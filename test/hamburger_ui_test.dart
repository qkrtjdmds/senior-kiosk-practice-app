import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:han_geoleum_digital/app/app.dart';
import 'package:han_geoleum_digital/app/app_router.dart';
import 'package:han_geoleum_digital/app/app_routes.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';

void main() {
  testWidgets('좁은 화면과 아주 큰 글씨에서 햄버거 주요 화면이 넘치지 않는다', (tester) async {
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

    appRouter.go(AppRoutes.hamburgerStart);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('메뉴와 세트를 고르는 순서를 천천히 연습해요.'), findsNWidgets(2));
    expect(find.text('화면의 안내를 보며 하나씩 주문해요.'), findsOneWidget);
    expect(find.text('오늘의 주문 미션을 기억하고 직접 골라봐요.'), findsOneWidget);
    expect(tester.takeException(), isNull);

    progress.selectHamburgerMode(HamburgerLearningMode.guided);
    appRouter.go(AppRoutes.hamburgerPractice);
    await tester.pumpAndSettle();
    expect(find.text('화면의 안내를 보고 선택해보세요.'), findsOneWidget);
    expect(find.text('여기를 눌러보세요'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await progress.startHamburgerSoloMission();
    appRouter.go(AppRoutes.hamburgerPractice);
    await tester.pumpAndSettle();
    expect(find.text('미션을 기억하고 직접 골라보세요.'), findsOneWidget);
    expect(find.text('힌트 보기'), findsOneWidget);
    expect(find.text('여기를 눌러보세요'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('햄버거 주문 확인은 선택한 내용을 공통 장바구니 카드에 표시한다', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final progress = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    )..selectHamburgerMode(HamburgerLearningMode.guided);

    appRouter.go(AppRoutes.hamburgerPractice);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();

    Future<void> choose(String label) async {
      final target = find.text(label);
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
    }

    await choose('매장에서 먹을게요');
    await choose('치즈버거');
    await choose('세트로 주문할게요');
    await choose('콜라');

    expect(find.text('내 장바구니'), findsWidgets);
    expect(find.text('주문 방식'), findsOneWidget);
    expect(find.text('매장 식사'), findsWidgets);
    expect(find.text('치즈버거'), findsWidgets);
    expect(find.text('세트 / 단품'), findsOneWidget);
    expect(find.text('콜라'), findsWidgets);
    expect(find.text('연습용 주문이에요'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
