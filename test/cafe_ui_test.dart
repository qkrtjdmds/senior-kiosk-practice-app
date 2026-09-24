import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:han_geoleum_digital/app/app.dart';
import 'package:han_geoleum_digital/app/app_router.dart';
import 'package:han_geoleum_digital/app/app_routes.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';
import 'package:han_geoleum_digital/features/learning/widgets/learning_widgets.dart';

void main() {
  testWidgets('좁은 화면과 아주 큰 글씨에서 카페 주요 화면이 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final progress = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    await progress.setAccessibilityTextSize(AccessibilityTextSize.extraLarge);
    await progress.setScreenContrast(ScreenContrast.vivid);

    appRouter.go(AppRoutes.cafeStart);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('실제 주문 전에 천천히 연습해 볼 수 있어요.'), findsOneWidget);
    expect(find.text('연습용 주문 화면을 보며 순서를 익혀보세요.'), findsOneWidget);
    expect(tester.takeException(), isNull);

    progress.selectMode(CafeLearningMode.guided);
    appRouter.go(AppRoutes.cafeStepOne);
    await tester.pumpAndSettle();
    expect(find.byType(KioskPanel), findsOneWidget);
    expect(find.byType(GuidanceCard), findsNothing);
    expect(find.text('카페 주문'), findsOneWidget);
    expect(find.text('여기를 눌러보세요'), findsNWidgets(2));
    expect(tester.takeException(), isNull);

    for (final route in [
      AppRoutes.cafeStepTwo,
      AppRoutes.cafeStepThree,
      AppRoutes.cafeStepFour,
      AppRoutes.cafeComplete,
    ]) {
      appRouter.go(route);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: route);
    }

    progress.selectMode(CafeLearningMode.solo);
    appRouter.go(AppRoutes.cafeMission);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    appRouter.go(AppRoutes.cafeStepOne);
    await tester.pumpAndSettle();
    expect(find.text('미션을 기억하고 직접 골라보세요.'), findsOneWidget);
    expect(find.text('여기를 눌러보세요'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('힌트 보기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('힌트 보기'));
    await tester.pumpAndSettle();
    expect(find.text('오늘의 주문'), findsOneWidget);
    expect(find.text('포장 · 아이스 아메리카노'), findsOneWidget);
    expect(find.text('다시 해볼게요'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('카페 주문 확인 화면은 연습 주문 안내와 선택값을 표시한다', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final progress = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    )..selectMode(CafeLearningMode.guided);
    progress
      ..selectDineOption('포장')
      ..selectDrink('카페라떼')
      ..selectTemperature('따뜻하게');

    appRouter.go(AppRoutes.cafeStepFour);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('주문 내용을 확인해 볼까요?'), findsOneWidget);
    expect(find.text('매장 / 포장'), findsOneWidget);
    expect(find.text('포장'), findsOneWidget);
    expect(find.text('카페라떼'), findsOneWidget);
    expect(find.text('따뜻하게'), findsOneWidget);
    expect(find.text('실제 결제가 아닌 연습용 주문이에요.'), findsOneWidget);
  });
}
