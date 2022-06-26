import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

abstract class AppStateObserver extends WidgetsBindingObserver {
  AppStateObserver() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  Future<void> resume();

  Future<void> suspend();

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await resume();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        await suspend();
        break;
    }
  }
}
