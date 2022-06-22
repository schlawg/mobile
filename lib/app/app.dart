import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'app_drawer.dart';
import 'app_scaffold.dart';
import '/user/login_page.dart';
import '/user/profile_page.dart';
import '/lobby/lobby_page.dart';
import '/services/env.dart';

class Routes {
  static const lobby = '/';
  static const login = '/login';
  static const profile = '/profile';
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
      GoRoute(path: Routes.profile, builder: (__, state) => ProfilePage(state.queryParams['uid'])),
    ],
    redirect: (state) {
      if (!env.user.loggedIn && false) {
        // check if route needs auth
        return Routes.login;
      }

      if (env.user.loggedIn && state.subloc == Routes.login) return Routes.lobby;

      return null;
    },
  );
}
