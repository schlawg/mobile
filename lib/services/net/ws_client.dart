import 'package:flutter/foundation.dart';

import '../../app/env.dart';

const String oPeriodicMillis = 'intervalMillis';
const String oPeriodicId = 'periodicId';
const String oRetry = 'retry';

mixin WsClient {
  final Map<String, Function> _wsHandlers = {};

  // these funky wsNames are to avoid name collisions with mixing class

  // clients need to implement wsPath getter and add handlers or override onWsMsg
  String get wsPath;

  // optional overrides:

  void onWsMsg(Map<String, dynamic> msg) {}
  void onWsErr(Object err, StackTrace trace) {}
  void onWsDone() {}

  @nonVirtual
  void addWsHandlers(Map<String, Function> handlers) {
    _wsHandlers.addAll(handlers);
  }

  @nonVirtual
  void wsSend({String? t, Map<String, dynamic>? d, Map<String, dynamic>? o}) =>
      env.ws.send(this, t, d, o);

  // probably don't need to worry about connect, close, or dispatch
  @nonVirtual
  Future<void> wsConnect() => env.ws.connect(this);

  @nonVirtual
  void wsClose() => env.ws.remove(this);

  @nonVirtual
  bool wsHandleMsg(String type, Map<String, dynamic> data) {
    return _wsHandlers[type]?.call(data) != null;
  }
}

