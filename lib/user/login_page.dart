import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '/app/env.dart';
import '/services/storage.dart';
import '/app/app_scaffold.dart';
import '/app/app.dart';
import '/app/ui.dart';

@immutable
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _uidCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  @override
  void initState() {
    super.initState();
    env.store.secureGet(keyUserId).then((uid) => _uidCtrl.text = uid ?? '');
    env.store.secureGet(keyPassword).then((pwd) => _pwdCtrl.text = pwd ?? '');
  }

  @override
  Widget build(BuildContext ctx) {
    return AppScaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: BlocProvider(
          create: (_) => _LoginCubit(),
          child: BlocBuilder<_LoginCubit, _LoginState>(builder: _onState),
        ),
      ),
    );
  }

  Widget _onState(BuildContext context, _LoginState state) {
    if (state is _SpinningLoginState) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is _EditableLoginState) {
      return ConstrainedWidthColumn(
        [
          TextField(
            decoration: const InputDecoration(icon: Icon(Icons.person), hintText: 'username'),
            autocorrect: false,
            maxLength: 20,
            autofocus: true,
            controller: _uidCtrl,
          ),
          TextField(
            decoration: const InputDecoration(icon: Icon(Icons.security), hintText: 'password'),
            obscureText: true,
            controller: _pwdCtrl,
          ),
          SizedBox(height: 60, child: Text(state.error ?? '')),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            TextButton(
              onPressed: () => context.go(Routes.register),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Text('REGISTER', style: UI.size22),
              ),
            ),
            TextButton(
              onPressed: () => BlocProvider.of<_LoginCubit>(context)
                  ._loginClicked(context, _uidCtrl.text, _pwdCtrl.text),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Text('LOGIN', style: UI.size22),
              ),
            ),
          ])
        ],
      );
    } else {
      return Container();
    }
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

class _LoginCubit extends Cubit<_LoginState> {
  _LoginCubit() : super(_LoginState.initial());

  void _loginClicked(BuildContext ctx, String username, String password) async {
    emit(_SpinningLoginState());
    env.user.login(userId: username, password: password).then((res) {
      if (res.ok) {
        ctx.go(Routes.lobby);
      } else {
        emit(_EditableLoginState(error: res.message));
      }
    });
  }

  @override
  Future<void> close() {
    return super.close();
  }
}

@immutable
abstract class _LoginState {
  const _LoginState();
  factory _LoginState.initial() => const _EditableLoginState();
}

@immutable
class _EditableLoginState extends _LoginState {
  const _EditableLoginState({this.error});
  final String? error;
}

@immutable
class _SpinningLoginState extends _LoginState {}
