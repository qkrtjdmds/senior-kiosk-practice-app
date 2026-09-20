import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:han_geoleum_digital/app/app.dart';
import 'package:han_geoleum_digital/app/app_router.dart';
import 'package:han_geoleum_digital/app/app_routes.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';

void main() {
  testWidgets('ATM 혼자 해보기 미션을 완료한다', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);
    appRouter.go(AppRoutes.atmStart);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('혼자 해보기'));
    await tester.tap(find.text('혼자 해보기'));
    await tester.pumpAndSettle();
    expect(find.text('오늘의 ATM 출금 미션'), findsOneWidget);
    expect(find.text('5만 원 찾기'), findsOneWidget);

    await tester.ensureVisible(find.text('혼자 출금해보기'));
    await tester.tap(find.text('혼자 출금해보기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('카드를 넣을게요'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('잔액을 확인할게요'));
    await tester.pump();
    expect(find.text('2 / 5 단계'), findsOneWidget);
    expect(
      find.text('괜찮아요. 오늘의 출금 내용을 다시 확인해볼까요?\n힌트 보기를 누르면 출금 내용을 확인할 수 있어요.'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('힌트 보기'));
    await tester.tap(find.text('힌트 보기'));
    await tester.pumpAndSettle();
    expect(find.text('오늘의 출금 내용'), findsOneWidget);
    expect(find.textContaining('카드와 현금 챙기기'), findsOneWidget);
    await tester.tap(find.text('다시 해볼게요'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('돈을 찾을게요'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('3만 원'));
    await tester.tap(find.text('3만 원'));
    await tester.pump();
    expect(find.text('3 / 5 단계'), findsOneWidget);

    await tester.ensureVisible(find.text('5만 원'));
    await tester.tap(find.text('5만 원'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('출금 확인'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('카드와 현금을 챙길게요'));
    await tester.pumpAndSettle();

    expect(find.text('혼자서도 잘하셨어요!'), findsOneWidget);
    expect(find.text('오늘의 ATM 출금 미션을 완성했어요.'), findsOneWidget);
    expect(find.text('용기 포인트 +20점'), findsOneWidget);
    expect(find.text('혼자 ATM 출금 첫걸음'), findsOneWidget);
  });

  test('ATM 혼자 해보기 보상과 첫 배지는 한 번만 저장한다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);

    await progress.startAtmLearning(AtmLearningMode.solo);
    progress.selectAtmAmount('5만 원');
    expect(await progress.completeAtmSoloLearning(), isTrue);

    final reentered = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    expect(reentered.isAtmSoloMode, isTrue);
    expect(await reentered.completeAtmSoloLearning(), isFalse);
    expect(reentered.atmSoloCompletionCount, 1);
    expect(reentered.atmSoloFirstBadgeEarned, isTrue);
    expect(reentered.totalPoints, 20);
    expect(reentered.recentPracticeRecords, hasLength(1));
    expect(reentered.recentPracticeRecords.single.learningName, 'ATM 출금');
    expect(reentered.recentPracticeRecords.single.modeName, '혼자 해보기');

    final reloaded = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    expect(reloaded.atmSoloCompletionCount, 1);
    expect(reloaded.atmSoloFirstBadgeEarned, isTrue);
    expect(reloaded.totalPoints, 20);
  });
}
