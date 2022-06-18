import 'package:flutter/material.dart';

// probably don't need this...  but could it be harder to use flutter's theme mgmt?
// fill this full of styles, fonts, decorators, eventually abstract and override.  clean
// up the mess as we go.  prefer shorter names, devs with small laptops will thank you!

class Theme {
  final ThemeData td = ThemeData(primarySwatch: Colors.blue);

  Color get bgColor => Color(0xff444444);
  Color get bg2Color => Color(0xff333333); // different shade than bg, but contrasts with all fg
  Color get fgColor => Color(0xffcccccc);
  Color get fg2Color => Color(0xffbbbbbb); // different shade then fg, but contrasts with all bg
  Color get primaryColor => Color(0xff4444ee);
  Color get secondaryColor => Color(0xff44bb44);

  InputDecoration inputDecor({Icon? icon, String? hint}) {
    // yes, currently useless
    return InputDecoration(icon: icon, hintText: hint);
  }

  TextStyle get h3TextStyle => const TextStyle(fontWeight: FontWeight.bold, fontSize: 20);
  TextStyle get btnTextStyle => const TextStyle(fontSize: 16);
}
