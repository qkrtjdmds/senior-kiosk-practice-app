import 'package:flutter_test/flutter_test.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('진료비 수납 따라 해보기는 세션당 10점을 한 번만 지급한다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);
    progress.startHospitalPaymentLearning(solo: false);
    expect(await progress.completeHospitalPaymentLearning(solo: false), isTrue);
    expect(
      await progress.completeHospitalPaymentLearning(solo: false),
      isFalse,
    );
    expect(progress.totalPoints, 10);
    expect(progress.hospitalPaymentCompletionCount, 1);
    expect(progress.hospitalCompletionCount, 0);
    expect(progress.hospitalReservationCompletionCount, 0);
    expect(progress.recentPracticeRecords.first.learningName, '병원 진료비 수납');
  });

  test('진료비 수납 혼자 해보기의 빠른 요청은 20점을 한 번만 지급한다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);
    progress.startHospitalPaymentLearning(solo: true);
    await Future.wait([
      progress.completeHospitalPaymentLearning(solo: true),
      progress.completeHospitalPaymentLearning(solo: true),
    ]);
    expect(progress.totalPoints, 20);
    expect(progress.hospitalPaymentSoloCompletionCount, 1);
    expect(progress.hospitalSoloCompletionCount, 0);
  });
}
