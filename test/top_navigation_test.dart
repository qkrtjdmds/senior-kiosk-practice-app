import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:han_geoleum_digital/app/app.dart';
import 'package:han_geoleum_digital/app/app_router.dart';
import 'package:han_geoleum_digital/app/app_routes.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';

void main() {
  testWidgets('홈 설정 버튼과 설정 뒤로가기가 동작한다', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final progress = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    appRouter.go(AppRoutes.home);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('글씨 크기와 화면 모양을 편하게 바꿔요.'), findsNothing);
    final settingsButton = find.byTooltip('화면 설정');
    expect(settingsButton, findsOneWidget);
    final buttonSize = tester.getSize(settingsButton);
    expect(buttonSize.width, greaterThanOrEqualTo(48));
    expect(buttonSize.height, greaterThanOrEqualTo(48));

    await tester.tap(settingsButton);
    await tester.pumpAndSettle();
    expect(find.text('글씨 크기'), findsOneWidget);
    await tester.tap(find.byTooltip('이전 화면으로 돌아가기'));
    await tester.pumpAndSettle();
    expect(find.text('한걸음 디지털'), findsOneWidget);
  });

  testWidgets('모든 학습 시작 화면의 뒤로가기가 홈으로 이동한다', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final progress = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    appRouter.go(AppRoutes.home);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();

    for (final route in [
      AppRoutes.cafeStart,
      AppRoutes.hospitalStart,
      AppRoutes.photoStart,
      AppRoutes.trainStart,
      AppRoutes.hamburgerStart,
      AppRoutes.atmStart,
      AppRoutes.civilDocumentStart,
    ]) {
      appRouter.go(route);
      await tester.pumpAndSettle();
      final backButton = find.byTooltip('이전 화면으로 돌아가기');
      expect(backButton, findsOneWidget, reason: route);
      await tester.tap(backButton);
      await tester.pumpAndSettle();
      expect(find.text('한걸음 디지털'), findsOneWidget, reason: route);
    }
  });

  testWidgets('단계 화면 뒤로가기와 좁은 상단 영역이 안전하다', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final progress = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    await progress.setAccessibilityTextSize(AccessibilityTextSize.extraLarge);
    appRouter.go(AppRoutes.home);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('화면 설정'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('이전 화면으로 돌아가기'));
    await tester.pumpAndSettle();

    progress.selectMode(CafeLearningMode.guided);
    appRouter.go(AppRoutes.cafeStepOne);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('이전 화면으로 돌아가기'));
    await tester.pumpAndSettle();
    expect(find.text('카페 키오스크 연습'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('잘못된 경로에서도 홈으로 안전하게 돌아간다', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final progress = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    await progress.setAccessibilityTextSize(AccessibilityTextSize.extraLarge);
    appRouter.go('/없는-화면');

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('이 화면을 열 수 없어요.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('홈으로 돌아가기'));
    await tester.pumpAndSettle();
    expect(find.text('한걸음 디지털'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
