import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'app_sidebar.dart';
import 'app_scaffold.dart';
import '/user/login_page.dart';
import '/lobby/lobby_page.dart';
import '/services/env.dart';

class Routes {
  static const lobby = '/';
  static const login = '/login';
}

class LichessApp extends StatelessWidget {
  LichessApp({Key? key}) : super(key: key);

  final _appKey = GlobalKey();
  final _router = _buildRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      key: _appKey,
      title: 'Lichess',
      theme: env.thm.td,
      routeInformationProvider: _router.routeInformationProvider,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
    );
  }
}

GoRouter _buildRouter() {
  return GoRouter(
    urlPathStrategy: UrlPathStrategy.path,
    initialLocation: Routes.lobby,
    routes: [
      GoRoute(path: Routes.lobby, builder: (__, _) => LobbyPage()),
      GoRoute(path: Routes.login, builder: (__, _) => LoginPage()),
    ],
  );
}
