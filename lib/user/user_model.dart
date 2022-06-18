import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String username,
    required bool online,
    //this.createdAt,
    //this.seenAt,
    required Map<String, int>? playTime,
    required List<String>? nowPlaying,
    required String? sessionId,
    required UserProfile? profile,
    required Map<String, UserPerf>? perfs,
  }) = _User;
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String? location,
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
