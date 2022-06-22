import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/services/env.dart';

class Assets {
  late final Widget octopus;

  Future<void> init() async {
    // just checking out this svg rendering class
    octopus = SvgPicture.asset('assets/images/octopus.svg', color: env.thm.lightTranspColor);
  }
}
