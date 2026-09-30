import 'package:flutter_test/flutter_test.dart';
import 'package:han_geoleum_digital/features/hospital_v2/hospital_reception_provider.dart';
import 'package:han_geoleum_digital/features/hospital_v2/hospital_reservation_provider.dart';

void main() {
  group('HospitalReceptionProvider', () {
    test('혼자 해보기 미션은 완료 횟수에 따라 세 가지가 순환한다', () {
      final provider = HospitalReceptionProvider();

      for (var i = 0; i < hospitalSoloScenarios.length; i++) {
        provider.beginSolo(i);
        expect(provider.scenario, same(hospitalSoloScenarios[i]));
      }
      provider.beginSolo(3);
      expect(provider.scenario, same(hospitalSoloScenarios.first));
    });

    test('혼자 해보기에서 미션과 다른 선택은 현재 단계에 머문다', () {
      final provider = HospitalReceptionProvider()..beginSolo(0);
      provider.next();
      provider.next();

      expect(provider.step, HospitalReceptionStep.visit);
      expect(provider.chooseVisit('전에 방문한 적 있어요'), isFalse);
      expect(provider.step, HospitalReceptionStep.visit);
      expect(provider.notice, isNotNull);
    });

    test('연습용 생년월일 8자리만 환자 확인을 통과한다', () {
      final provider = HospitalReceptionProvider()..beginGuided();
      provider.next();
      provider.next();
      provider.chooseVisit(hospitalGuidedScenario.visit);

      for (final digit in '19580411'.split('')) {
        provider.addDigit(digit);
      }
      expect(provider.verifyPatient(), isFalse);
      expect(provider.step, HospitalReceptionStep.patient);

      provider.clearSensitiveData();
      for (final digit in '19580412'.split('')) {
        provider.addDigit(digit);
      }
      expect(provider.verifyPatient(), isTrue);
      expect(provider.step, HospitalReceptionStep.reservation);
    });

    test('숫자 키패드는 한 자리와 전체 입력을 지울 수 있다', () {
      final provider = HospitalReceptionProvider()..beginGuided();
      provider.addDigit('1');
      provider.addDigit('9');

      provider.removeDigit();
      expect(provider.patientNumber, '1');
      provider.clearPatientNumber();
      expect(provider.patientNumber, isEmpty);
    });

    test('준비 중 업무와 직원 도움은 현재 단계에 머문다', () {
      final provider = HospitalReceptionProvider()..beginGuided();
      provider.next();

      provider.showPreparedService('진료비 수납');
      expect(provider.step, HospitalReceptionStep.service);
      expect(provider.notice, contains('진료비 수납 기능은 준비 중'));

      provider.requestHelp();
      expect(provider.step, HospitalReceptionStep.service);
      expect(provider.notice, contains('도움'));
    });

    test('따라 해보기에서도 권장 선택과 다른 항목은 현재 단계에 머문다', () {
      final provider = HospitalReceptionProvider()..beginGuided();
      provider.next();
      provider.next();

      expect(provider.chooseVisit('처음 방문이에요'), isFalse);
      expect(provider.step, HospitalReceptionStep.visit);
      expect(provider.visit, isNull);
    });
    test('이전 단계로 돌아가면 이후 선택과 환자 확인 숫자를 정리한다', () {
      final provider = HospitalReceptionProvider()..beginGuided();
      provider.next();
      provider.next();
      provider.chooseVisit(hospitalGuidedScenario.visit);
      for (final digit in '19580412'.split('')) {
        provider.addDigit(digit);
      }
      provider.verifyPatient();
      provider.chooseReservation(hospitalGuidedScenario.reservation);

      provider.previous();
      provider.previous();

      expect(provider.step, HospitalReceptionStep.patient);
      expect(provider.reservation, isNull);
      provider.previous();
      expect(provider.patientNumber, isEmpty);
    });
  });

  group('HospitalReservationProvider', () {
    test('예약 목록은 세 개의 연습용 데이터로 구성된다', () {
      expect(hospitalPracticeReservations, hasLength(3));
      expect(
        hospitalPracticeReservations.every((item) => item.isPracticeData),
        isTrue,
      );
      expect(
        hospitalPracticeReservations.map((item) => item.id).toSet(),
        hasLength(3),
      );
    });

    test('올바른 연습용 생년월일만 예약 목록으로 진행한다', () {
      final provider = HospitalReservationProvider()..begin(solo: false);
      provider.enterPatientCheck();
      for (final digit in '19580411'.split('')) {
        provider.addDigit(digit);
      }
      expect(provider.verifyPatient(), isFalse);
      expect(provider.step, HospitalReservationStep.patient);

      provider.clearPatientNumber();
      for (final digit in '19580412'.split('')) {
        provider.addDigit(digit);
      }
      expect(provider.verifyPatient(), isTrue);
      expect(provider.step, HospitalReservationStep.selection);
      expect(provider.patientNumber, isEmpty);
    });

    test('따라 해보기는 오늘 내과 예약만 상세 화면으로 진행한다', () {
      final provider = HospitalReservationProvider()..begin(solo: false);
      provider.enterPatientCheck();
      for (final digit in '19580412'.split('')) {
        provider.addDigit(digit);
      }
      provider.verifyPatient();

      expect(
        provider.selectReservation(hospitalPracticeReservations[1]),
        isFalse,
      );
      expect(provider.step, HospitalReservationStep.selection);
      expect(provider.notice, contains('다시 확인'));
      expect(
        provider.selectReservation(hospitalPracticeReservations[0]),
        isTrue,
      );
      expect(provider.step, HospitalReservationStep.detail);
    });

    test('혼자 해보기 예약 시나리오 세 개가 완료 횟수에 따라 순환한다', () {
      final provider = HospitalReservationProvider();
      for (var i = 0; i < hospitalPracticeReservations.length; i++) {
        provider.begin(solo: true, completedCount: i);
        expect(provider.targetReservation, hospitalPracticeReservations[i]);
      }
      provider.begin(solo: true, completedCount: 3);
      expect(provider.targetReservation, hospitalPracticeReservations.first);
    });

    test('다른 예약 선택과 뒤로가기는 민감 입력과 이후 선택을 정리한다', () {
      final provider = HospitalReservationProvider()..begin(solo: false);
      provider.enterPatientCheck();
      provider.addDigit('1');
      provider.previous();
      expect(provider.patientNumber, isEmpty);
      expect(provider.step, HospitalReservationStep.service);

      provider.enterPatientCheck();
      for (final digit in '19580412'.split('')) {
        provider.addDigit(digit);
      }
      provider.verifyPatient();
      provider.selectReservation(hospitalPracticeReservations.first);
      provider.chooseAnotherReservation();
      expect(provider.selectedReservation, isNull);
      expect(provider.step, HospitalReservationStep.selection);
    });

    test('도움 안내는 현재 예약 단계와 선택을 유지한다', () {
      final provider = HospitalReservationProvider()..begin(solo: true);
      provider.enterPatientCheck();
      provider.requestHelp();
      expect(provider.step, HospitalReservationStep.patient);
      expect(provider.notice, contains('안내 데스크'));
    });
  });
}
