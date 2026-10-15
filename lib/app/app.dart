import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_router.dart';
import 'app_theme.dart';
import '../features/learning/learning_progress_provider.dart';
import '../features/daily_mission/daily_mission_provider.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/rewards/reward_progress_provider.dart';
import '../features/rewards/reward_repository.dart';

class HanGeoleumDigitalApp extends StatefulWidget {
  const HanGeoleumDigitalApp({this.enableOnboarding = false, super.key});

  final bool enableOnboarding;

  @override
  State<HanGeoleumDigitalApp> createState() => _HanGeoleumDigitalAppState();
}

class _HanGeoleumDigitalAppState extends State<HanGeoleumDigitalApp> {
  DailyMissionProvider? _dailyMissions;
  RewardProgressProvider? _rewardProgress;
  LearningProgressProvider? _progress;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final progress = context.read<LearningProgressProvider>();
    if (!identical(_progress, progress)) {
      _dailyMissions?.dispose();
      _rewardProgress?.dispose();
      _progress = progress;
      _dailyMissions = DailyMissionProvider(progress.preferences, progress);
      _rewardProgress = RewardProgressProvider(
        repository: RewardRepository(progress.preferences),
        progress: progress,
      );
    }
  }

  @override
  void dispose() {
    _dailyMissions?.dispose();
    _rewardProgress?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<LearningProgressProvider>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _dailyMissions!),
        ChangeNotifierProvider.value(value: _rewardProgress!),
      ],
      child: MaterialApp.router(
        title: '한걸음 디지털',
        theme: buildAppTheme(highContrast: settings.usesVividContrast),
        routerConfig: appRouter,
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: TextScaler.linear(settings.textScaleFactor),
            ),
            child:
                widget.enableOnboarding &&
                    !settings.onboardingCompleted &&
                    appRouter.routeInformationProvider.value.uri.path == '/'
                ? const OnboardingPage()
                : child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
