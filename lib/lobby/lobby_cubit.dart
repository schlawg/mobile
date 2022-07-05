import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/env.dart';
import 'lobby_model.dart';
import '/challenge/challenge_model.dart';
import '/user/user_repo.dart';
import '/services/maybe.dart';
import '/services/net/lila_repo.dart';
import '/services/net/ws_client.dart';

class LobbyCubit extends Cubit<LobbyState> with WsClient {
  LobbyCubit(
    this._userRepo,
    this._lilaRepo,
  ) : super(LobbyState.initial()) {
    _userRepo.addListener(_onSessionChange);
    _fetchLobby();

    addWsHandlers({
      'had': _onHad,
      'hrm': _onHrm,
      'hooks': _onHooks,
      'hli': _onHli,
      'reload_seeks': _onReloadSeeks,
      'reload_timeline': _onReloadTimeline,
      'fen': _onFen,
      'featured': _onFeatured,
      'redirect': _onRedirect,
    });
    wsConnect();
  }
  final UserRepo _userRepo;
  final LilaRepo _lilaRepo;

  @override
  get wsPath => '/lobby/socket';

  @override
  void onWsMsg(Map<String, dynamic> msg) {
    debugPrint(json.encode(msg));
  }

  void quickMatch(BuildContext ctx, String clock, String perf) {
    final perfMap = _userRepo.me?.perfs ?? {};
    final rating = perfMap[perf]?.rating ?? 1500;
    final range = '${rating - 500}-${rating + 500}';
    Maybe.repeat(interval: 10 * 1000, (_) => wsSend(t: "poolIn", d: {"id": clock, "range": range}));
    //emit(PoolInLobbyState(clock));
  }

  void playWithFriend() async {
    debugPrint('here wwe are!');
    const cfg =
        Setup(variant: 1, timeMode: 1, days: 2, time: 5, increment: 0, color: "random", mode: 0);
    final LilaResult<Challenge> rsp =
        await env.lila.post('/setup/friend', body: cfg.toJson(), as: Challenge.fromJson);
    debugPrint('id = ${rsp.object!.id}');
  }
/*{"challenge":{"id":"p3vkFeyN","url":"http://192.168.1.7:9662/p3vkFeyN",
"status":"created","challenger":null,"destUser":null,
"variant":{"key":"standard","name":"Standard","short":"Std"},"rated":false,
"speed":"blitz","timeControl":{"type":"clock","limit":300,"increment":0,
"show":"5+0"},"color":"random","finalColor":"black",
"perf":{"icon":"","name":"Blitz"},"direction":"out"},"socketVersion":0}
*/

  void _onReloadTimeline() {
    debugPrint('got a reload timeline');
    /*(void) xhr.text('/timeline').then(html => {
          $('.timeline').html(html);
          lichess.contentLoaded();*/
  }

  void _onFeatured(Map<String, dynamic> obj) {
    debugPrint('got a featured');
    /*featured(o: { html: string }) {
        $('.lobby__tv').html(o.html);
        lichess.contentLoaded();*/
  }

  void _onRedirect(Map<String, dynamic> obj) {
    debugPrint('got a redirect');
    /*redirect(e: RedirectTo) {
        lobbyCtrl.leavePool();
        lobbyCtrl.setRedirecting();
        lichess.redirect(e);*/
  }

  void _onFen(Map<String, dynamic> obj) {
    debugPrint('got a fen');
    /*(e: any) {
        lobbyCtrl.gameActivity(e.id);*/
  }

  void _onHad(Map<String, dynamic> obj) {
    debugPrint('got a had');
    /*hook: Hook) {
        hookRepo.add(ctrl, hook);
        if (hook.action === 'cancel') ctrl.flushHooks(true);
        ctrl.redraw();*/
  }

  void _onHrm(Map<String, dynamic> obj) {
    debugPrint('got a hrm');
    /*ids: string)
        ids.match(/.{8}/g)!.forEach(function (id) {
          hookRepo.remove(ctrl, id);
        });
        ctrl.redraw();*/
  }

  void _onHooks(Map<String, dynamic> obj) {
    debugPrint('got a hooks');
    /*hooks: Hook[]) {
        hookRepo.setAll(ctrl, hooks);
        ctrl.flushHooks(true);
        ctrl.redraw();*/
  }

  void _onHli(Map<String, dynamic> obj) {
    debugPrint('got a hli');
    /*ids: string) {
        hookRepo.syncIds(ctrl, ids.match(/.{8}/g) || []);
        ctrl.redraw();*/
  }

  void _onReloadSeeks() {
    debugPrint('got a reload_seeks');
    /*reload_seeks() {
        if (ctrl.tab === 'seeks') xhr.seeks().then(ctrl.setSeeks);*/
  }

  Future<bool> _fetchLobby() async {
    final res = await _lilaRepo.get("/", as: LobbyRsp.fromJson);
    if (res.ok) {
      emit(res.object != null ? SuccessLobbyState(res.object!) : ErrorLobbyState(res.message));
      return true;
    } else {
      emit(const OfflineLobbyState());
      return false;
    }
  }

  void _onSessionChange() async {
    if (await _fetchLobby()) {
      debugPrint('gogogogogogogogogogogo ${env.wsOrigin}');
      wsSend(t: 'following_onlines');
    } else {
      debugPrint('oh noes mr bill'); // we're offline
    }
  }

  @override
  Future<void> close() async {
    _userRepo.removeListener(_onSessionChange);
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

class OfflineLobbyState extends LobbyState {
  const OfflineLobbyState();
}

class PoolInLobbyState extends LobbyState {
  const PoolInLobbyState(this.pool) : super();
  final String pool;
}
