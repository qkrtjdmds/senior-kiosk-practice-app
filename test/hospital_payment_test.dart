import 'package:flutter_test/flutter_test.dart';
import 'package:han_geoleum_digital/features/hospital_v2/hospital_payment_provider.dart';

void main() {
  group('HospitalPaymentProvider', () {
    test('세 개의 연습용 진료비와 원 단위 금액을 제공한다', () {
      expect(hospitalPracticeBills, hasLength(3));
      expect(hospitalPracticeBills.where((bill) => bill.canPay), hasLength(2));
      expect(formatPracticeWon(18500), '18,500원');
      expect(
        hospitalPracticeBills.every((bill) => bill.isPracticeData),
        isTrue,
      );
    });

    test('환자 확인 후 진료비 선택 단계로 이동하고 입력을 제거한다', () {
      final provider = HospitalPaymentProvider()..begin(solo: false);
      provider.enterPatientCheck();
      for (final digit in '19580412'.split('')) {
        provider.addDigit(digit);
      }
      expect(provider.verifyPatient(), isTrue);
      expect(provider.step, HospitalPaymentStep.selection);
      expect(provider.patientNumber, isEmpty);
    });

    test('납부 완료 내역과 목표가 아닌 내역은 현재 단계에 머문다', () {
      final provider = HospitalPaymentProvider()..begin(solo: false);
      provider.enterPatientCheck();
      for (final digit in '19580412'.split('')) {
        provider.addDigit(digit);
      }
      provider.verifyPatient();
      expect(provider.selectBill(hospitalPracticeBills[2]), isFalse);
      expect(provider.notice, contains('납부가 완료'));
      expect(provider.selectBill(hospitalPracticeBills[1]), isFalse);
      expect(provider.step, HospitalPaymentStep.selection);
      expect(provider.selectBill(hospitalPracticeBills[0]), isTrue);
    });

    test('혼자 해보기 세 시나리오가 완료 횟수에 따라 순환한다', () {
      final provider = HospitalPaymentProvider();
      for (var index = 0; index < hospitalPaymentScenarios.length; index++) {
        provider.begin(solo: true, completedCount: index);
        expect(provider.scenario, hospitalPaymentScenarios[index]);
      }
      provider.begin(solo: true, completedCount: 3);
      expect(provider.scenario, hospitalPaymentScenarios.first);
    });

    test('카드는 카드 챙기기까지 순서대로 눌러야 완료할 수 있다', () {
      final provider = HospitalPaymentProvider()..begin(solo: false);
      provider.selectedBill = hospitalPracticeBills.first;
      provider.continueToMethod();
      expect(provider.chooseMethod(HospitalPaymentMethod.card), isTrue);
      for (var index = 0; index < 3; index++) {
        provider.advancePractice();
      }
      expect(provider.practiceComplete, isFalse);
      provider.finish();
      expect(provider.step, HospitalPaymentStep.practice);
      provider.advancePractice();
      expect(provider.practiceComplete, isTrue);
      expect(provider.chooseReceipt(true), isTrue);
      provider.finish();
      expect(provider.step, HospitalPaymentStep.complete);
    });

    test('간편결제와 현금 시나리오를 별도 순서로 처리한다', () {
      final mobile = HospitalPaymentProvider()
        ..begin(solo: true, completedCount: 1);
      expect(mobile.targetMethod, HospitalPaymentMethod.mobile);
      expect(mobile.practiceActions, isEmpty);
      mobile.paymentMethod = HospitalPaymentMethod.mobile;
      expect(mobile.practiceActions, hasLength(3));

      final cash = HospitalPaymentProvider()
        ..begin(solo: true, completedCount: 2);
      cash.paymentMethod = HospitalPaymentMethod.cash;
      expect(cash.practiceActions, ['원무창구 안내를 확인했어요']);
      expect(cash.scenario.wantsReceipt, isNull);
    });

    test('내역이나 결제 방법으로 돌아가면 이후 결제 상태를 제거한다', () {
      final provider = HospitalPaymentProvider()..begin(solo: false);
      provider.selectedBill = hospitalPracticeBills.first;
      provider.continueToMethod();
      provider.chooseMethod(HospitalPaymentMethod.card);
      provider.advancePractice();
      provider.previous();
      expect(provider.step, HospitalPaymentStep.method);
      expect(provider.paymentMethod, isNull);
      expect(provider.practiceActionIndex, 0);
      provider.previous();
      provider.chooseAnotherBill();
      expect(provider.selectedBill, isNull);
      expect(provider.wantsReceipt, isNull);
    });
  });
}
