import 'package:device_info_plus/device_info_plus.dart';
import 'lobby_page.dart';
import '/user/user_model.dart';
import 'lobby_model.dart';
import '../app/env.dart';
import '/services/net/lila_repo.dart';
import 'dart:io';
import 'dart:convert';

class LobbyRepo {
  Future<LilaResult<LobbyRsp>> fetch() async {
    return await env.lila.get("/", rspFactory: LobbyRsp.fromJson);
  }
}
