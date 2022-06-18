import 'package:flutter/material.dart';
import 'app_sidebar.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  const AppScaffold({
    Key? key,
    required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _AppBar(),
      body: body,
      drawer: const AppSidebar(),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  _AppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('lichess.org'),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
