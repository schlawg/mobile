import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'lobby_model.dart';
import '/user/user_repo.dart';
import '/services/net/lila_repo.dart';
import 'lobby_cubit.dart';
import '/app/app_scaffold.dart';
import '/app/ui.dart';

/* 
 at standard zoom, basic layout strategy counts the number of "views" with
 width of a board or a board sized view such as chat or move list - essentially
 the number of logical pixels in a smallish phone's screen width), and
 decide how many of those views it can fit horizontally given the current
 orientation.  Each page element also has a bias (focus bias wants to be
 horizontally centered but prefers text direction when compared to another element)
 and a priority, which roughly determines overall list order from left to right,
 then next row, then next.  priority can be overruled by focus bias on a given row.
 The elements are then rendered in their assigned grid squares by the page container
 in such a way as to favor balance, i.e. 2/2 (a 2x2 grid square with horizontal padding) is
 preferable to 3/1 (a 3x2 grid square with only 1 element on the 2nd row).  zooming focuses
 on subgrids, max zoom is 1x1 like fullscreen board view.
 probably will turn out terrible but lets go with it for now.
*/

class LobbyPage extends StatelessWidget {
  const LobbyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
//      body: SafeArea(child: OrientationBuilder(builder: (context, o) {
//        return o == Orientation.landscape ? _landscapeLayout(context) : _portraitLayout(context);
      body: ConstrainedWidthColumn(
        [
          BlocProvider(
            create: (_) => LobbyCubit(context.watch<UserRepo>(), context.read<LilaRepo>()),
            child: BlocBuilder<LobbyCubit, LobbyState>(builder: _onState),
          ),
        ],
      ),
    );
  }

  Widget _onState(BuildContext context, LobbyState state) {
    if (state is SuccessLobbyState) {
      return _mainView(context, state);
    } else if (state is LoadingLobbyState) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is ErrorLobbyState) {
      return Center(
        child: Text(state.error),
      );
    } else {
      return Container();
    }
  }

  Widget _oppoGameList(BuildContext context) {
    return ListView();
  }

  Widget _oppoGame(
    BuildContext context, {
    required String creator,
    required String color,
    required String timeControl,
    required String rating,
    required bool rated,
  }) {
    return Row();
  }

  Widget _mainView(BuildContext context, SuccessLobbyState state) {
    return ConstrainedWidthColumn([
      _quickPairing(context, state),
      const SizedBox(height: 32),
      TextButton(
        onPressed: () => context.read<LobbyCubit>().playWithFriend,
        child: const Text("Play with a friend", style: UI.size22, textAlign: TextAlign.center),
      ),
    ]);
  }

  Widget _quickPairing(BuildContext context, SuccessLobbyState state) {
    List<Widget> buttons = [];
    state.rsp.lobby.pools.forEach((pool) => buttons.add(_quickMatchButton(context, pool)));
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      childAspectRatio: 1.8,
      children: buttons,
    );
  }

  Widget _quickMatchButton(BuildContext context, LobbyPool pool) {
    return OutlinedButton(
      onPressed: () => context.read<LobbyCubit>().quickMatch(context, pool.id, pool.perf),
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
