import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:io';

import '/services/env.dart';
import 'ws_client.dart';

class WsRepo {
  final Map<WsClient, _ClientData> _clients = {};

  Future<void> connect<T extends WsClient>(T client) async {
    final sri = _makeSri();
    final uri =
        Uri.parse(env.wsUrl(client.path)).replace(queryParameters: {'sri': sri, 'mobile': 1});

    final ws = await WebSocket.connect(
      uri.toString(),
      headers: {'user-agent': 'lichess-mobile'},
    );
    _clients[client] = _ClientData(ws, sri, '');
    ws.listen(client.onMsg, onError: client.onErr, onDone: client.onDone);
  }

  void send(WsClient client, String msg) {
    _clients[client]?.sock.add(msg);
  }

  void close(WsClient client) async {
    WebSocket? ws = _clients[client]?.sock;
    _clients.remove(client);
    await ws?.close(); // TODO close code, reason
  }

  void onMsg(dynamic msg) {
    if (msg is String) {
      debugPrint("onMsg: $msg");
    }
  }

  void onErr(Object err, StackTrace trace) {
    debugPrint(err.toString());
    debugPrint(trace.toString());
  }
}

class _ClientData {
  _ClientData(this.sock, this.sri, this.sessionId);
  final WebSocket sock;
  final String sri;
  String sessionId;
}

String _makeSri() {
  var src = Random.secure();
  return base64UrlEncode(List<int>.generate(6, (_) => src.nextInt(255)))
      .substring(0, 8)
      .replaceAll(RegExp(r'[/+]'), '_');
}
