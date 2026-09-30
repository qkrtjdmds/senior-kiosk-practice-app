import 'package:flutter_test/flutter_test.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('예약 확인 따라 해보기는 세션당 10점을 한 번만 저장한다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);

    progress.startHospitalReservationLearning(solo: false);
    expect(
      await progress.completeHospitalReservationLearning(solo: false),
      isTrue,
    );
    expect(
      await progress.completeHospitalReservationLearning(solo: false),
      isFalse,
    );

    expect(progress.totalPoints, 10);
    expect(progress.hospitalReservationCompletionCount, 1);
    expect(progress.hospitalCompletionCount, 0);
    expect(progress.recentPracticeRecords.first.learningName, '병원 예약 확인');
  });

  test('예약 확인 혼자 해보기는 세션당 20점을 한 번만 저장한다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);

    progress.startHospitalReservationLearning(solo: true);
    await Future.wait([
      progress.completeHospitalReservationLearning(solo: true),
      progress.completeHospitalReservationLearning(solo: true),
    ]);

    expect(progress.totalPoints, 20);
    expect(progress.hospitalReservationSoloCompletionCount, 1);
    expect(progress.hospitalSoloCompletionCount, 0);
    expect(progress.recentPracticeRecords.first.learningName, '병원 예약 확인');
  });

  test('예약 확인 보상 키는 기록 초기화 대상이며 화면 설정은 유지된다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);
    await progress.setAccessibilityTextSize(AccessibilityTextSize.extraLarge);
    await progress.setScreenContrast(ScreenContrast.vivid);
    progress.startHospitalReservationLearning(solo: false);
    await progress.completeHospitalReservationLearning(solo: false);

    await progress.resetPracticeRecords();

    expect(progress.totalPoints, 0);
    expect(progress.hospitalReservationCompletionCount, 0);
    expect(progress.recentPracticeRecords, isEmpty);
    expect(progress.accessibilityTextSize, AccessibilityTextSize.extraLarge);
    expect(progress.screenContrast, ScreenContrast.vivid);
  });
}