/*
const ctx: Worker = self as any
ctx.onmessage = (msg: MessageEvent) => {
  switch (msg.data.topic) {
    case 'create':
      create(msg.data.payload)
      break
    case 'send':
      doSend(msg.data.payload)
      break
    case 'ask': {
      const event = msg.data.payload.listenTo
      if (current &&
        current.options.registeredEvents.indexOf(event) === -1) {
        current.options.registeredEvents.push(event)
      }
      doSend(msg.data.payload.msg)
      break
    }
    case 'connect':
      if (current) current.connect()
      break
    case 'disconnect':
      if (current) current.disconnect()
      break
    case 'delayedDisconnect':
      if (current) current.delayedDisconnect(msg.data.payload)
      break
    case 'cancelDelayedDisconnect':
      if (current) current.cancelDelayedDisconnect()
      break
    case 'destroy':
      if (current) {
        current.disconnect()
        current = undefined
      }
      break
    case 'setVersion':
      if (current) {
        current.setVersion(msg.data.payload)
      }
      break
    case 'averageLag':
      if (current) {
        ctx.postMessage({ topic: 'averageLag', payload: Math.round(current.averageLag) })
      }
      else ctx.postMessage({ topic: 'averageLag', payload: null })
      break
    case 'getVersion':
      if (current) ctx.postMessage({ topic: 'getVersion', payload: current.version })
      else ctx.postMessage({ topic: 'getVersion', payload: null })
      break
    case 'deploy':
      if (current) current.deploy()
      break
    default:
      throw new Error('socker worker message not supported: ' + msg.data.topic)
  }
}

function create(payload: SocketSetup) {
  // don't always recreate default socket on page change
  // we don't want to do it for other sockets bc/ we want to register other
  // handlers on create
  if (current && payload.opts.options.name === 'default' &&
    current.options.name === 'default'
  ) {
    return
  }

  if (current) {
    current.disconnect(() => {
      current = new StrongSocket(
        ctx,
        payload.clientId,
        payload.socketEndPoint,
        payload.url,
        payload.version,
        payload.opts
      )
    })
  } else {
    current = new StrongSocket(
      ctx,
      payload.clientId,
      payload.socketEndPoint,
      payload.url,
      payload.version,
      payload.opts
    )
  }
}

function doSend(socketMsg: [string, string, any, any]) {
  const [url, t, d, o] = socketMsg
  if (current && current.ws) {
    if (current.path === url || url === 'noCheck') {
      current.send(t, d, o)
    } else {
      // trying to send to the wrong URL? log it
      const wrong = {
        t: t,
        d: d,
        url: url
      }
      current.send('wrongHole', wrong)
      console.warn('[socket] wrongHole', wrong)
    }
  }
}

typedef Unwrapper<T> = T Function(Map<String, dynamic> data);
typedef MapBehaviorSubject = BehaviorSubject<Map<String, dynamic>>;
typedef EventSubject = BehaviorSubject<Event>;
typedef MapStream = Stream<Map<String, dynamic>>;
typedef EventStream = Stream<Event>;

class ApiClient {
  static const host = 'https://lichess.org';

  List<http.Client> _httpClients = [];
  List<StreamSubscription> _streamSubs = [];

  //

  Future<Result<User>> getProfile() async =>
      getAndUnwrap('/api/account', unwrapper: User.fromJson, needAuth: true);

  Future<Result<EventStream>> getEventStream() => getStreamAndUnwrap(
        '/api/stream/event',
        needAuth: true,
        unwrapper: Event.fromJson,
      );

  Future<Result<EventStream>> getTvFeed() => getStreamAndUnwrap(
        '/api/tv/feed',
        unwrapper: Event.fromJson,
      );

  //

  void closeStreams() {
    for (final c in _httpClients) {
      c.close();
    }
    for (final s in _streamSubs) {
      s.cancel();
    }
    _httpClients = [];
    _streamSubs = [];
  }

  Future<ApiResponse> getStream(
    String path, {
    bool needAuth = false,
  }) async {
    Map<String, String> headers = {};
    if (needAuth) {
      String? token = await env.store.secureGet('token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        return ApiResponse.error(401);
      }
    }

    final req = http.Request('get', Uri.parse('$host$path'));
    req.headers.addAll(headers);
    final client = http.Client();
    final res = await client.send(req);
    if (res.statusCode != 200) {
      return ApiResponse.error(res.statusCode);
    }
    MapBehaviorSubject subject = BehaviorSubject();
    // length > 1 filters out the [10] keepalive messages
    _streamSubs.add(res.stream
        .where((e) => e.length > 1)
        .map(_decodeBytes)
        .listen(subject.add));
    return ApiResponse.stream(stream: subject);
  }

  Result<Stream<T>> unwrapStream<T>(
    ApiResponse response,
    Unwrapper<T> unwrapper,
  ) {
    // todo: maybe more error handling?
    if (!response.ok || response.stream == null) {
      return Result.error(response.error ?? response.status.toString());
    }
    return Result.ok(response.stream!.map(unwrapper));
  }

  Future<Result<Stream<T>>> getStreamAndUnwrap<T>(String path,
          {required Unwrapper<T> unwrapper, bool needAuth = false}) async =>
      unwrapStream(await getStream(path, needAuth: needAuth), unwrapper);

  Map<String, dynamic> _decodeBytes(List<int> bytes) =>
      jsonDecode(String.fromCharCodes(bytes));

  Future<ApiResponse> get(
    String path, {
    bool needAuth = false,
  }) async {
    try {
      Map<String, String> headers = {};
      if (needAuth) {
        String? token = await env.store.secureGet('token');
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        } else {
          return ApiResponse.error(401);
        }
      }

      final req = rc.Request(
        url: '$host$path',
        method: rc.RequestMethod.get,
        headers: headers,
      );
      final resp = await rc.Client().execute(request: req);
      if (resp.statusCode != 200) return ApiResponse.error(resp.statusCode);
      return ApiResponse.ok(data: resp.body);
    } catch (e, s) {
      debugPrint('ApiClient.get($path), error $e\n$s');
      return ApiResponse.error(500);
    }
  }

  Result<T> unwrapResponse<T>(ApiResponse response, Unwrapper<T> unwrapper) {
    if (!response.ok) {
      return Result.error(response.error ?? response.status.toString());
    }
    return Result.ok(
      unwrapper(response.data),
    );
  }

  Future<Result<T>> getAndUnwrap<T>(
    String path, {
    required Unwrapper<T> unwrapper,
    bool needAuth = false,
  }) async =>
      unwrapResponse(await get(path, needAuth: needAuth), unwrapper);
}
*/
