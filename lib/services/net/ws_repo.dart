import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';

import '/app/app.dart';
import '/app/env.dart';
import '/services/maybe.dart';
import 'ws_client.dart';

const int pingInterval = 4000;

class WsRepo {
  WsRepo();
  late final AppStateBinding _appState;
  final Map<WsClient, _ClientData> _clients = {};
  // surely sure we only need one connection to ws at a time.  but maybe
  // there's some schizo stuff in the web client, set it up as a map for now

  void init() {
    env.user.addListener(_onSessionChanged);
    _appState = AppStateBinding(_resume, _suspend);
    debugPrint(_appState.toString()); // make _appState isn't used nag go away
    // is it wrong to aggregate things for side effects?  (cuz it feels so right)
  }

  Future<void> connect<T extends WsClient>(T client) async {
    if (env.store.cookie == null) return; // don't think lila-ws can be used without this
    try {
      if (_clients.containsKey(client)) close(client); // ?
      final sri = env.randomString();
      // joinPath will merge query params
      final url = env.joinPath(env.wsUrl(client.wsPath), '?sri=$sri');
      final ws = await WebSocket.connect(
        url,
        headers: {'cookie': env.store.cookie},
      );
      ws.listen(
        (msg) => _onMsg(client, msg),
        onDone: () => _onDone(client),
        onError: (err, trace) => _onErr(client, err, trace),
      );
      _clients[client] = _ClientData(ws, sri);
      Maybe.delay(ms: pingInterval, (_) => _ping(client));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void send(WsClient client, String? type, Map<String, dynamic>? data, Map<String, dynamic>? o) {
    String msg = json.encode(data ?? '');
    if (type != null) msg = '{"t":"$type","d":$msg}';
    _ClientData? cdata = _clients[client];

    if (cdata == null ||
        cdata.sock.readyState == WebSocket.closed ||
        cdata.sock.readyState == WebSocket.closing) {
      connect(client).then((_) => _clients[client]?.sock.add(msg));
    } else {
      cdata.sock.add(msg);
    }
  }

  void close(WsClient client) /* async */ {
    int state = _clients[client]?.sock.readyState ?? WebSocket.closed;
    if (state != WebSocket.closed && state != WebSocket.closing) {
      _clients[client]?.sock.close().catchError((_) {}); // TODO close code, reason?
    }
  }

  void remove(WsClient client) /* async */ {
    close(client);
    _clients.remove(client);
  }

  void _ping(WsClient client) {
    debugPrint("sending ping");
    final cdata = _clients[client]!;
    cdata.sock.add('{"t": "p"}');
    cdata.last = env.now;
  }

  void _suspend() {
    debugPrint("_suspend");
    for (final client in _clients.keys) {
      close(client);
    }
  }

  void _resume() {
    debugPrint("_resume");
    // connect modifies _clients map so copy keys first
    for (final client in List.of(_clients.keys)) {
      connect(client);
    }
  }

  void _onMsg(WsClient client, dynamic msg) {
    final cdata = _clients[client]!;
    debugPrint("_onMsg: $msg");
    if (_isPong(msg)) {
      cdata.history.add(env.now - cdata.last);
      Maybe.delay(ms: 4000, (_) => _ping(client));
    } else {
      final obj = json.decode(msg);
      final type = obj['t'];
      final data = type != null ? obj['d'] : obj;
      if (data is Map<String, dynamic>) {
        if (type == null || !client.wsHandleMsg(type, data)) {
          client.onWsMsg(data);
        }
      } else {
        debugPrint("got a $data");
      }
    }
    cdata.last = env.now;
  }

  void _onDone(WsClient client) {
    debugPrint("_onDone");
    client.onWsDone();
  }

  void _onErr(WsClient client, Object err, StackTrace trace) {
    debugPrint('WsRepo._onErr: $err');
    client.onWsErr(err, trace);
  }

  void _onSessionChanged() {
    if (!env.user.loggedIn) {
      _suspend();
      _resume();
    } else {
      _suspend();
      _resume();
    }
  }

  bool _isPong(String msg) {
    return msg == '0' || msg.startsWith('{"t":"n"');
  }
}

// probably not needed
class _ClientData {
  _ClientData(this.sock, this.sri);
  final WebSocket sock;
  final String sri;
  final history = [env.now];
  var last = env.now;
}
