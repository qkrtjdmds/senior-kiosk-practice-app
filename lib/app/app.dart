import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_router.dart';
import 'app_theme.dart';
import '../features/learning/learning_progress_provider.dart';
import '../features/daily_mission/daily_mission_provider.dart';

class HanGeoleumDigitalApp extends StatefulWidget {
  const HanGeoleumDigitalApp({super.key});

  @override
  State<HanGeoleumDigitalApp> createState() => _HanGeoleumDigitalAppState();
}

class _HanGeoleumDigitalAppState extends State<HanGeoleumDigitalApp> {
  DailyMissionProvider? _dailyMissions;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final progress = context.read<LearningProgressProvider>();
    _dailyMissions ??= DailyMissionProvider(progress.preferences, progress);
  }

  @override
  void dispose() {
    _dailyMissions?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<LearningProgressProvider>();

    return ChangeNotifierProvider.value(
      value: _dailyMissions!,
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
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
