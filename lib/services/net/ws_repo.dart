import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:io';

import '../../app/app_state_observer.dart';
import '../../app/env.dart';
import 'ws_client.dart';

// WsRepo restores client connections transparently
// across app suspend/resumes, connection fails, retries, etc.
// handles ping/pong shite and little else.
class WsRepo extends AppStateObserver {
  WsRepo() : super();

  final Map<WsClient, _ClientData> _clients = {};

  void init() {
    env.user.addListener(_loginStateChanged);
  }

  Future<void> connect<T extends WsClient>(T client) async {
    if (_clients.containsKey(client)) close(client);
    final sri = _makeSri();
    // WsClient subclass might specify its own query params in wsPath getter, use joinPath
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
  }

  void send(WsClient client, dynamic msg) {
    _clients[client]?.sock.add(msg is String ? msg : json.encode(msg));
  }

  void close(WsClient client) /* async */ {
    WebSocket? ws = _clients[client]?.sock;
    _clients.remove(client);
    /* await */ ws?.close().catchError((_) {}); // TODO close code, reason?
  }

  @override
  Future<void> suspend() async {
    _clients.forEach((client, cdata) {
      try {
        cdata.sock.close().catchError((_) {});
      } catch (_) {}
    });
  }

  @override
  Future<void> resume() async {
    // connect modifies _clients map so copy keys first
    for (final client in List.of(_clients.keys)) {
      connect(client);
    }
  }

  void _clear() {
    // connect modifies _clients map so copy keys first
    for (final client in List.of(_clients.keys)) {
      close(client);
    }
    _clients.clear();
  }

  void _onMsg(WsClient client, dynamic msg) {
    final cdata = _clients[client];
    if (msg is String && cdata != null) {
      debugPrint("_onMsg: $msg");
      if (msg == '0') {
        cdata.latest = env.nowMillis;
        _pong(cdata);
        return;
      }
      client.onWsMsg(json.decode(msg));
    }
  }

  void _onDone(WsClient client) {
    debugPrint("_onDone");
    client.onWsDone();
  }

  void _onErr(WsClient client, Object err, StackTrace trace) {
    debugPrint('WsRepo._onErr: $err');
    client.onWsErr(err, trace);
  }

  void _loginStateChanged() {
    if (!env.user.loggedIn) {
      _clear();
    }
  }

  void _pong(_ClientData cdata) {
    debugPrint("sending pong...");
    cdata.sock.add('{"t":"p"}');
  }

/*  
  void pingAll() {
    // keep it simple for now
    for (final client in List.of(_clients.keys)) {
      send(client, '{"t":"p"}');
    }
  }
  */
}

class _ClientData {
  _ClientData(this.sock, this.sri);
  final WebSocket sock;
  final String sri;
  int latest = env.nowMillis;
}

String _makeSri() {
  var src = Random.secure();
  return base64UrlEncode(List<int>.generate(9, (_) => src.nextInt(255)))
      .substring(0, 12)
      .replaceAll(RegExp(r'[/+]'), '_');
}
