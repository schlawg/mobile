import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/services/env.dart';
import '/services/storage.dart';
import '/services/net/lila_repo.dart';
import 'user_model.dart';
import '../app/app_scaffold.dart';
import '/app/app.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  // due to text editing controllers
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}
// look into freezed

class _LoginPageState extends State<LoginPage> {
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
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: BlocProvider(
          create: (_) => LoginCubit(),
          child: BlocBuilder<LoginCubit, LoginState>(builder: _onState),
        ),
      ),
    );
  }

  Widget _onState(BuildContext ctx, LoginState state) {
    if (state is SpinningLoginState) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is EditableLoginState) {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        TextFormField(
          decoration: env.thm.inputDecor(icon: Icon(Icons.person), hint: 'username'),
          maxLength: 20,
          controller: uidCtrl,
          validator: (value) => null,
        ),
        TextFormField(
          decoration: env.thm.inputDecor(icon: Icon(Icons.security), hint: 'password'),
          obscureText: true,
          controller: pwdCtrl,
          validator: (value) => null,
        ),
        SizedBox(height: 60, child: Text(state.error ?? '')),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton(
            onPressed: () =>
                BlocProvider.of<LoginCubit>(ctx)._loginClicked(ctx, uidCtrl.text, pwdCtrl.text),
            child: const Text('Login'),
          ),
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
    debugPrint('dispose');

    env.store.secureSet(keyUserId, uidCtrl.text);
    env.store.secureSet(keyPassword, pwdCtrl.text);

    uidCtrl.dispose();
    pwdCtrl.dispose();
    super.dispose();
  }
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginState.initial());

  void _loginClicked(BuildContext ctx, String username, String password) async {
    emit(SpinningLoginState());
    env.user.login(userId: username, password: password).then((res) {
      if (res.ok) {
        ctx.go(Routes.lobby);
      } else {
        emit(EditableLoginState(error: res.message));
      }
    });
  }

  @override
  Future<void> close() {
    return super.close();
  }
}

abstract class LoginState {
  const LoginState();
  factory LoginState.initial() => const EditableLoginState();
}

class EditableLoginState extends LoginState {
  const EditableLoginState({this.error});
  final String? error;
}

class SpinningLoginState extends LoginState {}
