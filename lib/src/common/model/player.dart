import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dartchess/dartchess.dart';
import 'package:deep_pick/deep_pick.dart';

import 'package:lichess_mobile/src/utils/json.dart';

part 'player.freezed.dart';
part 'player.g.dart';

@Freezed(fromJson: true, toJson: true)
class LightPlayer with _$LightPlayer {
  const factory LightPlayer({
    required Side side,
    required String userId,
    required String name,
    String? title,
  }) = _LightPlayer;

  factory LightPlayer.fromJson(Map<String, dynamic> json) =>
      _$LightPlayerFromJson(json);

  factory LightPlayer.fromPick(RequiredPick pick) {
    return LightPlayer(
      name: pick('name').asStringOrThrow(),
      userId: pick('userId').asStringOrThrow(),
      side: pick('color').asSideOrThrow(),
      title: pick('title').asStringOrNull(),
    );
  }
}
