import 'dart:io';
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

// group home for services, repos, and singletons
//
// Surely it is OK for something in the UI build tree to reach INTO env and access
// a service/repo related instance with no state-modifying side effects, although I do
// believe that sidestepping Provider is considered a crime against flutter in most
// UN member countries.
//
// Use the providers injected in main.dart rather than env when you can, I guess.
// storage, lilarepo, wsrepo, assets, userrepo, all available via provider.

class Env {
  int get nowMillis => DateTime.now().millisecondsSinceEpoch;

  //UI get ui => it.get<UI>();
  Storage get store => it.get<Storage>();
  UserRepo get user => it.get<UserRepo>();
  WsRepo get ws => it.get<WsRepo>();
  LilaRepo get lila => it.get<LilaRepo>();
  Assets get assets => it.get<Assets>();

  String get origin => dotenv.env['origin'] ?? "http://localhost:9663";
  String url(String path) => joinPath(origin, path);
  String get wsOrigin => dotenv.env['ws_origin'] ?? "ws://localhost:9664";
  String wsUrl(String path) => joinPath(wsOrigin, joinPath(path, 'v5'));

  String? getVar(String variable) => dotenv.env[variable];

  static String joinPath(String p1, String p2) {
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
      debugPrint("Failed to load config file.  Hope you like default values.");
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

Future<String?> _getId() async {
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    var iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo.identifierForVendor;
  } else if (Platform.isAndroid) {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    return androidDeviceInfo.androidId;
  } else {
    return 'chrome-blah-blah';
  }
}
