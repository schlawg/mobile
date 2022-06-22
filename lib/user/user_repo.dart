import 'package:device_info_plus/device_info_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'user_model.dart';
import '/services/env.dart';
import '/services/storage.dart';
import '/services/net/lila_repo.dart';
import 'dart:io';
import 'dart:convert';

/*@immutable
class UserSession {
  const UserSession({
    required String sid,
    required User me,
  });
}*/

class UserRepo {
  User? me;

  bool get loggedIn => me != null;

  Future<void> init() async {
    // this is temporary, don't want to block startup trying to connect
    if (await env.lila.online()) {
      // we have networking
      login(userId: 'li', password: 'password');
    }
  }

  Future<LilaResult<User>> getUser(String userId) async {
    return await env.lila.get('/api/user/$userId', rspFactory: User.fromJson);
  }

  Future<LilaResult<User>> login({String? userId, String? password}) async {
    userId ??= await env.store.secureGet(keyUserId);
    password ??= await env.store.secureGet(keyPassword);
    if (userId == null || password == null) {
      _clearSession();
      return const LilaResult(status: 0, body: 'userId or password is null');
    }
    final userResult = await env.lila.post(
      '/login',
      body: {
        'username': userId.toLowerCase(),
        'password': password,
      },
      rspFactory: User.fromJson,
    );
    if (userResult.object?.sessionId != null) {
      env.store.sessionId = userResult.object?.sessionId!;
    } else if (userResult.headers != null) {
      env.store.sessionId = RegExp(r'sessionId=([A-Za-z0-9+/]{6,})')
          .firstMatch(userResult.headers!['set-cookie']?.first ?? '')
          ?.group(1);
    } else {
      _clearSession();
      return userResult;
    }
    // let's get the full monty
    final acctResult = (await env.lila.get('/account/info', rspFactory: User.fromJson));
    if (acctResult.ok) {
      me = acctResult.object;
    } else {
      debugPrint(acctResult.toString());
    }
    return acctResult;
  }

  Future<LilaResult> logout() async {
    final result = me != null ? await env.lila.post('/logout') : const LilaResult(status: 200);
    _clearSession();
    return result;
  }

  void _clearSession() {
    me = null;
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
