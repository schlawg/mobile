import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/env.dart';
import 'package:mobile/services/net/lila_repo.dart';
import 'lobby_model.dart';
import '/services/net/ws_client.dart';
import '/app/app_scaffold.dart';
import '/app/ui.dart';

// at standard zoom, basic layout strategy counts the number of "views" with
// width of a board or a board sized view such as chat or move list - essentially
// the number of logical pixels in a smallish phone's screen width), and
// decide how many of those views it can fit horizontally given the current
// orientation.  Each page element also has a bias (focus bias wants to be
// horizontally centered but prefers left over right when compared to another element)
// and a priority, which roughly determines overall list order from left to right,
// then next row, then next.  priority can be overruled by focus bias on a given row.
// The elements are then rendered in their assigned grid squares by the page container
// in such a way as to favor balance, i.e. 2/2 (a 2x2 grid square with horizontal padding) is
// preferable to 3/1 (a 3x2 grid square with only 1 element on the 2nd row).  zooming focuses
// on subgrids, max zoom is 1x1 like fullscreen board view.
// probably will turn out terrible but lets go with it for now.
class LobbyPage extends StatelessWidget {
  const LobbyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(child: OrientationBuilder(builder: (context, o) {
        return o == Orientation.landscape ? _landscapeLayout(context) : _portraitLayout(context);
      })),
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

  Widget _landscapeLayout(BuildContext ctx) {
    return _portraitLayout(ctx);
  }

  Widget _portraitLayout(BuildContext ctx) {
    return ConstrainedWidthColumn(
      [
        BlocProvider(
          create: (_) => LobbyCubit(),
          child: BlocBuilder<LobbyCubit, LobbyState>(builder: _onState),
        ),
      ],
    );
  }

  Widget _oppoGameList(BuildContext ctx) {
    return ListView();
  }

  Widget _oppoGame(
    BuildContext ctx, {
    required String creator,
    required String color,
    required String timeControl,
    required String rating,
    required bool rated,
  }) {
    return Row();
  }

  Widget _quickPairing(BuildContext ctx, SuccessLobbyState state) {
    List<Widget> buttons = [];
    state.rsp.lobby.pools.forEach((pool) => buttons.add(_quickMatchButton(ctx, pool)));
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      childAspectRatio: 1.8,
      children: buttons,
    );
  }

  Widget _quickMatchButton(BuildContext ctx, LobbyPool pool) {
    return OutlinedButton(
      onPressed: () => BlocProvider.of<LobbyCubit>(ctx)._quickMatch(ctx, pool.id, pool.perf),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            pool.id,
            style: UI.size24,
            textAlign: TextAlign.center,
          ),
          Text(
            pool.perf,
            style: UI.size20,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class LobbyCubit extends Cubit<LobbyState> with WsClient {
  LobbyCubit() : super(LobbyState.initial()) {
    env.user.addListener(_onSession);
    fetchLobby();
  }
  @override
  get wsPath => "/lobby/socket";

  @override
  void onWsMsg(Map<String, dynamic> msg) {
    debugPrint(json.encode(msg));
  }

  void fetchLobby() async {
    final res = await env.lobby.fetch();
    emit(res.object != null ? SuccessLobbyState(res.object!) : ErrorLobbyState(res.message));
  }

  void _quickMatch(BuildContext ctx, String clock, String perf) {
    emit(LoadingLobbyState());
  }

  void _onSession() {
    if (env.user.loggedIn) {
      debugPrint('gogogogogogogogogogogo ${env.wsOrigin}');
      env.ws.connect(this).then((_) {
        wsSend({'t': 'following_onlines'});
      });
    } else {
      debugPrint('oh noes mr bill');
    }
  }

  @override
  Future<void> close() async {
    env.user.removeListener(_onSession);
    super.close();
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
