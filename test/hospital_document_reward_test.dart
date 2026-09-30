import 'package:flutter_test/flutter_test.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('서류 발급 따라 해보기 보상은 세션마다 한 번만 저장된다', () async {
    SharedPreferences.setMockInitialValues({});
    final progress = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    progress.startHospitalDocumentLearning(solo: false);
    expect(
      await progress.completeHospitalDocumentLearning(solo: false),
      isTrue,
    );
    expect(
      await progress.completeHospitalDocumentLearning(solo: false),
      isFalse,
    );
    expect(progress.totalPoints, 10);
    expect(progress.hospitalDocumentCompletionCount, 1);
    expect(progress.hospitalPaymentCompletionCount, 0);
    expect(progress.recentPracticeRecords.first.learningName, '병원 서류 발급');
  });

  test('서류 발급 혼자 해보기는 20점이며 기록 초기화 대상이다', () async {
    SharedPreferences.setMockInitialValues({});
    final progress = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    progress.startHospitalDocumentLearning(solo: true);
    await Future.wait([
      progress.completeHospitalDocumentLearning(solo: true),
      progress.completeHospitalDocumentLearning(solo: true),
    ]);
    expect(progress.totalPoints, 20);
    expect(progress.hospitalDocumentSoloCompletionCount, 1);
    await progress.resetPracticeRecords();
    expect(progress.totalPoints, 0);
    expect(progress.hospitalDocumentSoloCompletionCount, 0);
  });

  test('병원 확장 업무 보상과 최근 기록은 서로 독립적이다', () async {
    SharedPreferences.setMockInitialValues({});
    final progress = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    progress.startHospitalReservationLearning(solo: false);
    await progress.completeHospitalReservationLearning(solo: false);
    progress.startHospitalPaymentLearning(solo: false);
    await progress.completeHospitalPaymentLearning(solo: false);
    progress.startHospitalDocumentLearning(solo: false);
    await progress.completeHospitalDocumentLearning(solo: false);
    expect(progress.totalPoints, 30);
    expect(progress.hospitalReservationCompletionCount, 1);
    expect(progress.hospitalPaymentCompletionCount, 1);
    expect(progress.hospitalDocumentCompletionCount, 1);
    expect(
      progress.recentPracticeRecords
          .take(3)
          .map((record) => record.learningName),
      ['병원 서류 발급', '병원 진료비 수납', '병원 예약 확인'],
    );
  });

  test('수납 연습 시작은 이미 지급된 서류 발급 세션을 다시 열지 않는다', () async {
    SharedPreferences.setMockInitialValues({});
    final progress = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    progress.startHospitalDocumentLearning(solo: false);
    expect(
      await progress.completeHospitalDocumentLearning(solo: false),
      isTrue,
    );
    progress.startHospitalPaymentLearning(solo: false);
    expect(
      await progress.completeHospitalDocumentLearning(solo: false),
      isFalse,
    );
    expect(progress.totalPoints, 10);
    expect(progress.hospitalDocumentCompletionCount, 1);
  });
}
