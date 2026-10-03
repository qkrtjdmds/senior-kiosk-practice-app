import 'package:flutter/foundation.dart';

enum HospitalPaymentStep {
  service,
  patient,
  selection,
  detail,
  method,
  practice,
  complete,
}

enum HospitalPaymentMethod { card, mobile, cash }

class PracticeMedicalBill {
  const PracticeMedicalBill({
    required this.id,
    required this.dateLabel,
    required this.department,
    required this.description,
    required this.amount,
    required this.status,
    required this.canPay,
    this.isPracticeData = true,
  });

  final String id;
  final String dateLabel;
  final String department;
  final String description;
  final int amount;
  final String status;
  final bool canPay;
  final bool isPracticeData;
}

const hospitalPracticeBills = <PracticeMedicalBill>[
  PracticeMedicalBill(
    id: 'bill-today-internal-18500',
    dateLabel: '오늘',
    department: '내과',
    description: '진찰료',
    amount: 18500,
    status: '미납',
    canPay: true,
  ),
  PracticeMedicalBill(
    id: 'bill-yesterday-orthopedics-32000',
    dateLabel: '어제',
    department: '정형외과',
    description: '진찰료 및 가상 검사비',
    amount: 32000,
    status: '미납',
    canPay: true,
  ),
  PracticeMedicalBill(
    id: 'bill-last-week-ent-12700',
    dateLabel: '지난주',
    department: '이비인후과',
    description: '진찰료',
    amount: 12700,
    status: '납부 완료',
    canPay: false,
  ),
];

class HospitalPaymentScenario {
  const HospitalPaymentScenario({
    required this.id,
    required this.billId,
    required this.method,
    required this.wantsReceipt,
  });

  final String id;
  final String billId;
  final HospitalPaymentMethod method;
  final bool? wantsReceipt;
}

const hospitalPaymentScenarios = <HospitalPaymentScenario>[
  HospitalPaymentScenario(
    id: 'payment-card-receipt',
    billId: 'bill-today-internal-18500',
    method: HospitalPaymentMethod.card,
    wantsReceipt: true,
  ),
  HospitalPaymentScenario(
    id: 'payment-mobile-no-receipt',
    billId: 'bill-yesterday-orthopedics-32000',
    method: HospitalPaymentMethod.mobile,
    wantsReceipt: false,
  ),
  HospitalPaymentScenario(
    id: 'payment-cash-desk',
    billId: 'bill-today-internal-18500',
    method: HospitalPaymentMethod.cash,
    wantsReceipt: null,
  ),
];

class HospitalPaymentProvider extends ChangeNotifier {
  HospitalPaymentStep step = HospitalPaymentStep.service;
  bool isSolo = false;
  bool isFreePractice = false;
  int scenarioIndex = 0;
  String patientNumber = '';
  PracticeMedicalBill? selectedBill;
  HospitalPaymentMethod? paymentMethod;
  int practiceActionIndex = 0;
  bool? wantsReceipt;
  String? notice;
  bool showHint = false;

  int get stepNumber => step.index + 1;
  int get totalSteps => HospitalPaymentStep.values.length;
  HospitalPaymentScenario get scenario =>
      hospitalPaymentScenarios[isSolo ? scenarioIndex : 0];
  PracticeMedicalBill get targetBill =>
      hospitalPracticeBills.firstWhere((bill) => bill.id == scenario.billId);
  HospitalPaymentMethod get targetMethod => scenario.method;
  bool get patientNumberComplete => patientNumber == '19580412';
  bool get practiceComplete => paymentMethod == HospitalPaymentMethod.cash
      ? practiceActionIndex >= 1
      : practiceActionIndex >= practiceActions.length;
  List<String> get practiceActions => switch (paymentMethod) {
    HospitalPaymentMethod.card => const [
      '카드를 넣었어요',
      '금액을 확인했어요',
      '결제 연습 진행',
      '카드를 챙겼어요',
    ],
    HospitalPaymentMethod.mobile => const [
      '휴대전화를 준비했어요',
      '인식 위치에 가까이 댔어요',
      '결제 금액을 확인했어요',
    ],
    HospitalPaymentMethod.cash => const ['원무창구 안내를 확인했어요'],
    null => const [],
  };

  void begin({required bool solo, int completedCount = 0}) {
    isSolo = solo;
    isFreePractice = false;
    scenarioIndex = solo ? completedCount % hospitalPaymentScenarios.length : 0;
    reset(notify: false);
    notifyListeners();
  }

  void beginFreePractice() {
    isSolo = false;
    isFreePractice = true;
    scenarioIndex = 0;
    reset();
  }

  void enterPatientCheck() {
    patientNumber = '';
    step = HospitalPaymentStep.patient;
    _clearFeedback();
    notifyListeners();
  }

  void addDigit(String digit) {
    if (patientNumber.length >= 8) return;
    patientNumber += digit;
    notice = null;
    notifyListeners();
  }

