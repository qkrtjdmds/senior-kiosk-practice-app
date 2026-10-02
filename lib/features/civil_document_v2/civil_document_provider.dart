import 'package:flutter/foundation.dart';

import 'civil_document_models.dart';

class CivilDocumentV2Provider extends ChangeNotifier {
  CivilDocumentV2Mode mode = CivilDocumentV2Mode.guided;
  CivilDocumentV2Step step = CivilDocumentV2Step.categories;
  CivilDocumentScenario scenario = guidedCivilScenario;
  CivilDocumentCategory? category;
  CivilPracticeDocument? document;
  bool availabilityConfirmed = false;
  bool identityConfirmed = false;
  int fingerprintAttempts = 0;
  bool fingerprintConfirmed = false;
  final Map<String, String> options = {};
  int copies = 1;
  bool reviewConfirmed = false;
  CivilPaymentMethod? payment;
  bool paymentProcessed = false;
  bool cardRetrieved = false;
  bool cashInserted = false;
  bool changeRetrieved = false;
  bool printing = false;
  bool printed = false;
  bool documentRetrieved = false;
  bool safelyFinished = false;
  bool hintVisible = false;
  String? notice;
  bool _processing = false;

  bool get isSolo => mode == CivilDocumentV2Mode.solo;
  int get feePerCopy => document?.fee ?? 0;
  int get totalFee => feePerCopy * copies;
  bool get needsChange => payment == CivilPaymentMethod.cash;
  bool get canPrint =>
      paymentProcessed &&
      (payment == CivilPaymentMethod.card ? cardRetrieved : changeRetrieved);
  bool get canComplete => printed && documentRetrieved && safelyFinished;

  void begin(CivilDocumentV2Mode value, {int completedCount = 0}) {
    mode = value;
    scenario = value == CivilDocumentV2Mode.guided
        ? guidedCivilScenario
        : soloCivilScenarios[completedCount % soloCivilScenarios.length];
    _resetTemporary();
    notifyListeners();
  }

  void _resetTemporary() {
    step = CivilDocumentV2Step.categories;
    category = null;
    document = null;
    availabilityConfirmed = false;
    identityConfirmed = false;
    fingerprintAttempts = 0;
    fingerprintConfirmed = false;
    options.clear();
    copies = 1;
    reviewConfirmed = false;
    payment = null;
    paymentProcessed = false;
    cardRetrieved = false;
    cashInserted = false;
    changeRetrieved = false;
    printing = false;
    printed = false;
    documentRetrieved = false;
    safelyFinished = false;
    hintVisible = false;
    notice = null;
    _processing = false;
  }

  bool chooseCategory(CivilDocumentCategory value) {
    final expected = scenario.documentName.contains('가족')
        ? CivilDocumentCategory.family
        : CivilDocumentCategory.resident;
    if (value != expected) {
      return _wrong('오늘의 발급 목표에 맞는 분야를 다시 살펴볼까요?');
    }
    if (value != CivilDocumentCategory.resident &&
        value != CivilDocumentCategory.family) {
      return _wrong('이 분야는 연습 준비 중이에요. 현재 발급할 서류의 분야를 골라 볼까요?');
    }
    category = value;
    _clearAfterCategory();
    step = CivilDocumentV2Step.documents;
    return _ok();
  }

  bool chooseDocument(CivilPracticeDocument value) {
    if (value.name != scenario.documentName) {
      return _wrong('괜찮아요. 이번 연습의 증명서를 다시 확인해 볼까요?');
    }
    document = value;
    _clearAfterDocument();
    step = CivilDocumentV2Step.availability;
    return _ok();
  }

  void confirmAvailability() {
    availabilityConfirmed = true;
    step = CivilDocumentV2Step.identity;
    _ok();
  }

  void confirmIdentity() {
    identityConfirmed = true;
    step = CivilDocumentV2Step.fingerprint;
    _ok();
  }

