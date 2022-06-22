import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '/services/env.dart';
import '/services/storage.dart';
import '/app/app_scaffold.dart';
import '/app/app.dart';
import '/services/net/lila_repo.dart';
import 'user_model.dart';

@immutable
class ProfilePage extends StatelessWidget {
  const ProfilePage(this.uid, {Key? key}) : super(key: key);
  final String? uid;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: BlocProvider(
          create: (_) => _ProfileCubit(uid),
          child: BlocBuilder<_ProfileCubit, _ProfileState>(builder: _onState),
        ),
      ),
    );
  }

  Widget _onState(BuildContext ctx, _ProfileState state) {
    if (state is _SpinningProfileState) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is _LoadedProfileState) {
      User u = state.user;
      // TODO: if u == env.user.me, allow editing
      return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(MediaQuery.of(ctx).size.toString()),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('First name: ${u.profile?.firstName}'),
            //const SizedBox(width: 48),
            Text('Last name: ${u.profile?.lastName}'),
          ],
        ),
        SizedBox(height: 60),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 48),
          ],
        )
      ]);
    } else {
      return Center(child: Text((state as _ErrorProfileState).error));
    }
  }
}

class _ProfileCubit extends Cubit<_ProfileState> {
  _ProfileCubit(String? uid) : super(_ProfileState.initial()) {
    if (uid != null && uid != env.user.me?.id) {
      env.user.getUser(uid).then(_loadProfile);
    } else if (env.user.me != null) {
      _loadProfile(LilaResult<User>(status: 200, object: env.user.me));
    } else {
      _loadProfile(const LilaResult(status: 0, body: 'null user'));
    }
  }

  void _loadProfile(LilaResult<User> res) {
    if (res.ok) {
      emit(_LoadedProfileState(res.object!));
    } else {
      emit(_ErrorProfileState(res.message));
    }
  }

  @override
  Future<void> close() {
    return super.close();
  }
}

@immutable
abstract class _ProfileState {
  const _ProfileState();
  factory _ProfileState.initial() => _SpinningProfileState();
}

@immutable
class _LoadedProfileState extends _ProfileState {
  const _LoadedProfileState(this.user);
  final User user;
}

@immutable
class _ErrorProfileState extends _ProfileState {
  const _ErrorProfileState(this.error);
  final String error;
}

@immutable
class _SpinningProfileState extends _ProfileState {}
