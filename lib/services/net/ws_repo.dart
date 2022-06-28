import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:io';

import '/app/app.dart';
import '/app/env.dart';
import 'ws_client.dart';

// WsRepo restores client connections transparently
// across app suspend/resumes, connection fails, retries, etc.
// handles ping/pong shite, app events, and little else.
class WsRepo {
  WsRepo();
  late final AppStateBinding _appState;
  final Map<WsClient, _ClientData> _clients = {};

  void init() {
    env.user.addListener(_onSessionChanged);
    _appState = AppStateBinding(_connectAll, _closeAll);
    debugPrint(_appState.toString()); // make _appState isn't used nag go away
  }

  Future<void> connect<T extends WsClient>(T client) async {
    if (_clients.containsKey(client)) close(client); // ?
    final sri = _makeSri();
    // could a client provide query params in wsPath getter?  use joinPath just in case
    final url = Env.joinPath(env.wsUrl(client.wsPath), '?sri=$sri');
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
    int state = _clients[client]?.sock.readyState ?? WebSocket.closed;
    if (state != WebSocket.closed && state != WebSocket.closing) {
      _clients[client]?.sock.close().catchError((_) {}); // TODO close code, reason?
    }
  }

  void remove(WsClient client) /* async */ {
    close(client);
    _clients.remove(client);
  }

  void _closeAll() {
    debugPrint("_closeAll");
    for (final client in _clients.keys) {
      close(client);
    }
  }

  void _connectAll() {
    debugPrint("_connectAll");
    // connect modifies _clients map so copy keys first
    for (final client in List.of(_clients.keys)) {
      connect(client);
    }
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

  void _onSessionChanged() {
    if (!env.user.loggedIn) {
      _closeAll();
    } else {
      _connectAll();
    }
  }

  void _pong(_ClientData cdata) {
    debugPrint("sending pong...");
    cdata.sock.add('{"t":"p"}');
  }
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
