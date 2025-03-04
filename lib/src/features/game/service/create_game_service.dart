import 'package:logging/logging.dart';
import 'package:dartchess/dartchess.dart' hide Tuple2;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:lichess_mobile/src/common/errors.dart';
import 'package:lichess_mobile/src/features/user/model/user.dart';
import '../data/play_preferences.dart';
import '../data/challenge_repository.dart';
import '../data/challenge_request.dart';
import '../data/game_repository.dart';
import '../data/api_event.dart';
import '../model/computer_opponent.dart';
import '../model/game.dart';

class CreateGameService {
  const CreateGameService(this._log, {required this.ref});

  final Ref ref;
  final Logger _log;

  TaskEither<IOError, PlayableGame> aiGameTask(User account, {Side? side}) {
    final challengeRepo = ref.read(challengeRepositoryProvider);
    final opponent = ref.read(computerOpponentPrefProvider);
    final maiaStrength = ref.read(maiaStrengthProvider);
    final timeControl = ref.read(timeControlPrefProvider).value;
    final level = ref.read(stockfishLevelProvider);

    final challengeRequest = ChallengeRequest(
      time: Duration(minutes: timeControl.time),
      side: side,
      increment: Duration(seconds: timeControl.increment),
    );
    final createChallengeTask = opponent == ComputerOpponent.stockfish
        ? challengeRepo.challengeAITask(
            AiChallengeRequest(level: level, challenge: challengeRequest))
        : challengeRepo.challengeTask(maiaStrength.name, challengeRequest);

    return createChallengeTask.andThen(() => _waitForGameStart(account));
  }

  TaskEither<IOError, PlayableGame> _waitForGameStart(User account) {
    return TaskEither<IOError, PlayableGame>.tryCatch(
      () async {
        final gameRepo = ref.read(gameRepositoryProvider);
        final stream = gameRepo.events().timeout(const Duration(seconds: 15),
            onTimeout: (sink) => sink.close());

        final startEvent = await stream.firstWhere(
            (event) =>
                event.type == GameEventLifecycle.start && event.boardCompat,
            orElse: () {
          throw Exception('Could not create game.');
        });

        final player = Player(
          id: account.id,
          name: account.username,
          rating: account.perfs[startEvent.perf]!.rating,
        );
        final opponent = Player(
            id: startEvent.opponent.id,
            name: startEvent.opponent.username,
            rating: startEvent.opponent.rating);
        return PlayableGame(
          id: startEvent.gameId,
          initialFen: startEvent.fen,
          speed: startEvent.speed,
          orientation: startEvent.side,
          rated: startEvent.rated,
          white: startEvent.side == Side.white ? player : opponent,
          black: startEvent.side == Side.white ? opponent : player,
          variant: Variant.standard,
        );
      },
      (error, trace) {
        _log.severe('Request error', error, trace);
        return GenericError(trace);
      },
    );
  }
}

final createGameServiceProvider = Provider<CreateGameService>((ref) {
  return CreateGameService(Logger('CreateGameService'), ref: ref);
});
