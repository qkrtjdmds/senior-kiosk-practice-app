import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import '../features/home/home_page.dart';
import '../features/progress/progress_page.dart';
import '../features/settings/accessibility_settings_page.dart';
import '../features/tabs/main_tab_scaffold.dart';
import '../features/tabs/mission_tab_page.dart';
import '../features/tabs/practice_tab_page.dart';
import '../features/learning/cafe_complete_page.dart';
import '../features/learning/cafe_mission_page.dart';
import '../features/learning/cafe_practice_page.dart';
import '../features/learning/cafe_start_page.dart';
import '../features/learning/cafe_step_four_page.dart';
import '../features/learning/cafe_step_three_page.dart';
import '../features/learning/cafe_step_two_page.dart';
import '../features/hospital/hospital_complete_page.dart';
import '../features/hospital/hospital_mission_page.dart';
import '../features/hospital/hospital_start_page.dart';
import '../features/hospital/hospital_step_four_page.dart';
import '../features/hospital/hospital_step_one_page.dart';
import '../features/hospital/hospital_step_three_page.dart';
import '../features/hospital/hospital_step_two_page.dart';
import '../features/photo/photo_complete_page.dart';
import '../features/photo/photo_mission_page.dart';
import '../features/photo/photo_start_page.dart';
import '../features/photo/photo_step_four_page.dart';
import '../features/photo/photo_step_one_page.dart';
import '../features/photo/photo_step_three_page.dart';
import '../features/photo/photo_step_two_page.dart';
import '../features/train/train_complete_page.dart';
import '../features/train/train_mission_page.dart';
import '../features/train/train_start_page.dart';
import '../features/train/train_step_five_page.dart';
import '../features/train/train_step_four_page.dart';
import '../features/train/train_step_one_page.dart';
import '../features/train/train_step_three_page.dart';
import '../features/train/train_step_two_page.dart';
import '../features/hamburger/hamburger_complete_page.dart';
import '../features/hamburger/hamburger_mission_page.dart';
import '../features/hamburger/hamburger_practice_page.dart';
import '../features/hamburger/hamburger_start_page.dart';
import '../features/atm/atm_complete_page.dart';
import '../features/atm/atm_mission_page.dart';
import '../features/atm/atm_practice_page.dart';
import '../features/atm/atm_start_page.dart';
import '../features/civil_document/civil_document_complete_page.dart';
import '../features/civil_document/civil_document_mission_page.dart';
import '../features/civil_document/civil_document_practice_page.dart';
import '../features/civil_document/civil_document_start_page.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  errorBuilder: (context, state) => const _RouteNotFoundPage(),
  routes: [
    ShellRoute(
      builder: (context, state, child) =>
          MainTabScaffold(location: state.uri.path, child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: AppRoutes.practice,
          builder: (context, state) => const PracticeTabPage(),
        ),
        GoRoute(
          path: AppRoutes.missions,
          builder: (context, state) => const MissionTabPage(),
        ),
        GoRoute(
          path: AppRoutes.progress,
          builder: (context, state) => const ProgressPage(isTabPage: true),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.accessibilitySettings,
      builder: (context, state) => const AccessibilitySettingsPage(),
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
    GoRoute(
      path: AppRoutes.hospitalStart,
      builder: (context, state) => const HospitalStartPage(),
    ),
    GoRoute(
      path: AppRoutes.hospitalMission,
      builder: (context, state) => const HospitalMissionPage(),
    ),
    GoRoute(
      path: AppRoutes.hospitalStepOne,
      builder: (context, state) => const HospitalStepOnePage(),
    ),
    GoRoute(
      path: AppRoutes.hospitalStepTwo,
      builder: (context, state) => const HospitalStepTwoPage(),
    ),
    GoRoute(
      path: AppRoutes.hospitalStepThree,
      builder: (context, state) => const HospitalStepThreePage(),
    ),
    GoRoute(
      path: AppRoutes.hospitalStepFour,
      builder: (context, state) => const HospitalStepFourPage(),
    ),
    GoRoute(
      path: AppRoutes.hospitalComplete,
      builder: (context, state) => const HospitalCompletePage(),
    ),
    GoRoute(
      path: AppRoutes.photoStart,
      builder: (context, state) => const PhotoStartPage(),
    ),
    GoRoute(
      path: AppRoutes.photoMission,
      builder: (context, state) => const PhotoMissionPage(),
    ),
    GoRoute(
      path: AppRoutes.photoStepOne,
      builder: (context, state) => const PhotoStepOnePage(),
    ),
    GoRoute(
      path: AppRoutes.photoStepTwo,
      builder: (context, state) => const PhotoStepTwoPage(),
    ),
    GoRoute(
      path: AppRoutes.photoStepThree,
      builder: (context, state) => const PhotoStepThreePage(),
    ),
    GoRoute(
      path: AppRoutes.photoStepFour,
      builder: (context, state) => const PhotoStepFourPage(),
    ),
    GoRoute(
      path: AppRoutes.photoComplete,
      builder: (context, state) => const PhotoCompletePage(),
    ),
    GoRoute(
      path: AppRoutes.trainStart,
      builder: (context, state) => const TrainStartPage(),
    ),
    GoRoute(
      path: AppRoutes.trainMission,
      builder: (context, state) => const TrainMissionPage(),
    ),
    GoRoute(
      path: AppRoutes.trainStepOne,
      builder: (context, state) => const TrainStepOnePage(),
    ),
    GoRoute(
      path: AppRoutes.trainStepTwo,
      builder: (context, state) => const TrainStepTwoPage(),
    ),
    GoRoute(
      path: AppRoutes.trainStepThree,
      builder: (context, state) => const TrainStepThreePage(),
    ),
    GoRoute(
      path: AppRoutes.trainStepFour,
      builder: (context, state) => const TrainStepFourPage(),
    ),
    GoRoute(
      path: AppRoutes.trainStepFive,
      builder: (context, state) => const TrainStepFivePage(),
    ),
    GoRoute(
      path: AppRoutes.trainComplete,
      builder: (context, state) => const TrainCompletePage(),
    ),
    GoRoute(
      path: AppRoutes.hamburgerStart,
      builder: (context, state) => const HamburgerStartPage(),
    ),
    GoRoute(
      path: AppRoutes.hamburgerMission,
      builder: (context, state) => const HamburgerMissionPage(),
    ),
    GoRoute(
      path: AppRoutes.hamburgerPractice,
      builder: (context, state) => const HamburgerPracticePage(),
    ),
    GoRoute(
      path: AppRoutes.hamburgerComplete,
      builder: (context, state) => const HamburgerCompletePage(),
    ),
    GoRoute(
      path: AppRoutes.atmStart,
      builder: (context, state) => const AtmStartPage(),
    ),
    GoRoute(
      path: AppRoutes.atmMission,
      builder: (context, state) => const AtmMissionPage(),
    ),
    GoRoute(
      path: AppRoutes.atmPractice,
      builder: (context, state) => const AtmPracticePage(),
    ),
    GoRoute(
      path: AppRoutes.atmComplete,
      builder: (context, state) => const AtmCompletePage(),
    ),
    GoRoute(
      path: AppRoutes.civilDocumentStart,
      builder: (context, state) => const CivilDocumentStartPage(),
    ),
    GoRoute(
      path: AppRoutes.civilDocumentMission,
      builder: (context, state) => const CivilDocumentMissionPage(),
    ),
    GoRoute(
      path: AppRoutes.civilDocumentPractice,
      builder: (context, state) => const CivilDocumentPracticePage(),
    ),
    GoRoute(
      path: AppRoutes.civilDocumentComplete,
      builder: (context, state) => const CivilDocumentCompletePage(),
    ),
  ],
);

class _RouteNotFoundPage extends StatelessWidget {
  const _RouteNotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('페이지 안내')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.home_outlined,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '이 화면을 열 수 없어요.',
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '홈으로 돌아가서 연습을 다시 선택해 주세요.',
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: () => context.go(AppRoutes.home),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(64),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    icon: const Icon(Icons.home_outlined),
                    label: const Text(
                      '홈으로 돌아가기',
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
