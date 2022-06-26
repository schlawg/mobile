import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String username,
    required int seenAt,
    required bool? online,
    required int? createdAt,
    required bool? patron,
    required Map<String, int>? playTime,
    required UserProfile? profile,
    required Map<String, UserPerf>? perfs,
    required UserPrefs? prefs,
    required List<dynamic>? nowPlaying,
    required int? nbChallenges,
    required String? sessionId, // trust this one, or the one in the header??
  }) = _User;
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String? location,
    required String? country,
    required String? bio,
    required String? firstName,
    required String? lastName,
    required int? fideRating,
    required int? uscfRating,
    required int? ecfRating,
    required int? rcfRating,
    required int? cfcRating,
    required int? dsbRating,
    required String? links,
  }) = _UserProfile;
  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
}

@freezed
class UserPerf with _$UserPerf {
  const factory UserPerf({
    required int games,
    required int rating,
    required int rd,
    required int prog,
  }) = _UserPerf;
  factory UserPerf.fromJson(Map<String, dynamic> json) => _$UserPerfFromJson(json);
}

@freezed
class UserPrefs with _$UserPrefs {
  const factory UserPrefs({
    required bool dark,
    required bool transp,
    required String bgImg,
    required bool is3d,
    required String theme,
    required String pieceSet,
    required String theme3d,
    required String pieceSet3d,
    required String soundSet,
    required int blindfold,
    required int autoQueen,
    required int autoThreefold,
    required int takeback,
    required int moretime,
    required int clockTenths,
    required bool clockBar,
    required bool clockSound,
    required bool premove,
    required int animation,
    required bool captured,
    required bool follow,
    required bool highlight,
    required bool destination,
    required int coords,
    required int replay,
    required int challenge,
    required int message,
    required int submitMove,
    required int confirmResign,
    required bool mention,
    required bool corresEmailNotif,
    required int insightShare,
    required int keyboardMove,
    required int zen,
    required int moveEvent,
    required int rookCastle,
  }) = _UserPrefs;
  factory UserPrefs.fromJson(Map<String, dynamic> json) => _$UserPrefsFromJson(json);
}
