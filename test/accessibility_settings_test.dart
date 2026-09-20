import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:han_geoleum_digital/app/app.dart';
import 'package:han_geoleum_digital/app/app_router.dart';
import 'package:han_geoleum_digital/app/app_routes.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';

void main() {
  test('화면 설정을 저장하고 새 Provider에서 복원한다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final settings = LearningProgressProvider(preferences);

    expect(settings.accessibilityTextSize, AccessibilityTextSize.normal);
    expect(settings.screenContrast, ScreenContrast.comfortable);
    expect(settings.textScaleFactor, 1.0);

    await settings.setAccessibilityTextSize(AccessibilityTextSize.extraLarge);
    await settings.setScreenContrast(ScreenContrast.vivid);

    final reloaded = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    expect(reloaded.accessibilityTextSize, AccessibilityTextSize.extraLarge);
    expect(reloaded.screenContrast, ScreenContrast.vivid);
    expect(reloaded.textScaleFactor, 1.33);
    expect(reloaded.usesVividContrast, isTrue);
  });

  testWidgets('화면 설정 변경을 앱 전체에 바로 적용한다', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final settings = LearningProgressProvider(preferences);
    appRouter.go(AppRoutes.home);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: settings,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('화면 설정'));
    await tester.pumpAndSettle();
    expect(find.text('글씨 크기'), findsOneWidget);
    expect(find.text('화면 대비'), findsOneWidget);

    await tester.ensureVisible(find.text('아주 크게'));
    await tester.tap(find.text('아주 크게'));
    await tester.pumpAndSettle();
    expect(settings.textScaleFactor, 1.33);
    final settingsContext = tester.element(find.text('글씨 크기'));
    expect(
      MediaQuery.textScalerOf(settingsContext).scale(20),
      closeTo(26.6, 0.01),
    );

    await tester.ensureVisible(find.text('선명한 화면'));
    await tester.tap(find.text('선명한 화면'));
    await tester.pumpAndSettle();
    expect(settings.usesVividContrast, isTrue);
    expect(
      Theme.of(tester.element(find.text('화면 대비'))).colorScheme.onSurface,
      const Color(0xFF101413),
    );
    expect(find.text('설정한 내용은 앱을 다시 열어도 그대로 유지돼요.'), findsOneWidget);

    await tester.ensureVisible(find.text('홈으로 돌아가기'));
    await tester.tap(find.text('홈으로 돌아가기'));
    await tester.pumpAndSettle();
    expect(find.text('한걸음 디지털'), findsOneWidget);
    expect(find.byTooltip('화면 설정'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
