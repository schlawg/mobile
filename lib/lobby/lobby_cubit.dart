import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/env.dart';
import 'lobby_model.dart';
import '/user/user_repo.dart';
import '/services/net/lila_repo.dart';
import '/services/net/ws_client.dart';

class LobbyCubit extends Cubit<LobbyState> with WsClient {
  LobbyCubit(
    this._userRepo,
    this._lilaRepo,
    /*this._wsRepo*/
  ) : super(LobbyState.initial()) {
    _userRepo.addListener(_onSessionChange);
    _fetchLobby();
  }
  final UserRepo _userRepo;
  final LilaRepo _lilaRepo;
  //final WsRepo _wsRepo;

  @override
  get wsPath => "/lobby/socket";

  @override
  void onWsMsg(Map<String, dynamic> msg) {
    debugPrint(json.encode(msg));
  }

  void quickMatch(BuildContext ctx, String clock, String perf) {
    emit(LoadingLobbyState());
  }

  Future<bool> _fetchLobby() async {
    final res = await _lilaRepo.get("/", rspFactory: LobbyRsp.fromJson);
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
      wsConnect().then((_) {
        wsSend({'t': 'following_onlines'});
      });
    } else {
      debugPrint('oh noes mr bill');
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
