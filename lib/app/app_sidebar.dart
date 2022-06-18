import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/app/app.dart';
import '/user/login_page.dart';
import '/services/env.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:go_router/go_router.dart';

class AppSidebar extends StatefulWidget {
  const AppSidebar({Key? key}) : super(key: key);

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  bool inUserMenu = false;

  void _toggleUserMenu() => setState(() => inUserMenu = !inUserMenu);

  @override
  Widget build(BuildContext context) {
    List<DrawerEntry> items = [];
    if (inUserMenu) {
      items.addAll([
        DrawerItem(
          icon: MdiIcons.human,
          label: 'Profile',
          onTap: () {},
        ),
        DrawerItem(
          icon: MdiIcons.chessPawn,
          label: 'Games',
          onTap: () {},
        ),
        DrawerItem(
          icon: MdiIcons.message,
          label: 'Inbox',
          onTap: () {},
        ),
        DrawerItem(
          icon: MdiIcons.cog,
          label: 'Preferences',
          onTap: () {},
        ),
        DrawerItem(
          icon: MdiIcons.group,
          label: '0 friends online',
          onTap: () {},
        ),
        DrawerItem(
          icon: MdiIcons.power,
          label: 'Sign out',
          onTap: env.user.logout,
        ),
      ]);
    } else {
      items.addAll([
        DrawerItem(
          icon: MdiIcons.home,
          label: 'Home',
          onTap: () => context.go(Routes.lobby),
        ),
        const DrawerSubtitle('Play online'),
        DrawerItem(
          icon: MdiIcons.plusCircle,
          label: 'Create a game',
          onTap: () {},
        ),
        DrawerItem(
          icon: MdiIcons.trophy,
          label: 'Tournaments',
          onTap: () {},
        ),
        const DrawerSubtitle('Learn'),
        DrawerItem(
          icon: MdiIcons.target,
          label: 'Puzzles',
          onTap: () {},
        ),
        DrawerItem(
          icon: MdiIcons.target,
          label: 'Study',
          onTap: () {},
        ),
        DrawerItem(
          icon: MdiIcons.target,
          label: 'Coordinates',
          onTap: () {},
        ),
        const DrawerSubtitle('Watch'),
        DrawerItem(
          icon: MdiIcons.televisionClassic,
          label: 'Watch games',
          onTap: () {},
        ),
        const DrawerSubtitle('Community'),
        DrawerItem(
          icon: MdiIcons.at,
          label: 'Players',
          onTap: () {},
        ),
        const DrawerSubtitle('Tools'),
        DrawerItem(
          icon: MdiIcons.microscope,
          label: 'Analysis',
          onTap: () {},
        ),
        DrawerItem(
          icon: MdiIcons.pencil,
          label: 'Board Editor',
          onTap: () {},
        ),
        DrawerItem(
          icon: MdiIcons.clock,
          label: 'Clock',
          onTap: () {},
        ),
        DrawerItem(
          icon: MdiIcons.cloudUpload,
          label: 'Import Game',
          onTap: () {},
        ),
        DrawerItem(
          icon: MdiIcons.magnify,
          label: 'Advanced search',
          onTap: () {},
        ),
        const DrawerSubtitle('Play offline'),
        DrawerItem(
          icon: MdiIcons.cogs,
          label: 'Computer',
          onTap: () {},
        ),
        DrawerItem(
          icon: MdiIcons.cup,
          label: 'Over the board',
          onTap: () {},
        ),
      ]);
    }
    return Drawer(
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
                  if (env.user.loggedIn) _userHeader('logged in user'),
                  if (!env.user.loggedIn) _loginButton(),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: items.map(_drawerEntry).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerEntry(DrawerEntry item) {
    if (item is DrawerItem) {
      return ListTile(
        leading: Icon(item.icon),
        title: Text(item.label),
        onTap: item.onTap,
        dense: true,
      );
    } else {
      return ListTile(title: Text(item.label));
    }
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
}

class DrawerEntry {
  final String label;
  const DrawerEntry(this.label);
}

class DrawerSubtitle extends DrawerEntry {
  const DrawerSubtitle(String label) : super(label);
}

class DrawerItem extends DrawerEntry {
  final IconData icon;
  final VoidCallback onTap;
  const DrawerItem({
    required this.icon,
    required String label,
    required this.onTap,
  }) : super(label);
}
