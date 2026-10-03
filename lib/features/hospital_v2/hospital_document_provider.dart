import 'package:flutter/foundation.dart';

import 'hospital_payment_provider.dart';

enum HospitalDocumentStep {
  service,
  patient,
  document,
  purpose,
  copies,
  review,
  practice,
  complete,
}

class PracticeHospitalDocument {
  const PracticeHospitalDocument({
    required this.id,
    required this.name,
    required this.description,
    required this.fee,
    required this.kioskAvailable,
    this.counterNotice,
    this.isPracticeData = true,
  });

  final String id;
  final String name;
  final String description;
  final int fee;
  final bool kioskAvailable;
  final String? counterNotice;
  final bool isPracticeData;
}

const hospitalPracticeDocuments = <PracticeHospitalDocument>[
  PracticeHospitalDocument(
    id: 'visit-confirmation',
    name: '통원확인서',
    description: '병원에 방문한 사실을 확인하는 연습용 서류',
    fee: 3000,
    kioskAvailable: true,
  ),
  PracticeHospitalDocument(
    id: 'treatment-confirmation',
    name: '진료확인서',
    description: '진료받은 사실을 확인하는 연습용 서류',
    fee: 3000,
    kioskAvailable: true,
  ),
  PracticeHospitalDocument(
    id: 'payment-confirmation',
    name: '진료비 납입확인서',
    description: '가상 진료비 납부 내용을 확인하는 연습용 서류',
    fee: 1000,
    kioskAvailable: true,
  ),
  PracticeHospitalDocument(
    id: 'prescription-copy',
    name: '처방전 사본',
    description: '처방전 사본 발급 과정을 익히는 연습용 서류',
    fee: 500,
    kioskAvailable: true,
  ),
  PracticeHospitalDocument(
    id: 'diagnosis-certificate',
    name: '진단서',
    description: '의사 확인이나 원무창구 방문이 필요할 수 있는 서류',
    fee: 0,
    kioskAvailable: false,
    counterNotice: '이 서류는 실제 병원에서 의사 확인이나 원무창구 방문이 필요할 수 있어요.',
  ),
];

const hospitalDocumentPurposes = <String>[
  '보험회사 제출',
  '회사 제출',
  '학교·기관 제출',
  '개인 보관',
  '기타',
];

class HospitalDocumentScenario {
  const HospitalDocumentScenario({
    required this.id,
    required this.documentId,
    required this.purpose,
    required this.copies,
    required this.paymentMethod,
  });

  final String id;
  final String documentId;
  final String purpose;
  final int copies;
  final HospitalPaymentMethod paymentMethod;
}

const hospitalDocumentScenarios = <HospitalDocumentScenario>[
  HospitalDocumentScenario(
    id: 'document-visit-insurance-card',
    documentId: 'visit-confirmation',
    purpose: '보험회사 제출',
    copies: 1,
    paymentMethod: HospitalPaymentMethod.card,
  ),
  HospitalDocumentScenario(
    id: 'document-payment-company-mobile',
    documentId: 'payment-confirmation',
    purpose: '회사 제출',
    copies: 2,
    paymentMethod: HospitalPaymentMethod.mobile,
  ),
  HospitalDocumentScenario(
    id: 'document-prescription-personal-card',
    documentId: 'prescription-copy',
    purpose: '개인 보관',
    copies: 1,
    paymentMethod: HospitalPaymentMethod.card,
  ),
];

class HospitalDocumentProvider extends ChangeNotifier {
  HospitalDocumentStep step = HospitalDocumentStep.service;
  bool isSolo = false;
  bool isFreePractice = false;
  int scenarioIndex = 0;
  String patientNumber = '';
  PracticeHospitalDocument? selectedDocument;
  String? purpose;
  int copies = 1;
  HospitalPaymentMethod? paymentMethod;
  int paymentActionIndex = 0;
  bool printingComplete = false;
  bool documentTaken = false;
  String? notice;
  bool showHint = false;

  int get stepNumber => step.index + 1;
  int get totalSteps => HospitalDocumentStep.values.length;
  HospitalDocumentScenario get scenario =>
      hospitalDocumentScenarios[isSolo ? scenarioIndex : 0];
  PracticeHospitalDocument get targetDocument => hospitalPracticeDocuments
      .firstWhere((document) => document.id == scenario.documentId);
  bool get patientNumberComplete => patientNumber == '19580412';
  int get totalFee => (selectedDocument?.fee ?? 0) * copies;
  bool get paymentComplete =>
      paymentActionIndex >= paymentActions.length && paymentMethod != null;

  List<String> get paymentActions => switch (paymentMethod) {
    HospitalPaymentMethod.card => const [
      '카드를 넣었어요',
      '가상 금액을 확인했어요',
      '가상 결제를 진행했어요',
      '카드를 챙겼어요',
    ],
    HospitalPaymentMethod.mobile => const [
      '휴대전화를 준비했어요',
      '가상 인식 위치를 확인했어요',
      '금액을 확인했어요',
      '가상 결제를 진행했어요',
    ],
    HospitalPaymentMethod.cash => const ['원무창구 안내를 확인했어요'],
    null => const [],
  };

