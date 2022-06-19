import 'package:device_info_plus/device_info_plus.dart';
import 'login_page.dart';
import 'user_model.dart';
import '/services/env.dart';
import '/services/storage.dart';
import '/services/net/lila_repo.dart';
import 'dart:io';
import 'dart:convert';

class UserRepo {
  bool get loggedIn => false; //env.store.sessionId != null;

  Future<void> init() async {
    // this is temporary, don't want to block startup trying to connect
    if (await env.lila.online()) {
      // we have networking
    }
  }

  Future<LilaResult<User>> info() {
    return env.lila.get('/account/info', rspFactory: User.fromJson);
  }

  Future<LilaResult<User>> login({String? userId, String? password}) async {
    userId ??= await env.store.secureGet(keyUserId);
    password ??= await env.store.secureGet(keyPassword);
    if (userId == null || password == null) {
      _clearSession();
      throw Exception('userId or password is null');
    }
    final res = await env.lila.post(
      '/login',
      body: {
        'username': userId,
        'password': password,
      },
      rspFactory: User.fromJson,
    );
    Map<String, List<String>>? hdrs = res.headers;
    if (hdrs != null) {
      env.store.sessionId = RegExp(r'sessionId=([A-Za-z0-9+/]{6,})')
          .firstMatch(hdrs['set-cookie']?.first ?? '')
          ?.group(1);
    }
    return res;
  }

  void logout() {
    env.lila.post("/logout").then(
          (_) => _clearSession(),
          onError: (_) => _clearSession(),
        );
  }

  Future<void> _clearSession() async {
    env.store.sessionId = null;
  }
}

Future<String?> _getId() async {
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    var iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo.identifierForVendor;
  } else if (Platform.isAndroid) {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    return androidDeviceInfo.androidId;
  } else {
    return 'chrome-blah-blah';
  }
}
