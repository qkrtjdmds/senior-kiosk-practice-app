import 'package:flutter/foundation.dart';

import '../learning/learning_progress_provider.dart';
import 'atm_withdrawal_models.dart';

class AtmWithdrawalProvider extends ChangeNotifier {
  AtmLearningMode mode = AtmLearningMode.guided;
  AtmV2Step step = AtmV2Step.services;
  AtmSoloScenario scenario = guidedAtmScenario;
  bool cardInserted = false;
  String _pin = '';
  AtmPracticeAccount? account;
  int? amount;
  bool transactionConfirmed = false;
  bool transactionProcessed = false;
  bool cardRetrieved = false;
  bool cashRetrieved = false;
  AtmReceiptChoice? receipt;
  bool showHint = false;
  String? notice;
  bool _busy = false;

  bool get isSolo => mode == AtmLearningMode.solo;
  int get pinLength => _pin.length;
  int get fee => scenario.fee;
  int get debitTotal => (amount ?? 0) + fee;
  bool get canComplete =>
      transactionProcessed && cardRetrieved && cashRetrieved && receipt != null;
  bool get busy => _busy;

  void begin(AtmLearningMode value, {int completedCount = 0}) {
    mode = value;
    scenario = value == AtmLearningMode.guided
        ? guidedAtmScenario
        : soloAtmScenarios[completedCount % soloAtmScenarios.length];
    reset();
  }

  void reset() {
    step = AtmV2Step.services;
    cardInserted = false;
    _pin = '';
    account = null;
    amount = null;
    transactionConfirmed = false;
    transactionProcessed = false;
    cardRetrieved = false;
    cashRetrieved = false;
    receipt = null;
    showHint = false;
    notice = null;
    _busy = false;
    notifyListeners();
  }

  bool chooseService(String service) {
    if (service != '현금 출금') {
      notice = '현재는 현금 출금 연습만 할 수 있어요.';
      notifyListeners();
      return false;
    }
    step = AtmV2Step.transaction;
    _accepted();
    return true;
  }

  bool chooseTransaction(String value) {
    if (value != '현금 출금') return _wrong('현금 출금을 다시 선택해 볼까요?');
    step = AtmV2Step.card;
    _accepted();
    return true;
  }

  void insertCard() {
    if (cardInserted) return;
    cardInserted = true;
    step = AtmV2Step.pin;
    _accepted();
  }

  void addPinDigit(String digit) {
    if (_pin.length >= 4) return;
    _pin += digit;
    notice = null;
    notifyListeners();
  }

  void removePinDigit() {
    if (_pin.isEmpty) return;
    _pin = _pin.substring(0, _pin.length - 1);
    notifyListeners();
  }

  void clearPin() {
    if (_pin.isEmpty) return;
    _pin = '';
    notifyListeners();
  }

  bool verifyPin() {
    if (!cardInserted) return _wrong('연습용 카드를 먼저 넣어 주세요.');
    if (_pin != '1234') {
      _pin = '';
      return _wrong('괜찮아요. 연습용 비밀번호 1234를 다시 눌러 볼까요?');
    }
    _pin = '';
    step = AtmV2Step.account;
    _accepted();
    return true;
  }

  bool chooseAccount(AtmPracticeAccount value) {
    if (value.type != scenario.account) return _wrong('미션의 계좌를 다시 살펴볼까요?');
    account = value;
    _clearAfterAccount();
    step = AtmV2Step.amount;
    _accepted();
    return true;
  }

  bool chooseAmount(int value) {
    if (!_validAmount(value)) return false;
    if (value != scenario.amount) return _wrong('찾을 금액을 다시 살펴볼까요?');
    amount = value;
    _clearAfterAmount();
    step = AtmV2Step.review;
    _accepted();
    return true;
  }

  bool enterAmount(String digits) {
    final parsed = int.tryParse(digits) ?? 0;
    return chooseAmount(parsed);
  }

  bool _validAmount(int value) {
    if (value < 10000 || value > 300000 || value % 10000 != 0) {
      notice = '1만 원 단위로 1만 원부터 30만 원까지 입력해 주세요.';
      notifyListeners();
      return false;
    }
    if (account == null || value + fee > account!.balance) {
      notice = '가상 계좌의 잔액 안에서 금액과 수수료를 확인해 주세요.';
      notifyListeners();
      return false;
    }
    return true;
  }

