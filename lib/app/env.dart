import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '/user/user_repo.dart';
import '/services/storage.dart';
import '/services/net/ws_repo.dart';
import '/services/net/lila_repo.dart';
import 'assets.dart';
//import 'ui.dart';

final env = Env();

// group home for services/repos/singletons and helpers yet to be moved
//
// Surely it is OK for something in the UI build tree to reach INTO env and access
// a service/repo related instance with no build state-modifying side effects, although
// it is true that sidestepping Provider is considered a crime against flutter in most
// UN member countries.
//
// Use the providers injected in main.dart rather than env when you can, I guess.
// storage, lilarepo, wsrepo, assets, userrepo, all available via provider.

class Env {
  //UI get ui => it.get<UI>();
  Storage get store => it.get<Storage>();
  UserRepo get user => it.get<UserRepo>();
  WsRepo get ws => it.get<WsRepo>();
  LilaRepo get lila => it.get<LilaRepo>();
  Assets get assets => it.get<Assets>();

  Future<String?> get deviceId async => _getDeviceId();
  String get origin => dotenv.env['origin'] ?? "http://localhost:9663";
  String url(String path) => joinPath(origin, path);
  String get wsOrigin => dotenv.env['ws_origin'] ?? "ws://localhost:9664";
  String wsUrl(String path) => joinPath(wsOrigin, joinPath(path, 'v5'));

  String? getVar(String variable) => dotenv.env[variable];

  // the following could be static, but don't want callers to have to worry about Env vs env
  int get now => DateTime.now().millisecondsSinceEpoch;

  String randomString({int len = 12}) {
    var src = Random.secure();
    return base64UrlEncode(List<int>.generate((len * 3 + 3) ~/ 4, (_) => src.nextInt(255)))
        .substring(0, len)
        .replaceAll(RegExp(r'[/+]'), '_');
  }

  String joinPath(String p1, String p2) {
    final base = Uri.parse(p1); // safely join p2 to p1, merging any query params
    final rhs = Uri.parse(p2);
    return base.replace(
      pathSegments: [...base.pathSegments, ...rhs.pathSegments],
      queryParameters: (base.hasQuery || rhs.hasQuery)
          ? {...base.queryParameters, ...rhs.queryParameters}
          : null,
    ).toString();
  }

  final GetIt it = GetIt.instance;

  Future<void> init() async {
    // can specify for example:  flutter run --dart-define APP_CONFIG=test2
    // can also set env vars in info.plist and android manifest
    const appConfig = String.fromEnvironment('APP_CONFIG', defaultValue: 'dev'); // 'prod'
    try {
      debugPrint("Using assets/conf/$appConfig.env");
      await dotenv.load(fileName: "assets/conf/$appConfig.env");
    } catch (e) {
      dotenv.testLoad();
      debugPrint("Failed to load config.  I hear default values are lovely this time of year.");
    }
    it.registerSingleton<Storage>(Storage());
    await store.init();

    //it.registerSingleton<UI>(UI());
    it.registerSingleton<LilaRepo>(LilaRepo());
    it.registerSingleton<UserRepo>(UserRepo());
    it.registerSingleton<WsRepo>(WsRepo());
    it.registerSingleton<Assets>(Assets());
    await user.init();
    await assets.init(); // for the octopus.  octopus > horsey.
    ws.init();
  }
}

Future<String?> _getDeviceId() async {
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    var iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo.identifierForVendor;
  } else if (Platform.isAndroid) {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    return androidDeviceInfo.androidId;
  } else {
    return 'web';
  }
}
