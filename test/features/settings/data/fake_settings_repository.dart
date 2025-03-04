import 'package:flutter/material.dart';
import 'package:lichess_mobile/src/features/settings/data/settings_repository.dart';

class FakeSettingsRepository implements SettingsRepository {
  ThemeMode themeMode = ThemeMode.system;
  bool soundMuted = false;

  @override
  Future<bool> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    return true;
  }

  @override
  ThemeMode getThemeMode() {
    return themeMode;
  }

  @override
  Future<bool> toggleSound() async {
    soundMuted = !soundMuted;
    return true;
  }

  @override
  bool isSoundMuted() {
    return soundMuted;
  }
}
