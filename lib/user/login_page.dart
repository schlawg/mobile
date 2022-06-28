import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '/services/storage.dart';
import '/app/app_scaffold.dart';
import '/app/app.dart';
import '/app/ui.dart';
import '/app/env.dart';
import 'user_repo.dart';

// don't need cubit for this.
@immutable
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _uidCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _spinning = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    env.store.secureGet(keyUserId).then((uid) => _uidCtrl.text = uid ?? '');
    env.store.secureGet(keyPassword).then((pwd) => _pwdCtrl.text = pwd ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: _spinning
          ? const CircularProgressIndicator()
          : ConstrainedWidthColumn(
              [
                TextField(
                  decoration: const InputDecoration(icon: Icon(Icons.person), hintText: 'username'),
                  autocorrect: false,
                  maxLength: 20,
                  autofocus: true,
                  controller: _uidCtrl,
                ),
                TextField(
                  decoration:
                      const InputDecoration(icon: Icon(Icons.security), hintText: 'password'),
                  obscureText: true,
                  controller: _pwdCtrl,
                ),
                SizedBox(height: 60, child: Text(_error ?? '')),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  TextButton(
                    onPressed: () => context.go(Routes.register),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      child: Text('REGISTER', style: UI.size20),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _spinning = true;
                      _error = null;
                      context
                          .read<UserRepo>()
                          .login(userId: _uidCtrl.text, password: _pwdCtrl.text)
                          .then((res) {
                        _spinning = false;
                        if (res.ok) {
                          _error = null;
                          context.go(Routes.lobby);
                        } else {
                          _error = res.message;
                        }
                      });
                    }),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      child: Text('LOGIN', style: UI.size20),
                    ),
                  ),
                ])
              ],
            ),
    ));
  }

  @override
  void dispose() {
    env.store.secureSet(keyUserId, _uidCtrl.text);
    env.store.secureSet(keyPassword, _pwdCtrl.text);
    _uidCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }
}
