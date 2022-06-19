import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '/services/env.dart';
import '/services/storage.dart';
import '/app/app_scaffold.dart';
import '/app/app.dart';

@immutable
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final uidCtrl = TextEditingController();
  final pwdCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    env.store.secureGet(keyUserId).then((uid) => uidCtrl.text = uid ?? '');
    env.store.secureGet(keyPassword).then((pwd) => pwdCtrl.text = pwd ?? '');
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

  Widget _onState(BuildContext ctx, _LoginState state) {
    if (state is _SpinningLoginState) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is _EditableLoginState) {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        TextFormField(
          decoration: env.thm.inputDecor(icon: const Icon(Icons.person), hint: 'username'),
          maxLength: 20,
          controller: uidCtrl,
          validator: (value) => null,
        ),
        TextFormField(
          decoration: env.thm.inputDecor(icon: const Icon(Icons.security), hint: 'password'),
          obscureText: true,
          controller: pwdCtrl,
          validator: (value) => null,
        ),
        SizedBox(height: 60, child: Text(state.error ?? '')),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton(
            onPressed: () =>
                BlocProvider.of<_LoginCubit>(ctx)._loginClicked(ctx, uidCtrl.text, pwdCtrl.text),
            child: const Text('Login'),
          ),
          const SizedBox(width: 48),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Register'),
          )
        ])
      ]);
    } else {
      return Container(); // no idea why we need this, there are no other subclasses
    }
  }

  @override
  void dispose() {
    env.store.secureSet(keyUserId, uidCtrl.text);
    env.store.secureSet(keyPassword, pwdCtrl.text);

    uidCtrl.dispose();
    pwdCtrl.dispose();
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
