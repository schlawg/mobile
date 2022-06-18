import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/services/env.dart';
import 'package:mobile/services/net/lila_repo.dart';
import 'lobby_model.dart';
import '../app/app_scaffold.dart';

class LobbyPage extends StatelessWidget {
  const LobbyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    return AppScaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocProvider(
                create: (_) => LobbyCubit(),
                child: BlocBuilder<LobbyCubit, LobbyState>(builder: _onState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _onState(BuildContext ctx, LobbyState state) {
    if (state is SuccessLobbyState) {
      return _quickPairing(ctx, state);
    } else if (state is LoadingLobbyState) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Center(
        child: Text((state as ErrorLobbyState).error),
      );
    }
  }

  Widget _quickPairing(BuildContext ctx, SuccessLobbyState state) {
    LobbyCubit cubit = BlocProvider.of<LobbyCubit>(ctx);
    List<Widget> buttons = [];
    state.rsp.lobby.pools.forEach((pool) => buttons.add(_quickMatchButton(pool)));
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      childAspectRatio: 1.8,
      children: buttons,
    );
  }

  Widget _quickMatchButton(LobbyPool pool) {
    return OutlinedButton(
      onPressed: () => {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            pool.id,
            style: env.thm.h3TextStyle,
            textAlign: TextAlign.center,
          ),
          Text(
            pool.perf,
            style: env.thm.btnTextStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class LobbyCubit extends Cubit<LobbyState> {
  LobbyCubit() : super(LobbyState.initial()) {
    fetchLobby();
  }
  void fetchLobby() async {
    LilaResult<LobbyRsp> res = await env.lobby.fetch();
    emit(res.object != null ? SuccessLobbyState(res.object!) : ErrorLobbyState(res.message));
    env.user.info().then((res) => {});
  }
}

abstract class LobbyState {
  const LobbyState();
  factory LobbyState.initial() => LoadingLobbyState();
}

class LoadingLobbyState extends LobbyState {}

class ErrorLobbyState extends LobbyState {
  const ErrorLobbyState(this.error);
  final String error;
}

class SuccessLobbyState extends LobbyState {
  final LobbyRsp rsp;
  const SuccessLobbyState(this.rsp);
}