  void confirmTransaction() {
    if (account == null || amount == null || transactionConfirmed) return;
    transactionConfirmed = true;
    step = AtmV2Step.processing;
    _accepted();
  }

  Future<bool> processTransaction() async {
    if (_busy || !transactionConfirmed || transactionProcessed) return false;
    _busy = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    transactionProcessed = true;
    _busy = false;
    step = AtmV2Step.cardReturn;
    _accepted();
    return true;
  }

  void retrieveCard() {
    if (!transactionProcessed || cardRetrieved) return;
    cardRetrieved = true;
    step = AtmV2Step.cashReturn;
    _accepted();
  }

  void retrieveCash() {
    if (!cardRetrieved || cashRetrieved) return;
    cashRetrieved = true;
    step = AtmV2Step.receipt;
    _accepted();
  }

  bool chooseReceipt(AtmReceiptChoice value) {
    if (value != scenario.receipt) return _wrong('미션의 명세표 선택을 다시 살펴볼까요?');
    receipt = value;
    step = AtmV2Step.complete;
    _pin = '';
    _accepted();
    return true;
  }

  void requestHelp() {
    notice = '괜찮아요. 직원에게 도움을 요청하고 천천히 다시 해보세요.';
    notifyListeners();
  }

  void revealHint() {
    showHint = true;
    notice = null;
    notifyListeners();
  }

  String get hint => switch (step) {
    AtmV2Step.services || AtmV2Step.transaction => '현금 출금을 선택해 보세요.',
    AtmV2Step.card => '연습용 카드를 넣어 보세요.',
    AtmV2Step.pin => '연습용 비밀번호는 1234예요.',
    AtmV2Step.account =>
      '${scenario.account == AtmAccountType.checking ? '입출금' : '생활비'} 계좌를 골라 보세요.',
    AtmV2Step.amount => '${formatAtmWon(scenario.amount)}을 골라 보세요.',
    AtmV2Step.review => '금액과 가상 수수료를 확인한 뒤 거래를 진행해 보세요.',
    AtmV2Step.processing => '가상 출금 진행 버튼을 눌러 보세요.',
    AtmV2Step.cardReturn => '카드를 먼저 챙겨 주세요.',
    AtmV2Step.cashReturn => '현금을 챙겨 주세요.',
    AtmV2Step.receipt =>
      scenario.receipt == AtmReceiptChoice.receive
          ? '명세표 받기를 선택해 보세요.'
          : '명세표 받지 않기를 선택해 보세요.',
    AtmV2Step.complete => '연습을 모두 마쳤어요.',
  };

  String get summary => [
    if (account != null) account!.name,
    if (amount != null) formatAtmWon(amount!),
    if (cardRetrieved) '카드 챙김',
    if (cashRetrieved) '현금 챙김',
  ].join(' · ');

  void clearSensitiveState() {
    _pin = '';
  }

  void previous() {
    switch (step) {
      case AtmV2Step.services:
        return;
      case AtmV2Step.transaction:
        step = AtmV2Step.services;
      case AtmV2Step.card:
        step = AtmV2Step.transaction;
      case AtmV2Step.pin:
        cardInserted = false;
        _pin = '';
        step = AtmV2Step.card;
      case AtmV2Step.account:
        _pin = '';
        step = AtmV2Step.pin;
      case AtmV2Step.amount:
        account = null;
        _clearAfterAccount();
        step = AtmV2Step.account;
      case AtmV2Step.review:
        _clearAfterAmount();
        step = AtmV2Step.amount;
      case AtmV2Step.processing:
        transactionConfirmed = false;
        transactionProcessed = false;
        step = AtmV2Step.review;
      case AtmV2Step.cardReturn:
      case AtmV2Step.cashReturn:
      case AtmV2Step.receipt:
      case AtmV2Step.complete:
        return;
    }
    notice = null;
    showHint = false;
    notifyListeners();
  }

  void _clearAfterAccount() {
    amount = null;
    _clearAfterAmount();
  }

  void _clearAfterAmount() {
    transactionConfirmed = false;
    transactionProcessed = false;
    cardRetrieved = false;
    cashRetrieved = false;
    receipt = null;
  }

  bool _wrong(String message) {
    notice = message;
    notifyListeners();
    return false;
  }

  void _accepted() {
    notice = null;
    showHint = false;
    notifyListeners();
  }
}