  bool scanFingerprint() {
    fingerprintAttempts++;
    if (fingerprintAttempts == 1) {
      return _wrong('인식이 잘되지 않았어요. 손가락 위치와 압력을 조정해 다시 해볼까요?');
    }
    fingerprintConfirmed = true;
    step = CivilDocumentV2Step.options;
    notice = '가상 지문 인식 연습을 완료했어요.';
    notifyListeners();
    return true;
  }

  bool chooseOption(String key, String value) {
    final expected = scenario.options[key];
    if (expected != null && value != expected) {
      return _wrong('괜찮아요. 이번 연습에서는 $key을(를) $expected으로 골라 볼까요?');
    }
    options[key] = value;
    _clearAfterOptions();
    return _ok();
  }

  void finishOptions() {
    step = CivilDocumentV2Step.copies;
    _ok();
  }

  bool chooseCopies(int value) {
    if (value < 1 || value > 3) return false;
    if (value != scenario.copies) {
      return _wrong('괜찮아요. 오늘은 ${scenario.copies}부를 발급해 볼까요?');
    }
    copies = value;
    _clearAfterCopies();
    step = CivilDocumentV2Step.review;
    return _ok();
  }

  void confirmReview() {
    reviewConfirmed = true;
    step = CivilDocumentV2Step.payment;
    _ok();
  }

  bool choosePayment(CivilPaymentMethod value) {
    if (value != scenario.payment) return _wrong('이번 연습의 결제 방법을 다시 확인해 볼까요?');
    payment = value;
    _clearAfterPayment();
    return _ok();
  }

  Future<bool> processPayment() async {
    if (_processing || payment == null) return false;
    _processing = true;
    paymentProcessed = true;
    if (payment == CivilPaymentMethod.cash) cashInserted = true;
    notifyListeners();
    await Future<void>.delayed(Duration.zero);
    _processing = false;
    return true;
  }

  void retrieveCard() {
    if (paymentProcessed && payment == CivilPaymentMethod.card) {
      cardRetrieved = true;
      notifyListeners();
    }
  }

  void retrieveChange() {
    if (paymentProcessed && payment == CivilPaymentMethod.cash) {
      changeRetrieved = true;
      notifyListeners();
    }
  }

  Future<bool> startPrinting() async {
    if (_processing || !canPrint) return false;
    _processing = true;
    printing = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 350));
    printing = false;
    printed = true;
    step = CivilDocumentV2Step.collection;
    _processing = false;
    notifyListeners();
    return true;
  }

  void retrieveDocument() {
    if (printed) {
      documentRetrieved = true;
      notifyListeners();
    }
  }

  void finishSafely() {
    if (documentRetrieved) {
      safelyFinished = true;
      notifyListeners();
    }
  }

  void toggleHint() {
    hintVisible = !hintVisible;
    notifyListeners();
  }

  void requestHelp() {
    notice = '천천히 해도 괜찮아요. 현장에서는 직원에게 도움을 요청할 수 있어요.';
    notifyListeners();
  }

  void showNotice(String message) {
    notice = message;
    notifyListeners();
  }

  void goTo(CivilDocumentV2Step value) {
    step = value;
    notice = null;
    notifyListeners();
  }

  void _clearAfterCategory() {
    document = null;
    _clearAfterDocument();
  }

  void _clearAfterDocument() {
    availabilityConfirmed = false;
    identityConfirmed = false;
    fingerprintAttempts = 0;
    fingerprintConfirmed = false;
    options.clear();
    _clearAfterOptions();
  }

  void _clearAfterOptions() {
    reviewConfirmed = false;
    _clearAfterCopies();
  }

  void _clearAfterCopies() {
    payment = null;
    _clearAfterPayment();
  }

  void _clearAfterPayment() {
    paymentProcessed = false;
    cardRetrieved = false;
    cashInserted = false;
    changeRetrieved = false;
    printing = false;
    printed = false;
    documentRetrieved = false;
    safelyFinished = false;
  }

  bool _wrong(String message) {
    notice = message;
    notifyListeners();
    return false;
  }

  bool _ok() {
    notice = null;
    notifyListeners();
    return true;
  }
}
