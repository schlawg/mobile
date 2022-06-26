import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'app/env.dart';
import 'user/user_repo.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await env.init();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<UserRepo>(
        create: (context) => env.user, // not a creatae
      ) // let's hope provider never finds out!
    ],
    child: LichessApp(),
  ));
}
