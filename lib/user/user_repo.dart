import 'package:flutter/foundation.dart';
import 'user_model.dart';
import '/app/env.dart';
import '/services/storage.dart';
import '/services/net/lila_repo.dart';

/*@immutable
class UserSession {
  const UserSession({
    required String sid,
    required User me,
  });
}*/

class UserRepo extends ChangeNotifier {
  User? me;
  final sessionIdRegex = RegExp(r'sessionId=([A-Za-z0-9+/]{6,})');

  bool get loggedIn => me != null;

  Future<void> init() async {
    // this is temporary, don't want to block startup trying to connect
    if (await env.lila.online()) {
      // we have networking
      //login(userId: 'li', password: 'password');
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
    } else {
      _clearSession();
      return userResult;
    }
    if (userResult.headers != null) {
      env.store.cookie = userResult.headers!['set-cookie']?.first;
    }
    // let's get it all
    final acctResult = (await env.lila.get('/account/info', rspFactory: User.fromJson));
    if (acctResult.ok) {
      me = acctResult.object;
      notifyListeners();
    } else {
      debugPrint(acctResult.toString());
    }
    return acctResult;
  }

  Future<LilaResult> logout() async {
    final result = me != null ? await env.lila.post('/logout') : const LilaResult(status: 200);
    _clearSession();
    notifyListeners();
    return result;
  }

  void _clearSession() {
    me = null;
    env.store.cookie = null;
    env.store.sessionId = null;
    // shut down ws connections
  }
}