  void removeDigit() {
    if (patientNumber.isEmpty) return;
    patientNumber = patientNumber.substring(0, patientNumber.length - 1);
    notifyListeners();
  }

  void clearPatientNumber() {
    patientNumber = '';
    notice = null;
    notifyListeners();
  }

  bool verifyPatient() {
    if (!patientNumberComplete) {
      notice = '괜찮아요. 연습용 생년월일 1958년 4월 12일을 다시 확인해 볼까요?';
      notifyListeners();
      return false;
    }
    patientNumber = '';
    step = HospitalPaymentStep.selection;
    _clearFeedback();
    notifyListeners();
    return true;
  }

  bool selectBill(PracticeMedicalBill bill) {
    if (!bill.canPay) {
      notice = '이 내역은 이미 납부가 완료되었어요. 미납 내역을 선택해 주세요.';
      notifyListeners();
      return false;
    }
    if (!isFreePractice && bill.id != targetBill.id) {
      notice = '괜찮아요. 날짜와 진료과, 금액을 다시 확인해 볼까요?';
      notifyListeners();
      return false;
    }
    selectedBill = bill;
    _resetPaymentChoices();
    step = HospitalPaymentStep.detail;
    _clearFeedback();
    notifyListeners();
    return true;
  }

  void chooseAnotherBill() {
    selectedBill = null;
    _resetPaymentChoices();
    step = HospitalPaymentStep.selection;
    _clearFeedback();
    notifyListeners();
  }

  void continueToMethod() {
    if (selectedBill == null) return;
    step = HospitalPaymentStep.method;
    _clearFeedback();
    notifyListeners();
  }

  bool chooseMethod(HospitalPaymentMethod method) {
    if (!isFreePractice && method != targetMethod) {
      notice = '괜찮아요. 연습 목표의 결제 방법을 다시 확인해 볼까요?';
      notifyListeners();
      return false;
    }
    paymentMethod = method;
    practiceActionIndex = 0;
    wantsReceipt = null;
    step = HospitalPaymentStep.practice;
    _clearFeedback();
    notifyListeners();
    return true;
  }

  void advancePractice() {
    if (practiceActionIndex < practiceActions.length) {
      practiceActionIndex++;
      notifyListeners();
    }
  }

  bool chooseReceipt(bool value) {
    if (!practiceComplete) return false;
    if (!isFreePractice &&
        scenario.wantsReceipt != null &&
        value != scenario.wantsReceipt) {
      notice = '괜찮아요. 연습 목표의 영수증 선택을 다시 확인해 볼까요?';
      notifyListeners();
      return false;
    }
    wantsReceipt = value;
    notice = null;
    notifyListeners();
    return true;
  }

  void finish() {
    if (!practiceComplete) return;
    if (paymentMethod != HospitalPaymentMethod.cash && wantsReceipt == null) {
      return;
    }
    patientNumber = '';
    step = HospitalPaymentStep.complete;
    notifyListeners();
  }

  void toggleHint() {
    showHint = !showHint;
    notifyListeners();
  }

  void requestHelp() {
    notice = '연습 화면입니다. 실제 병원에서는 주변 직원이나 원무창구에 도움을 요청하세요.';
    notifyListeners();
  }

  void previous() {
    switch (step) {
      case HospitalPaymentStep.service:
        break;
      case HospitalPaymentStep.patient:
        patientNumber = '';
        step = HospitalPaymentStep.service;
        break;
      case HospitalPaymentStep.selection:
        patientNumber = '';
        step = HospitalPaymentStep.patient;
        break;
      case HospitalPaymentStep.detail:
        chooseAnotherBill();
        return;
      case HospitalPaymentStep.method:
        step = HospitalPaymentStep.detail;
        _resetPaymentChoices();
        break;
      case HospitalPaymentStep.practice:
        step = HospitalPaymentStep.method;
        _resetPaymentChoices();
        break;
      case HospitalPaymentStep.complete:
        break;
    }
    _clearFeedback();
    notifyListeners();
  }

  void reset({bool notify = true}) {
    step = HospitalPaymentStep.service;
    patientNumber = '';
    selectedBill = null;
    _resetPaymentChoices();
    _clearFeedback();
    if (notify) notifyListeners();
  }

  void _resetPaymentChoices() {
    paymentMethod = null;
    practiceActionIndex = 0;
    wantsReceipt = null;
  }

  void _clearFeedback() {
    notice = null;
    showHint = false;
  }
}

String formatPracticeWon(int amount) {
  final digits = amount.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) buffer.write(',');
    buffer.write(digits[index]);
  }
  return '$buffer원';
}

String hospitalPaymentMethodLabel(HospitalPaymentMethod method) =>
    switch (method) {
      HospitalPaymentMethod.card => '카드',
      HospitalPaymentMethod.mobile => '간편결제',
      HospitalPaymentMethod.cash => '현금',
    };
