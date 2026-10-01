import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:han_geoleum_digital/app/app.dart';
import 'package:han_geoleum_digital/app/app_router.dart';
import 'package:han_geoleum_digital/app/app_routes.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';

void main() {
  testWidgets('ATM V2 혼자 해보기 미션 화면을 표시한다', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final progress = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    appRouter.go(AppRoutes.atmMission);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('오늘의 ATM 출금 미션'), findsOneWidget);
    expect(find.text('혼자 출금해 보기'), findsOneWidget);
    expect(find.textContaining('가상 수수료'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
