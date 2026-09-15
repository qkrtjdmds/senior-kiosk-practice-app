import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import '../features/home/home_page.dart';
import '../features/progress/progress_page.dart';
import '../features/learning/cafe_complete_page.dart';
import '../features/learning/cafe_mission_page.dart';
import '../features/learning/cafe_practice_page.dart';
import '../features/learning/cafe_start_page.dart';
import '../features/learning/cafe_step_four_page.dart';
import '../features/learning/cafe_step_three_page.dart';
import '../features/learning/cafe_step_two_page.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.progress,
      builder: (context, state) => const ProgressPage(),
    ),
    GoRoute(
      path: AppRoutes.cafeStart,
      builder: (context, state) => const CafeStartPage(),
    ),
    GoRoute(
      path: AppRoutes.cafeMission,
      builder: (context, state) => const CafeMissionPage(),
    ),
    GoRoute(
      path: AppRoutes.cafeStepOne,
      builder: (context, state) => const CafePracticePage(),
    ),
    GoRoute(
      path: AppRoutes.cafeStepTwo,
      builder: (context, state) => const CafeStepTwoPage(),
    ),
    GoRoute(
      path: AppRoutes.cafeStepThree,
      builder: (context, state) => const CafeStepThreePage(),
    ),
    GoRoute(
      path: AppRoutes.cafeStepFour,
      builder: (context, state) => const CafeStepFourPage(),
    ),
    GoRoute(
      path: AppRoutes.cafeComplete,
      builder: (context, state) => const CafeCompletePage(),
    ),
  ],
);