  void begin({required bool solo, int completedCount = 0}) {
    isSolo = solo;
    isFreePractice = false;
    scenarioIndex = solo
        ? completedCount % hospitalDocumentScenarios.length
        : 0;
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
    step = HospitalDocumentStep.patient;
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
    step = HospitalDocumentStep.document;
    _clearFeedback();
    notifyListeners();
    return true;
  }

  bool selectDocument(PracticeHospitalDocument document) {
    if (!document.kioskAvailable) {
      notice = document.counterNotice;
      notifyListeners();
      return false;
    }
    if (!isFreePractice && document.id != targetDocument.id) {
      notice = '괜찮아요. 필요한 서류를 다시 확인해 볼까요?';
      notifyListeners();
      return false;
    }
    if (selectedDocument?.id != document.id) {
      purpose = null;
      copies = 1;
      _resetPayment();
    }
    selectedDocument = document;
    step = HospitalDocumentStep.purpose;
    _clearFeedback();
    notifyListeners();
    return true;
  }

  bool selectPurpose(String value) {
    if (!isFreePractice && value != scenario.purpose) {
      notice = '괜찮아요. 제출할 곳을 다시 확인해 볼까요?';
      notifyListeners();
      return false;
    }
    purpose = value;
    copies = 1;
    step = HospitalDocumentStep.copies;
    _clearFeedback();
    notifyListeners();
    return true;
  }

  bool selectCopies(int value) {
    if (value < 1 || value > 3) return false;
    if (!isFreePractice && value != scenario.copies) {
      notice = '괜찮아요. 필요한 발급 부수를 다시 확인해 볼까요?';
      notifyListeners();
      return false;
    }
    copies = value;
    step = HospitalDocumentStep.review;
    _clearFeedback();
    notifyListeners();
    return true;
  }

  void editApplication() {
    step = HospitalDocumentStep.document;
    _clearFeedback();
    notifyListeners();
  }

  void continueToPayment() {
    if (selectedDocument == null || purpose == null) return;
    step = HospitalDocumentStep.practice;
    _clearFeedback();
    notifyListeners();
  }

  bool choosePaymentMethod(HospitalPaymentMethod method) {
    if (!isFreePractice && method != scenario.paymentMethod) {
      notice = '괜찮아요. 연습 목표의 결제 방법을 다시 확인해 볼까요?';
      notifyListeners();
      return false;
    }
    paymentMethod = method;
    paymentActionIndex = 0;
    printingComplete = false;
    documentTaken = false;
    _clearFeedback();
    notifyListeners();
    return true;
  }

  void advancePayment() {
    if (paymentActionIndex < paymentActions.length) {
      paymentActionIndex++;
      notifyListeners();
    }
  }

  void completePrinting() {
    if (!paymentComplete) return;
    printingComplete = true;
    notifyListeners();
  }

  void takeDocument() {
    if (!printingComplete) return;
    documentTaken = true;
    notifyListeners();
  }

  bool finish() {
    if (!documentTaken) return false;
    patientNumber = '';
    step = HospitalDocumentStep.complete;
    notifyListeners();
    return true;
  }

  void toggleHint() {
    showHint = !showHint;
    notifyListeners();
  }

  void requestHelp() {
    notice = '연습 화면이에요. 실제 병원에서는 주변 직원이나 원무창구에 도움을 요청하세요.';
    notifyListeners();
  }

  void previous() {
    switch (step) {
      case HospitalDocumentStep.service:
        break;
      case HospitalDocumentStep.patient:
        patientNumber = '';
        step = HospitalDocumentStep.service;
      case HospitalDocumentStep.document:
        patientNumber = '';
        step = HospitalDocumentStep.patient;
      case HospitalDocumentStep.purpose:
        step = HospitalDocumentStep.document;
        purpose = null;
      case HospitalDocumentStep.copies:
        step = HospitalDocumentStep.purpose;
        copies = 1;
      case HospitalDocumentStep.review:
        step = HospitalDocumentStep.copies;
      case HospitalDocumentStep.practice:
        step = HospitalDocumentStep.review;
        _resetPayment();
      case HospitalDocumentStep.complete:
        break;
    }
    _clearFeedback();
    notifyListeners();
  }

  void reset({bool notify = true}) {
    step = HospitalDocumentStep.service;
    patientNumber = '';
    selectedDocument = null;
    purpose = null;
    copies = 1;
    _resetPayment();
    _clearFeedback();
    if (notify) notifyListeners();
  }

  void _resetPayment() {
    paymentMethod = null;
    paymentActionIndex = 0;
    printingComplete = false;
    documentTaken = false;
  }

  void _clearFeedback() {
    notice = null;
    showHint = false;
  }
}

String hospitalDocumentPaymentLabel(HospitalPaymentMethod method) =>
    hospitalPaymentMethodLabel(method);
