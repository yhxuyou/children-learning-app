import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/chinese_learning/chinese_learning_screen.dart';
import '../screens/chinese_learning/chinese_detail_screen.dart';
import '../screens/english_learning/english_learning_screen.dart';
import '../screens/english_learning/english_detail_screen.dart';
import '../screens/games/games_screen.dart';
import '../screens/games/game_play_screen.dart';
import '../screens/parent/parent_center_screen.dart';
import '../screens/ai_companion/ai_companion_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/chinese',
      builder: (context, state) => const ChineseLearningScreen(),
    ),
    GoRoute(
      path: '/chinese/:char',
      builder: (context, state) => ChineseDetailScreen(
        character: state.pathParameters['char']!,
      ),
    ),
    GoRoute(
      path: '/english',
      builder: (context, state) => const EnglishLearningScreen(),
    ),
    GoRoute(
      path: '/english/:word',
      builder: (context, state) => EnglishDetailScreen(
        word: state.pathParameters['word']!,
      ),
    ),
    GoRoute(
      path: '/games',
      builder: (context, state) => const GamesScreen(),
    ),
    GoRoute(
      path: '/games/:gameId',
      builder: (context, state) => GamePlayScreen(
        gameId: state.pathParameters['gameId']!,
      ),
    ),
    GoRoute(
      path: '/parent',
      builder: (context, state) => const ParentCenterScreen(),
    ),
    GoRoute(
      path: '/ai-companion',
      builder: (context, state) => const AiCompanionScreen(),
    ),
  ],
);
