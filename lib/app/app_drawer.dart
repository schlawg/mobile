import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/app/app.dart';
import '/user/login_page.dart';
import 'env.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool inUserMenu = false;

  void _toggleUserMenu() => setState(() => inUserMenu = !inUserMenu);

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    if (inUserMenu) {
      items.addAll([
        _item(icon: MdiIcons.human, text: 'Profile', onTap: _profile),
        _item(icon: MdiIcons.chessPawn, text: 'Games', onTap: () {}),
        _item(icon: MdiIcons.message, text: 'Inbox', onTap: () {}),
        _item(icon: MdiIcons.cog, text: 'Preferences', onTap: () {}),
        _item(icon: MdiIcons.group, text: '0 friends online', onTap: () {}),
        _item(icon: MdiIcons.power, text: 'Sign out', onTap: () => _logout()),
      ]);
    } else {
      items.addAll([
        _item(icon: MdiIcons.home, text: 'Home', onTap: _home),
        _item(text: 'Play online'),
        _item(icon: MdiIcons.plusCircle, text: 'Create a game', onTap: () {}),
        _item(icon: MdiIcons.trophy, text: 'Tournaments', onTap: () {}),
        _item(text: 'Learn'),
        _item(icon: MdiIcons.target, text: 'Puzzles', onTap: () {}),
        _item(icon: MdiIcons.target, text: 'Study', onTap: () {}),
        _item(icon: MdiIcons.target, text: 'Coordinates', onTap: () {}),
        _item(text: 'Watch'),
        _item(icon: MdiIcons.televisionClassic, text: 'Watch games', onTap: () {}),
        _item(text: 'Community'),
        _item(icon: MdiIcons.at, text: 'Players', onTap: () {}),
        _item(text: 'Tools'),
        _item(icon: MdiIcons.microscope, text: 'Analysis', onTap: () {}),
        _item(icon: MdiIcons.pencil, text: 'Board Editor', onTap: () {}),
        _item(icon: MdiIcons.clock, text: 'Clock', onTap: () {}),
        _item(icon: MdiIcons.cloudUpload, text: 'Import Game', onTap: () {}),
        _item(icon: MdiIcons.magnify, text: 'Advanced search', onTap: () {}),
        _item(text: 'Play offline'),
        _item(icon: MdiIcons.cogs, text: 'Computer', onTap: () {}),
        _item(icon: MdiIcons.cup, text: 'Over the board', onTap: () {}),
      ]);
    }
    return Drawer(
      key: const PageStorageKey('/drawer'),
      child: Column(
        children: [
          SafeArea(
            child: Container(
              width: double.infinity,
              color: Colors.grey[200],
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // TODO: network status bar
                  if (env.user.loggedIn) _userHeader(env.user.me!.username) else _loginButton(),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: items,
            ),
          ),
        ],
      ),
    );
  }

  Widget _item({IconData? icon, String? text, VoidCallback? onTap}) {
    return ListTile(
      leading: (icon != null) ? Icon(icon) : null,
      title: Text(text ?? ''),
      onTap: onTap,
      dense: onTap != null,
    );
  }

  Widget _userHeader(String user) => InkWell(
        onTap: _toggleUserMenu,
        child: Row(
          children: [
            Text(
              user,
              style: const TextStyle(fontSize: 24),
            ),
            Icon(inUserMenu ? MdiIcons.chevronUp : MdiIcons.chevronDown),
          ],
        ),
      );

  Widget _loginButton() => ElevatedButton(
        onPressed: () => context.go(Routes.login),
        child: const Text('Login'),
      );

  void _profile() async {
    context.go(Routes.profile + '?uid=ana');
  }

  void _logout() {
    env.user.logout().then((_) {
      setState(() => inUserMenu = false);
    });
  }

  void _home() {
    //if (GoRouter.of(context).location == Routes.lobby) {
    //  GoRouter.of(context).pop();
    //} else {
    context.go(Routes.lobby);
    context.pop();

    //}
  }
}
