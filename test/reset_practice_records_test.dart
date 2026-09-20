import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:han_geoleum_digital/app/app.dart';
import 'package:han_geoleum_digital/app/app_router.dart';
import 'package:han_geoleum_digital/app/app_routes.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';

void main() {
  test('학습 기록만 초기화하고 화면 설정은 유지한다', () async {
    SharedPreferences.setMockInitialValues({
      'accessibility_text_size': 'extraLarge',
      'screen_contrast': 'vivid',
      'cafe_learning_completion_count': 2,
      'cafe_guided_completion_count': 3,
      'cafe_solo_completion_count': 4,
      'digital_confidence_points': 350,
      'cafe_solo_first_badge_earned': true,
      'cafe_familiar_badge_earned': true,
      'hospital_guided_completion_count': 2,
      'hospital_solo_completion_count': 2,
      'hospital_solo_first_badge_earned': true,
      'photo_guided_completion_count': 2,
      'photo_solo_completion_count': 2,
      'photo_solo_first_badge_earned': true,
      'train_guided_completion_count': 2,
      'train_solo_completion_count': 2,
      'train_solo_first_badge_earned': true,
      'hamburger_guided_completion_count': 2,
      'hamburger_solo_completion_count': 2,
      'hamburger_solo_first_badge_earned': true,
      'hamburger_learning_mode': 'solo',
      'hamburger_solo_session_awarded': true,
      'atm_guided_completion_count': 2,
      'atm_guided_session_awarded': true,
      'atm_solo_completion_count': 2,
      'atm_solo_first_badge_earned': true,
      'atm_solo_session_awarded': true,
      'atm_learning_mode': 'solo',
      'civil_document_guided_completion_count': 2,
      'civil_document_guided_session_awarded': true,
      'civil_document_solo_completion_count': 2,
      'civil_document_solo_first_badge_earned': true,
      'civil_document_solo_session_awarded': true,
      'civil_document_learning_mode': 'solo',
    });
    final progress = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );

    await progress.resetPracticeRecords();

    expect(progress.totalPoints, 0);
    expect(progress.guidedCompletionCount, 0);
    expect(progress.soloCompletionCount, 0);
    expect(progress.hospitalCompletionCount, 0);
    expect(progress.hospitalSoloCompletionCount, 0);
    expect(progress.photoCompletionCount, 0);
    expect(progress.photoSoloCompletionCount, 0);
    expect(progress.trainCompletionCount, 0);
    expect(progress.trainSoloCompletionCount, 0);
    expect(progress.hamburgerCompletionCount, 0);
    expect(progress.hamburgerSoloCompletionCount, 0);
    expect(progress.atmCompletionCount, 0);
    expect(progress.atmSoloCompletionCount, 0);
    expect(progress.civilDocumentCompletionCount, 0);
    expect(progress.civilDocumentSoloCompletionCount, 0);
    expect(progress.soloFirstBadgeEarned, isFalse);
    expect(progress.cafeFamiliarBadgeEarned, isFalse);
    expect(progress.hospitalSoloFirstBadgeEarned, isFalse);
    expect(progress.photoSoloFirstBadgeEarned, isFalse);
    expect(progress.trainSoloFirstBadgeEarned, isFalse);
    expect(progress.hamburgerSoloFirstBadgeEarned, isFalse);
    expect(progress.atmSoloFirstBadgeEarned, isFalse);
    expect(progress.civilDocumentSoloFirstBadgeEarned, isFalse);
    expect(progress.recentPracticeRecords, isEmpty);
    expect(progress.isHamburgerSoloMode, isFalse);
    expect(progress.isAtmSoloMode, isFalse);
    expect(progress.isCivilDocumentSoloMode, isFalse);
    expect(progress.accessibilityTextSize, AccessibilityTextSize.extraLarge);
    expect(progress.screenContrast, ScreenContrast.vivid);

    final reloaded = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    expect(reloaded.totalPoints, 0);
    expect(reloaded.recentPracticeRecords, isEmpty);
    expect(reloaded.accessibilityTextSize, AccessibilityTextSize.extraLarge);
    expect(reloaded.screenContrast, ScreenContrast.vivid);
  });

  testWidgets('취소는 기록을 유지하고 확인은 즉시 초기화한다', (tester) async {
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
    progress.selectMode(CafeLearningMode.solo);
    await progress.completeCafeLearning();
    appRouter.go(AppRoutes.accessibilitySettings);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();

    Future<void> openResetDialog() async {
      await tester.ensureVisible(find.text('연습 기록 초기화'));
      await tester.tap(find.text('연습 기록 초기화'));
      await tester.pumpAndSettle();
      expect(find.text('연습 기록을 초기화할까요?'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }

    await openResetDialog();
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(progress.totalPoints, 20);
    expect(progress.soloCompletionCount, 1);
    expect(progress.soloFirstBadgeEarned, isTrue);
    expect(progress.recentPracticeRecords, hasLength(1));

    await openResetDialog();
    await tester.tap(find.text('초기화하기'));
    await tester.pumpAndSettle();
    expect(find.text('연습 기록을 처음 상태로 되돌렸어요.'), findsOneWidget);
    expect(progress.totalPoints, 0);
    expect(progress.soloCompletionCount, 0);
    expect(progress.soloFirstBadgeEarned, isFalse);
    expect(progress.recentPracticeRecords, isEmpty);
    expect(progress.accessibilityTextSize, AccessibilityTextSize.extraLarge);
    expect(progress.screenContrast, ScreenContrast.vivid);
    expect(tester.takeException(), isNull);

    appRouter.go(AppRoutes.progress);
    await tester.pumpAndSettle();
    expect(find.text('0점'), findsOneWidget);
    expect(find.text('아직 완료한 연습이 없어요.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
