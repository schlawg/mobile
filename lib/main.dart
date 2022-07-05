import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'app/env.dart';
import 'services/storage.dart';
import 'user/user_repo.dart';
import 'services/net/ws_repo.dart';
import 'services/net/lila_repo.dart';
import 'app/assets.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }*/
  await env.init();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<UserRepo>(
        create: (_) => env.user,
      ),
      Provider<Storage>(create: (_) => env.store), // let's hope provider never finds out
      Provider<WsRepo>(create: (_) => env.ws),
      Provider<LilaRepo>(create: (_) => env.lila),
      Provider<Assets>(create: (_) => env.assets),
    ],
    child: LichessApp(),
  ));
}
