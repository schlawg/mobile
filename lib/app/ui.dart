import 'package:flutter/material.dart';

// everything here should probably be static (and const if possible)

class UI {
  static var theme = ThemeData(
    fontFamily: "Roboto",
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff3692e7),
      primary: const Color(0xff3692e7),
      secondary: const Color(0xff629924),
      //tertiary: const Color(0xffcc3333),
      error: const Color(0xffcc3333),
    ),
  );

  static const size28 = TextStyle(fontSize: 28);
  static const size24 = TextStyle(fontSize: 24);
  static const size22 = TextStyle(fontSize: 22);
  static const size20 = TextStyle(fontSize: 20);
  static const size18 = TextStyle(fontSize: 18);
  static const size16 = TextStyle(fontSize: 16);
  static const size14 = TextStyle(fontSize: 14);

  static const squareWidthConstraint = BoxConstraints(maxWidth: 380);
}

class ConstrainedWidthColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment align;
  const ConstrainedWidthColumn(this.children, {Key? key, this.align = MainAxisAlignment.center})
      : super(key: key); // todo add optional background, etc.
  @override
  Widget build(BuildContext context) {
    Widget built = Container(
        constraints: UI.squareWidthConstraint,
        child: Column(mainAxisAlignment: align, children: children));
    if (true) {
      //centered) {
      built = Center(child: built);
    }
    return built;
  }
}
