import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'env.dart';

class Assets {
  late final Widget octopus;

  Future<void> init() async {
    // just checking out this svg rendering class
    octopus = SvgPicture.asset('assets/images/octopus.svg', color: const Color(0x08000000));
  }
}
