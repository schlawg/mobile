import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge_model.freezed.dart';
part 'challenge_model.g.dart';

@freezed
class Setup with _$Setup {
  const factory Setup({
    //{"variant":"1","timeMode":"1","days":"2","time":"5","increment":"0","color":"random","mode":"0"}

    int? variant,
    int? timeMode,
    int? days,
    int? time,
    int? increment,
    String? color,
    int? mode,
    String? fen,
    String? ratingRange,
    bool? rated,
  }) = _Setup;

  factory Setup.fromJson(Map<String, Object?> json) => _$SetupFromJson(json);
}

@freezed
class Perf with _$Perf {
  const factory Perf({
    String? icon,
    String? name,
    String? direction, // ?
  }) = _Perf;
  factory Perf.fromJson(Map<String, Object?> json) => _$PerfFromJson(json);
}

@freezed
class TimeControl with _$TimeControl {
  const factory TimeControl({
    String? type,
    int? limit,
    int? increment,
    String? show,
    String? color,
    String? finalColor,
    Perf? perf,
    int? socketVersion,
  }) = _TimeControl;
  factory TimeControl.fromJson(Map<String, Object?> json) => _$TimeControlFromJson(json);
}

@freezed
class Challenge with _$Challenge {
  const factory Challenge(
      {String? id,
      String? url,
      String? created,
      String? challenger,
      String? destUser,
      bool? rated,
      String? speed,
      TimeControl? timeControl,
      Variant? variant}) = _Challenge;

  factory Challenge.fromJson(Map<String, Object?> json) => _$ChallengeFromJson(json);
}

@freezed
class Variant with _$Variant {
  const factory Variant({
    String? key,
    String? name,
    String? short,
  }) = _Variant;
  factory Variant.fromJson(Map<String, Object?> json) => _$VariantFromJson(json);
}

/* ai
      "variant"   -> aiVariants,
      "timeMode"  -> timeMode,
      "time"      -> time,
      "increment" -> increment,
      "days"      -> days,
      "level"     -> level,
      "color"     -> color,
      "fen"       -> fenField
-- hook
       "variant"     -> variantWithVariants,
        "timeMode"    -> timeMode,
        "time"        -> time,
        "increment"   -> increment,
        "days"        -> days,
        "mode"        -> mode(ctx.isAuth),
        "ratingRange" -> optional(ratingRange),
        "color"       -> color
 -- friend
        "variant"   -> variantWithFenAndVariants,
        "timeMode"  -> timeMode,
        "time"      -> time,
        "increment" -> increment,
        "days"      -> days,
        "mode"      -> mode(withRated = ctx.isAuth),
        "color"     -> color,
        "fen"       -> fenField
 -- boardApiHook
     "time"        -> optional(time),
      "increment"   -> optional(increment),
      "days"        -> optional(days),
      "variant"     -> optional(boardApiVariantKeys),
      "rated"       -> optional(boolean),
      "color"       -> optional(color),
      "ratingRange" -> optional(ratingRange)
 -- boardApiSeek
       "time"        -> time,
      "increment"   -> increment,
      "variant"     -> optional(boardApiVariantKeys),
      "rated"       -> optional(boolean),
      "color"       -> optional(color),
      "ratingRange" -> optional(ratingRange)
 
 ---------------------
   val variants       = List(chess.variant.Standard.id, chess.variant.Chess960.id)
  val variantDefault = chess.variant.Standard

  val variantsWithFen = variants :+ FromPosition.id
  val aiVariants = variants :+
    chess.variant.Crazyhouse.id :+
    chess.variant.KingOfTheHill.id :+
    chess.variant.ThreeCheck.id :+
    chess.variant.Antichess.id :+
    chess.variant.Atomic.id :+
    chess.variant.Horde.id :+
    chess.variant.RacingKings.id :+
    chess.variant.FromPosition.id
  val variantsWithVariants =
    variants :+
      chess.variant.Crazyhouse.id :+
      chess.variant.KingOfTheHill.id :+
      chess.variant.ThreeCheck.id :+
      chess.variant.Antichess.id :+
      chess.variant.Atomic.id :+
      chess.variant.Horde.id :+
      chess.variant.RacingKings.id
  val variantsWithFenAndVariants =
    variantsWithVariants :+ FromPosition.id

  val speeds = Speed.all.map(_.id)

  private val timeMin             = 0
  private val timeMax             = 180
  private val acceptableFractions = Set(1 / 4d, 1 / 2d, 3 / 4d, 3 / 2d)
  def validateTime(t: Double) =
    t >= timeMin && t <= timeMax && (t.isWhole || acceptableFractions(t))

  private val incrementMin      = 0
  private val incrementMax      = 180
  def validateIncrement(i: Int) = i >= incrementMin && i <= incrementMax
*/

/*{"challenge":{"id":"p3vkFeyN","url":"http://192.168.1.7:9662/p3vkFeyN",
"status":"created","challenger":null,"destUser":null,
"variant":{"key":"standard","name":"Standard","short":"Std"},
"rated":false,"speed":"blitz","timeControl":
{ "type":"clock","limit":300,"increment":0,
  "show":"5+0"},"color":"random","finalColor":"black",
  "perf":
  { "icon":"",
    "name":"Blitz"},
    "direction":"out"
  },
  "socketVersion":0
}
*/
