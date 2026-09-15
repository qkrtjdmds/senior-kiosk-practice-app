import 'package:flutter/material.dart';

import 'app_router.dart';
import 'app_theme.dart';

class HanGeoleumDigitalApp extends StatelessWidget {
  const HanGeoleumDigitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '한걸음 디지털',
      theme: buildAppTheme(),
      routerConfig: appRouter,
    );
  }
}
