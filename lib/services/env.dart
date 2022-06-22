import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:go_router/go_router.dart';
import '/lobby/lobby_repo.dart';
import '/user/user_repo.dart';
import '/theme/theme.dart';
import '/theme/assets.dart';
import 'storage.dart';
import 'net/ws_repo.dart';
import 'net/lila_repo.dart';

final env = Env();

// group home for services, repos, and singletons

class Env {
  Storage get store => it.get<Storage>();
  UserRepo get user => it.get<UserRepo>();
  LobbyRepo get lobby => it.get<LobbyRepo>();
  WsRepo get ws => it.get<WsRepo>();
  LilaRepo get lila => it.get<LilaRepo>();
  Theme get thm => it.get<Theme>();
  Assets get assets => it.get<Assets>();

  String get origin => dotenv.env['origin'] ?? "http://localhost:9663";
  String url(String path) => p.Context(style: p.Style.url).join(origin, path);
  String get wsOrigin => dotenv.env['ws_origin'] ?? "ws://localhost:9664";
  String wsUrl(String path) => p.Context(style: p.Style.url).join(wsOrigin, path);
  // wsOrigin dotenv is temporary, wsOrigin will come from lila

  String? getVar(String variable) => dotenv.env[variable];

  final GetIt it = GetIt.instance;

  Future<void> init() async {
    // can specify for example:  flutter run --dart-define APP_CONFIG=test2
    // can also set env vars in info.plist and android manifest i believe
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
    it.registerSingleton<LilaRepo>(LilaRepo());
    it.registerSingleton<UserRepo>(UserRepo());
    it.registerSingleton<LobbyRepo>(LobbyRepo());
    it.registerSingleton<WsRepo>(WsRepo());
    it.registerSingleton<Theme>(Theme());
    it.registerSingleton<Assets>(Assets());
    await user.init();
    await assets.init();
  }
}
