import 'package:flutter_test/flutter_test.dart';

import 'package:han_geoleum_digital/features/atm_v2/atm_withdrawal_models.dart';
import 'package:han_geoleum_digital/features/atm_v2/atm_withdrawal_provider.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';

void main() {
  group('ATM V2 상태와 검증', () {
    late AtmWithdrawalProvider provider;

    setUp(() {
      provider = AtmWithdrawalProvider();
      provider.begin(AtmLearningMode.guided);
    });

    test('카드를 넣기 전에는 비밀번호 확인을 진행하지 않는다', () {
      for (final digit in '1234'.split('')) {
        provider.addPinDigit(digit);
      }
      expect(provider.verifyPin(), isFalse);
      expect(provider.step, AtmV2Step.services);
    });

    test('연습용 비밀번호 정답과 다른 입력을 구분하고 입력값을 지운다', () {
      provider.chooseService('현금 출금');
      provider.chooseTransaction('현금 출금');
      provider.insertCard();
      for (final digit in '1111'.split('')) {
        provider.addPinDigit(digit);
      }
      expect(provider.verifyPin(), isFalse);
      expect(provider.pinLength, 0);
      for (final digit in '1234'.split('')) {
        provider.addPinDigit(digit);
      }
      expect(provider.verifyPin(), isTrue);
      expect(provider.pinLength, 0);
      expect(provider.step, AtmV2Step.account);
    });

    test('PIN 한 글자와 전체 삭제가 동작하며 세션 초기화 후 남지 않는다', () {
      provider.addPinDigit('1');
      provider.addPinDigit('2');
      provider.removePinDigit();
      expect(provider.pinLength, 1);
      provider.clearPin();
      expect(provider.pinLength, 0);
      provider.addPinDigit('1');
      provider.reset();
      expect(provider.pinLength, 0);
    });

    test('출금 금액은 1만 원 단위, 범위, 잔액과 수수료를 검증한다', () {
      provider.account = atmPracticeAccounts.first;
      expect(provider.enterAmount('0'), isFalse);
      expect(provider.enterAmount('5000'), isFalse);
      expect(provider.enterAmount('15000'), isFalse);
      expect(provider.enterAmount('310000'), isFalse);
      provider.account = const AtmPracticeAccount(
        type: AtmAccountType.checking,
        name: '테스트',
        practiceName: '연습',
        balance: 40000,
      );
      expect(provider.enterAmount('50000'), isFalse);
    });

    test('계좌 변경은 금액 이후 상태를 초기화한다', () {
      provider.amount = 50000;
      provider.transactionConfirmed = true;
      provider.chooseAccount(atmPracticeAccounts.first);
      expect(provider.amount, isNull);
      expect(provider.transactionConfirmed, isFalse);
    });

    test('카드를 챙기기 전 현금 단계와 완료를 허용하지 않는다', () {
      expect(provider.cashRetrieved, isFalse);
      provider.retrieveCash();
      expect(provider.cashRetrieved, isFalse);
      expect(provider.canComplete, isFalse);
    });

    test('혼자 해보기 3개 시나리오는 완료 횟수에 따라 순환한다', () {
      for (var index = 0; index < 6; index++) {
        provider.begin(AtmLearningMode.solo, completedCount: index);
        expect(provider.scenario, same(soloAtmScenarios[index % 3]));
      }
    });

    test('거래 진행을 빠르게 두 번 요청해도 한 번만 처리한다', () async {
      provider.transactionConfirmed = true;
      final first = provider.processTransaction();
      final second = provider.processTransaction();
      expect(await second, isFalse);
      expect(await first, isTrue);
      expect(provider.transactionProcessed, isTrue);
    });
  });
}
