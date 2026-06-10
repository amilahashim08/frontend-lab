import 'package:go_router/go_router.dart';

import '../../features/auth/auth_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/interview/interview_bank_screen.dart';
import '../../features/interview/interview_category_screen.dart';
import '../../features/interview/interview_question_detail_screen.dart';
import '../../features/interview/interview_hub_screen.dart';
import '../../features/interview/interview_session_screen.dart';
import '../../features/learning/learning_hub_screen.dart';
import '../../features/learning/learning_path_screen.dart';
import '../../features/learning/unit_detail_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/playground/code_playground_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/quiz/quiz_screen.dart';
import '../../features/splash/splash_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/learn',
      builder: (context, state) => const LearningHubScreen(),
    ),
    GoRoute(
      path: '/learn/track/:trackId',
      builder: (_, state) => LearningPathScreen(
        trackId: state.pathParameters['trackId']!,
      ),
    ),
    GoRoute(
      path: '/learn/unit/:unitId',
      builder: (_, state) => UnitDetailScreen(
        unitId: state.pathParameters['unitId']!,
      ),
    ),
    GoRoute(
      path: '/quiz/:unitId',
      builder: (_, state) => QuizScreen(unitId: state.pathParameters['unitId']!),
    ),
    GoRoute(
      path: '/interview',
      builder: (context, state) => const InterviewHubScreen(),
    ),
    GoRoute(
      path: '/interview/bank',
      builder: (context, state) => const InterviewBankScreen(),
    ),
    GoRoute(
      path: '/interview/bank/:categoryId',
      builder: (_, state) => InterviewCategoryScreen(
        categoryId: state.pathParameters['categoryId']!,
      ),
    ),
    GoRoute(
      path: '/interview/question/:questionId',
      builder: (_, state) => InterviewQuestionDetailScreen(
        questionId: state.pathParameters['questionId']!,
      ),
    ),
    GoRoute(
      path: '/interview/session/:trackId',
      builder: (_, state) => InterviewSessionScreen(
        trackId: state.pathParameters['trackId']!,
      ),
    ),
    GoRoute(
      path: '/playground',
      builder: (context, state) => const CodePlaygroundScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
