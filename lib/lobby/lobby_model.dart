import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'lobby_model.freezed.dart';
part 'lobby_model.g.dart';

@freezed
class LobbyRsp with _$LobbyRsp {
  const factory LobbyRsp({
    required Lobby lobby,
    required LobbyDomain assets,
  }) = _LobbyRsp;

  factory LobbyRsp.fromJson(Map<String, Object?> json) => _$LobbyRspFromJson(json);
}

@freezed
class Lobby with _$Lobby {
  const factory Lobby({
    required int version,
    required List<LobbyPool> pools,
  }) = _Lobby;
  factory Lobby.fromJson(Map<String, Object?> json) => _$LobbyFromJson(json);
}

@freezed
class LobbyPool with _$LobbyPool {
  const factory LobbyPool({
    required String id,
    required int lim, // time minutes
    required int inc, // increment seconds
    required String perf,
  }) = _LobbyPool;
  factory LobbyPool.fromJson(Map<String, Object?> json) => _$LobbyPoolFromJson(json);
}

@freezed
class LobbyDomain with _$LobbyDomain {
  const factory LobbyDomain({
    required String domain,
  }) = _LobbyDomain;
  factory LobbyDomain.fromJson(Map<String, Object?> json) => _$LobbyDomainFromJson(json);
}
