import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:han_geoleum_digital/app/app.dart';
import 'package:han_geoleum_digital/app/app_router.dart';
import 'package:han_geoleum_digital/app/app_routes.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';

void main() {
  testWidgets('좁은 화면과 아주 큰 글씨에서 ATM 주요 화면이 넘치지 않는다', (tester) async {
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

    appRouter.go(AppRoutes.atmStart);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('실제 돈이 나가지 않는 연습 화면이에요.'), findsOneWidget);
    expect(find.text('ATM에서 돈을 찾는 순서를 천천히 연습해요.'), findsOneWidget);
    expect(find.text('화면의 안내를 보며 하나씩 연습해요.'), findsOneWidget);
    expect(find.text('오늘의 출금 미션을 기억하고 직접 해봐요.'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await progress.startAtmLearning(AtmLearningMode.guided);
    appRouter.go(AppRoutes.atmPractice);
    await tester.pumpAndSettle();
    expect(find.text('화면의 안내를 보고 선택해보세요.'), findsOneWidget);
    expect(find.text('여기를 눌러보세요'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await progress.startAtmLearning(AtmLearningMode.solo);
    appRouter.go(AppRoutes.atmPractice);
    await tester.pumpAndSettle();
    expect(find.text('미션을 기억하고 직접 골라보세요.'), findsOneWidget);
    expect(find.text('힌트 보기'), findsOneWidget);
    expect(find.text('여기를 눌러보세요'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ATM 출금 확인은 선택 금액과 수수료를 공통 요약 카드에 표시한다', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final progress = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    await progress.startAtmLearning(AtmLearningMode.guided);

    appRouter.go(AppRoutes.atmPractice);
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

    await choose('카드를 넣을게요');
    await choose('돈을 찾을게요');
    await choose('5만 원');

    expect(find.text('출금 내용'), findsOneWidget);
    expect(find.text('출금 금액'), findsOneWidget);
    expect(find.text('수수료'), findsOneWidget);
    expect(find.text('없음'), findsOneWidget);
    expect(find.text('받을 금액'), findsOneWidget);
    expect(find.text('실제 거래가 아닌 연습용 화면이에요.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
