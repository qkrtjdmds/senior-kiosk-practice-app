import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_router.dart';
import 'app_theme.dart';
import '../features/learning/learning_progress_provider.dart';

class HanGeoleumDigitalApp extends StatelessWidget {
  const HanGeoleumDigitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<LearningProgressProvider>();

    return MaterialApp.router(
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
    );
  }
}
