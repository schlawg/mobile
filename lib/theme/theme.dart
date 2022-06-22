import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// move to flutter's theme stuff eventually?
// fill this full of styles, fonts, decorators, and appearance related junk
//
// flutter dips are 96/in or 38/cm, 240 dips can be min width?

/* TODO abstract */ class Theme {
  final ThemeData td = ThemeData(primarySwatch: Colors.blue);

  final Color bgColor = const Color(0xff444444);
  final Color bg2Color = const Color(0xff333333);
  final Color fgColor = const Color(0xffcccccc);
  final Color fg2Color = const Color(0xffbbbbbb);
  final Color primaryColor = const Color(0xff4444ee);
  final secondaryColor = const Color(0xff44bb44);
  final lightTranspColor = const Color(0x08000000);

  InputDecoration inputDecor({Icon? icon, String? hint}) {
    // yes, currently useless
    return InputDecoration(icon: icon, hintText: hint);
  }

  final TextStyle h3TextStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 20);
  final TextStyle btnTextStyle = const TextStyle(fontSize: 16);
}
