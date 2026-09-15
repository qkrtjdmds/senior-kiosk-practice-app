// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:han_geoleum_digital/app/app.dart';
import 'package:han_geoleum_digital/app/app_router.dart';
import 'package:han_geoleum_digital/app/app_routes.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';

void main() {
  testWidgets('홈 화면을 표시한다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    appRouter.go(AppRoutes.home);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LearningProgressProvider(preferences),
        child: const HanGeoleumDigitalApp(),
      ),
    );

    expect(find.text('한걸음 디지털'), findsOneWidget);
    expect(find.text('카페 키오스크 연습하기'), findsOneWidget);
  });

  testWidgets('카페 주문 선택값을 4단계 확인 화면에 표시한다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    appRouter.go(AppRoutes.home);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LearningProgressProvider(preferences),
        child: const HanGeoleumDigitalApp(),
      ),
    );

    await tester.tap(find.text('카페 키오스크 연습하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('따라 해보기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('포장할게요'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('카페라떼'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('따뜻하게 먹을게요'));
    await tester.pumpAndSettle();

    expect(find.text('4 / 4 단계'), findsOneWidget);
    expect(find.text('포장'), findsOneWidget);
    expect(find.text('카페라떼'), findsOneWidget);
    expect(find.text('따뜻하게'), findsOneWidget);
  });

  testWidgets('혼자 해보기 미션은 정답 선택과 첫 배지를 확인한다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    appRouter.go(AppRoutes.home);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LearningProgressProvider(preferences),
        child: const HanGeoleumDigitalApp(),
      ),
    );

    await tester.tap(find.text('카페 키오스크 연습하기'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('혼자 해보기'));
    await tester.tap(find.text('혼자 해보기'));
    await tester.pumpAndSettle();
    expect(find.text('오늘의 주문 미션'), findsOneWidget);
    expect(find.text('포장 · 아이스 아메리카노'), findsOneWidget);

    await tester.tap(find.text('혼자 주문해보기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('매장에서 먹을게요'));
    await tester.pump();
    expect(find.text('1 / 4 단계'), findsOneWidget);
    expect(find.textContaining('괜찮아요. 오늘의 주문을 다시 확인해볼까요?'), findsOneWidget);

    await tester.tap(find.text('힌트 보기'));
    await tester.pumpAndSettle();
    expect(find.text('오늘의 주문'), findsOneWidget);
    expect(find.text('포장 · 아이스 아메리카노'), findsOneWidget);
    await tester.tap(find.text('다시 해볼게요'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('포장할게요'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('아메리카노'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('차갑게 먹을게요'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('결제하기'));
    await tester.tap(find.text('결제하기'));
    await tester.pumpAndSettle();

    expect(find.text('혼자서도 잘하셨어요!'), findsOneWidget);
    expect(find.text('오늘의 주문 미션을 완성했어요.'), findsOneWidget);
    expect(find.text('용기 포인트 +20점'), findsOneWidget);
    expect(find.text('혼자 주문 첫걸음'), findsOneWidget);
  });

  test('카페 완료 횟수를 저장하고 다시 읽는다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);

    await progress.markCafeLearningCompleted();
    await progress.markCafeLearningCompleted();

    expect(progress.cafeCompletionCount, 2);
    final reloaded = await SharedPreferences.getInstance();
    expect(LearningProgressProvider(reloaded).cafeCompletionCount, 2);
  });

  test('학습 모드별 포인트를 한 번씩만 지급한다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);

    progress.selectMode(CafeLearningMode.guided);
    await progress.completeCafeLearning();
    await progress.completeCafeLearning();

    expect(progress.totalPoints, 10);
    expect(progress.guidedCompletionCount, 1);
    expect(progress.soloCompletionCount, 0);

    progress.selectMode(CafeLearningMode.solo);
    final firstSoloBadge = await progress.completeCafeLearning();
    await progress.completeCafeLearning();

    expect(progress.totalPoints, 30);
    expect(progress.guidedCompletionCount, 1);
    expect(progress.soloCompletionCount, 1);
    expect(firstSoloBadge, isTrue);
    expect(progress.soloFirstBadgeEarned, isTrue);

    progress.resetCafeLearning();
    final secondSoloBadge = await progress.completeCafeLearning();

    expect(secondSoloBadge, isFalse);
    expect(progress.totalPoints, 50);
    expect(progress.soloCompletionCount, 2);
  });

  testWidgets('나의 디지털 걸음 화면에 기록과 배지를 표시한다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'digital_confidence_points': 70,
      'cafe_guided_completion_count': 3,
      'cafe_solo_completion_count': 3,
      'cafe_solo_first_badge_earned': true,
      'cafe_familiar_badge_earned': true,
    });
    final preferences = await SharedPreferences.getInstance();
    appRouter.go(AppRoutes.progress);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LearningProgressProvider(preferences),
        child: const HanGeoleumDigitalApp(),
      ),
    );

    expect(find.text('나의 디지털 걸음'), findsOneWidget);
    expect(find.text('70점'), findsOneWidget);
    expect(find.text('따라 해보기'), findsOneWidget);
    expect(find.text('3회'), findsNWidgets(2));
    expect(find.text('혼자 주문 첫걸음'), findsOneWidget);
    expect(find.text('카페 주문 익숙해졌어요'), findsOneWidget);
    expect(find.text('달성했어요'), findsOneWidget);
  });
}
