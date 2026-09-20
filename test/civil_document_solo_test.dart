import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:han_geoleum_digital/app/app.dart';
import 'package:han_geoleum_digital/app/app_router.dart';
import 'package:han_geoleum_digital/app/app_routes.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';

void main() {
  testWidgets('무인민원발급기 혼자 해보기 미션을 완료한다', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);
    appRouter.go(AppRoutes.civilDocumentStart);

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
    expect(find.text('오늘의 서류 발급 미션'), findsOneWidget);
    expect(find.text('필요한 서류'), findsOneWidget);
    expect(find.text('주민등록등본'), findsOneWidget);
    expect(find.text('표시 내용'), findsOneWidget);
    expect(find.text('기본 내용'), findsOneWidget);
    expect(find.text('발급 부수'), findsOneWidget);
    expect(find.text('한 부'), findsOneWidget);
    expect(find.text('힌트가 필요하면 언제든지 확인할 수 있어요.'), findsOneWidget);

    await tester.ensureVisible(find.text('혼자 발급해보기'));
    await tester.tap(find.text('혼자 발급해보기'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('가족관계증명서'));
    await tester.tap(find.text('가족관계증명서'));
    await tester.pump();
    expect(find.text('1 / 5 단계'), findsOneWidget);
    expect(
      find.text('이번 미션 내용을 다시 살펴볼까요?\n힌트 보기를 누르면 발급 내용을 확인할 수 있어요.'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('힌트 보기'));
    await tester.tap(find.text('힌트 보기'));
    await tester.pumpAndSettle();
    expect(find.text('오늘의 발급 내용'), findsOneWidget);
    expect(find.textContaining('서류 챙기기'), findsOneWidget);
    await tester.tap(find.text('다시 해볼게요'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('주민등록등본'));
    await tester.tap(find.text('주민등록등본'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('자세한 내용으로 발급할게요'));
    await tester.tap(find.text('자세한 내용으로 발급할게요'));
    await tester.pump();
    expect(find.text('2 / 5 단계'), findsOneWidget);

    await tester.tap(find.text('기본 내용'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('두 부'));
    await tester.tap(find.text('두 부'));
    await tester.pump();
    expect(find.text('3 / 5 단계'), findsOneWidget);

    await tester.tap(find.text('한 부'));
    await tester.pumpAndSettle();
    expect(find.text('주민등록등본'), findsOneWidget);
    expect(find.text('기본 내용'), findsOneWidget);
    expect(find.text('한 부'), findsOneWidget);
    await tester.tap(find.text('맞아요, 발급할게요'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('서류를 챙겼어요'));
    await tester.pumpAndSettle();

    expect(find.text('혼자서도 잘하셨어요!'), findsOneWidget);
    expect(find.text('무인민원발급기에서 서류를 고르는 연습을 마쳤어요.'), findsOneWidget);
    expect(find.text('+20점'), findsOneWidget);
    expect(find.text('새 배지: 혼자 서류 발급 첫걸음'), findsOneWidget);
    expect(progress.civilDocumentSoloCompletionCount, 1);
    expect(progress.totalPoints, 20);

    await tester.ensureVisible(find.text('처음부터 다시 하기'));
    await tester.tap(find.text('처음부터 다시 하기'));
    await tester.pumpAndSettle();
    expect(find.text('1 / 5 단계'), findsOneWidget);
    expect(progress.civilDocumentSoloCompletionCount, 1);
    expect(progress.totalPoints, 20);
  });

  test('무인민원발급기 혼자 해보기 보상과 첫 배지는 한 번만 저장한다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);

    await progress.startCivilDocumentLearning(CivilDocumentLearningMode.solo);
    progress.selectCivilDocumentContent('기본 내용');
    progress.selectCivilDocumentCopies('한 부');
    expect(await progress.completeCivilDocumentSoloLearning(), isTrue);

    final reentered = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    expect(reentered.isCivilDocumentSoloMode, isTrue);
    expect(await reentered.completeCivilDocumentSoloLearning(), isFalse);
    expect(reentered.civilDocumentSoloCompletionCount, 1);
    expect(reentered.civilDocumentSoloFirstBadgeEarned, isTrue);
    expect(reentered.totalPoints, 20);
    expect(reentered.recentPracticeRecords, hasLength(1));
    expect(reentered.recentPracticeRecords.single.learningName, '무인민원발급기');
    expect(reentered.recentPracticeRecords.single.modeName, '혼자 해보기');

    final reloaded = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    expect(reloaded.civilDocumentSoloCompletionCount, 1);
    expect(reloaded.civilDocumentSoloFirstBadgeEarned, isTrue);
    expect(reloaded.totalPoints, 20);
  });
}
