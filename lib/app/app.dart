import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'app_drawer.dart';
import 'app_scaffold.dart';
import '/user/login_page.dart';
import '/user/profile_page.dart';
import '/user/prefs_page.dart';
import '/user/register_page.dart';
import '/lobby/lobby_page.dart';
import 'env.dart';
import 'ui.dart';

class Routes {
  static const lobby = '/';
  static const login = '/login';
  static const profile = '/profile';
  static const register = '/register';
  static const prefs = '/prefs';
  static const game = '/:gameId';
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
      theme: UI.theme,
      routeInformationProvider: _router.routeInformationProvider,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
    );
  }
}

class AppStateBinding extends WidgetsBindingObserver {
  AppStateBinding(this._resume, this._suspend) {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  final Function _resume;
  final Function _suspend;

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        _resume();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _suspend();
        break;
    }
  }
}

GoRouter _buildRouter() {
  return GoRouter(
    urlPathStrategy: UrlPathStrategy.path,
    initialLocation: Routes.lobby,
    routes: [
      GoRoute(path: Routes.lobby, builder: (ctx, state) => const LobbyPage()),
      GoRoute(path: Routes.login, builder: (__, _) => const LoginPage()),
      GoRoute(path: Routes.register, builder: (__, _) => const RegisterPage()),
      GoRoute(path: Routes.prefs, builder: (__, _) => const RegisterPage()),
      GoRoute(path: Routes.profile, builder: (__, state) => ProfilePage(state.queryParams['uid'])),
      GoRoute(path: Routes.game, builder: (ctx, state) => _gameUrl(ctx, state)),
    ],
    redirect: (state) {
      return null;
    },
  );
}

Widget _gameUrl(BuildContext ctx, GoRouterState state) {
  final gameId = state.params['gameId'];
  if (gameId != null) {
    debugPrint('woohoo! $gameId');
    return Container();
  } else {
    return const LobbyPage();
  }
}
