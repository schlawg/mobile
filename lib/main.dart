import 'package:flutter/material.dart';
import '/app/app.dart';
import '/services/env.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await env.init();
  runApp(LichessApp());
}
