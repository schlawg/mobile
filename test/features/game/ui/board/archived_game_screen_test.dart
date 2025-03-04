import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:dartchess/dartchess.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chessground/chessground.dart' as cg;

import 'package:lichess_mobile/src/constants.dart';
import 'package:lichess_mobile/src/widgets/player.dart';
import 'package:lichess_mobile/src/widgets/countdown_clock.dart';
import 'package:lichess_mobile/src/widgets/game_board_layout.dart';
import 'package:lichess_mobile/src/common/models.dart';
import 'package:lichess_mobile/src/common/http.dart';
import 'package:lichess_mobile/src/common/sound.dart';
import 'package:lichess_mobile/src/common/shared_preferences.dart';
import 'package:lichess_mobile/src/features/game/ui/board/archived_game_screen.dart';
import 'package:lichess_mobile/src/features/game/model/game.dart' as game;
import 'package:lichess_mobile/src/features/game/model/game_status.dart';
import '../../../auth/data/fake_auth_repository.dart';
import '../../../../utils.dart';

class MockClient extends Mock implements http.Client {}

class MockLogger extends Mock implements Logger {}

class MockSoundService extends Mock implements SoundService {}

void main() {
  final mockLogger = MockLogger();
  final mockClient = MockClient();
  final mockSoundService = MockSoundService();

  setUpAll(() {
    when(
      () => mockClient.get(Uri.parse('$kLichessHost/game/export/qVChCOTc'),
          headers: any(
              named: 'headers',
              that: sameHeaders({'Accept': 'application/json'}))),
    ).thenAnswer((_) => mockResponse(gameResponse, 200));
    registerFallbackValue(http.Request('GET', Uri.parse('http://api.test')));
  });

  group('ArchivedGameScreen', () {
    testWidgets('displays game data and last fen immediately, then moves',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();

      final app = await buildTestApp(
        tester,
        home: Consumer(builder: (context, ref, _) {
          return ArchivedGameScreen(gameData: gameData, account: fakeUser);
        }),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            apiClientProvider
                .overrideWithValue(ApiClient(mockLogger, mockClient)),
            soundServiceProvider.overrideWithValue(mockSoundService),
          ],
          child: app,
        ),
      );

      // data shown immediately
      expect(find.byType(cg.Board), findsOneWidget);
      expect(find.byType(cg.PieceWidget), findsNWidgets(25));
      expect(find.widgetWithText(Player, 'veloce'), findsOneWidget);
      expect(find.widgetWithText(Player, 'Stockfish'), findsOneWidget);
      expect(find.widgetWithText(CountdownClock, '3:00'), findsNWidgets(2));

      // cannot interact with board
      expect(
          tester.widget<cg.Board>(find.byType(cg.Board)).data.interactableSide,
          cg.InteractableSide.none);

      // moves are not loaded
      expect(find.byType(MoveList), findsNothing);
      expect(
          tester
              .widget<IconButton>(find.byKey(const ValueKey('cursor-back')))
              .onPressed,
          isNull);

      // wait for game steps loading
      await tester.pump(const Duration(milliseconds: 100));
      // wait for move list ensureVisible animation to finish
      await tester.pumpAndSettle();

      // same info still displayed
      expect(find.byType(cg.Board), findsOneWidget);
      expect(find.byType(cg.PieceWidget), findsNWidgets(25));
      expect(find.widgetWithText(Player, 'veloce'), findsOneWidget);
      expect(find.widgetWithText(Player, 'Stockfish'), findsOneWidget);

      // except for the clocks
      expect(find.widgetWithText(CountdownClock, '1:46'), findsNWidgets(1));
      expect(find.widgetWithText(CountdownClock, '0:46'), findsNWidgets(1));

      // moves are loaded
      expect(find.byType(MoveList), findsOneWidget);
      expect(
          tester
              .widget<IconButton>(find.byKey(const ValueKey('cursor-back')))
              .onPressed,
          isNotNull);
    }, variant: kPlatformVariant);
  });
}

// --

const gameResponse = '''
{"id":"qVChCOTc","rated":false,"variant":"standard","speed":"blitz","perf":"blitz","createdAt":1673443822389,"lastMoveAt":1673444036416,"status":"mate","players":{"white":{"aiLevel":1},"black":{"user":{"name":"veloce","patron":true,"id":"veloce"},"rating":1435,"provisional":true}},"winner":"black","opening":{"eco":"C20","name":"King's Pawn Game: Wayward Queen Attack, Kiddie Countergambit","ply":4},"moves":"e4 e5 Qh5 Nf6 Qxe5+ Be7 b3 d6 Qb5+ Bd7 Qxb7 Nc6 Ba3 Rb8 Qa6 Nxe4 Bb2 O-O Nc3 Nb4 Nf3 Nxa6 Nd5 Nb4 Nxe7+ Qxe7 Nd4 Qf6 f4 Qe7 Ke2 Ng3+ Kd1 Nxh1 Bc4 Nf2+ Kc1 Qe1#","clocks":[18003,18003,17915,17627,17771,16691,17667,16243,17475,15459,17355,14779,17155,13795,16915,13267,14771,11955,14451,10995,14339,10203,13899,9099,12427,8379,12003,7547,11787,6691,11355,6091,11147,5763,10851,5099,10635,4657],"clock":{"initial":180,"increment":0,"totalTime":180}}
''';

final gameData = game.ArchivedGameData(
  id: const GameId('qVChCOTc'),
  rated: false,
  speed: game.Speed.blitz,
  perf: Perf.blitz,
  createdAt: DateTime.parse('2023-01-11 14:30:22.389'),
  lastMoveAt: DateTime.parse('2023-01-11 14:33:56.416'),
  status: GameStatus.mate,
  white: const game.Player(name: 'Stockfish', aiLevel: 1),
  black: const game.Player(
    id: 'veloce',
    name: 'veloce',
    rating: 1435,
    patron: true,
  ),
  variant: game.Variant.standard,
  lastFen: '1r3rk1/p1pb1ppp/3p4/8/1nBN1P2/1P6/PBPP1nPP/R1K1q3 w - - 4 1',
  winner: Side.black,
  clock: const game.ClockData(
    initial: Duration(minutes: 3),
    increment: Duration.zero,
  ),
);
