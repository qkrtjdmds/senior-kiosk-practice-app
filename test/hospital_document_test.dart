import 'package:flutter_test/flutter_test.dart';
import 'package:han_geoleum_digital/features/hospital_v2/hospital_document_provider.dart';
import 'package:han_geoleum_digital/features/hospital_v2/hospital_payment_provider.dart';

void main() {
  group('HospitalDocumentProvider', () {
    test('모든 서류 데이터는 연습용이고 진단서는 창구 안내만 제공한다', () {
      expect(hospitalPracticeDocuments, hasLength(5));
      expect(
        hospitalPracticeDocuments.every((item) => item.isPracticeData),
        isTrue,
      );
      final diagnosis = hospitalPracticeDocuments.last;
      expect(diagnosis.kioskAvailable, isFalse);
      expect(diagnosis.counterNotice, contains('원무창구'));
    });

    test('환자 확인 전에는 서류 목록으로 이동하지 않는다', () {
      final provider = HospitalDocumentProvider()..begin(solo: false);
      provider.enterPatientCheck();
      for (final digit in '19580411'.split('')) {
        provider.addDigit(digit);
      }
      expect(provider.verifyPatient(), isFalse);
      expect(provider.step, HospitalDocumentStep.patient);
      provider.clearPatientNumber();
      for (final digit in '19580412'.split('')) {
        provider.addDigit(digit);
      }
      expect(provider.verifyPatient(), isTrue);
      expect(provider.step, HospitalDocumentStep.document);
      expect(provider.patientNumber, isEmpty);
    });

    test('발급 불가 서류는 현재 단계에 머물며 직원 안내를 제공한다', () {
      final provider = HospitalDocumentProvider()..begin(solo: false);
      provider.step = HospitalDocumentStep.document;
      expect(provider.selectDocument(hospitalPracticeDocuments.last), isFalse);
      expect(provider.step, HospitalDocumentStep.document);
      expect(provider.notice, contains('원무창구'));
    });

    test('따라 해보기 목표와 수수료 계산이 올바르다', () {
      final provider = HospitalDocumentProvider()..begin(solo: false);
      provider.step = HospitalDocumentStep.document;
      expect(provider.targetDocument.name, '통원확인서');
      expect(provider.selectDocument(provider.targetDocument), isTrue);
      expect(provider.selectPurpose('보험회사 제출'), isTrue);
      expect(provider.selectCopies(1), isTrue);
      expect(provider.totalFee, 3000);
      expect(provider.step, HospitalDocumentStep.review);
    });

    test('혼자 해보기 세 시나리오가 서로 다른 목표를 제공한다', () {
      final provider = HospitalDocumentProvider();
      for (var index = 0; index < hospitalDocumentScenarios.length; index++) {
        provider.begin(solo: true, completedCount: index);
        expect(provider.scenario, hospitalDocumentScenarios[index]);
      }
      expect(
        hospitalDocumentScenarios.map((item) => item.id).toSet(),
        hasLength(3),
      );
    });

    test('다른 선택은 단계를 진행시키지 않는다', () {
      final provider = HospitalDocumentProvider()
        ..begin(solo: true, completedCount: 1);
      provider.step = HospitalDocumentStep.document;
      expect(provider.selectDocument(hospitalPracticeDocuments.first), isFalse);
      expect(provider.step, HospitalDocumentStep.document);
      expect(provider.notice, contains('다시 확인'));
    });

    test('1부 미만과 3부 초과를 허용하지 않고 총액을 다시 계산한다', () {
      final provider = HospitalDocumentProvider()
        ..begin(solo: true, completedCount: 1);
      provider.step = HospitalDocumentStep.document;
      provider.selectDocument(provider.targetDocument);
      provider.selectPurpose(provider.scenario.purpose);
      expect(provider.selectCopies(0), isFalse);
      expect(provider.selectCopies(4), isFalse);
      expect(provider.selectCopies(2), isTrue);
      expect(provider.totalFee, 2000);
    });

    test('결제 완료와 출력 완료만으로는 끝낼 수 없고 서류를 챙겨야 한다', () {
      final provider = HospitalDocumentProvider()..begin(solo: false);
      provider.selectedDocument = provider.targetDocument;
      provider.purpose = provider.scenario.purpose;
      provider.step = HospitalDocumentStep.practice;
      provider.choosePaymentMethod(HospitalPaymentMethod.card);
      while (!provider.paymentComplete) {
        provider.advancePayment();
      }
      expect(provider.finish(), isFalse);
      provider.completePrinting();
      expect(provider.finish(), isFalse);
      provider.takeDocument();
      expect(provider.finish(), isTrue);
      expect(provider.step, HospitalDocumentStep.complete);
    });

    test('뒤로가기는 결제 진행 상태와 환자 입력을 정리한다', () {
      final provider = HospitalDocumentProvider()..begin(solo: false);
      provider.step = HospitalDocumentStep.practice;
      provider.paymentMethod = HospitalPaymentMethod.card;
      provider.paymentActionIndex = 2;
      provider.previous();
      expect(provider.step, HospitalDocumentStep.review);
      expect(provider.paymentMethod, isNull);
      provider.step = HospitalDocumentStep.patient;
      provider.patientNumber = '1958';
      provider.previous();
      expect(provider.patientNumber, isEmpty);
    });
  });
}
