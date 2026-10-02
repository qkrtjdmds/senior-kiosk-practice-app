import 'package:flutter_test/flutter_test.dart';
import 'package:han_geoleum_digital/features/civil_document_v2/civil_document_models.dart';
import 'package:han_geoleum_digital/features/civil_document_v2/civil_document_provider.dart';

void main() {
  group('무인민원발급기 V2', () {
    late CivilDocumentV2Provider provider;
    setUp(() {
      provider = CivilDocumentV2Provider()..begin(CivilDocumentV2Mode.guided);
    });

    test('혼자 해보기 3개 시나리오가 완료 횟수에 따라 순환한다', () {
      for (var index = 0; index < 6; index++) {
        provider.begin(CivilDocumentV2Mode.solo, completedCount: index);
        expect(provider.scenario, same(soloCivilScenarios[index % 3]));
      }
    });

    test('따라 해보기는 다른 분야를 선택해도 현재 단계에 머문다', () {
      expect(provider.chooseCategory(CivilDocumentCategory.family), isFalse);
      expect(provider.step, CivilDocumentV2Step.categories);
      expect(provider.category, isNull);
      expect(provider.notice, contains('다시 살펴볼까요'));
    });

    test('지문 연습은 첫 시도 후 재시도로 완료한다', () {
      expect(provider.scanFingerprint(), isFalse);
      expect(provider.fingerprintAttempts, 1);
      expect(provider.fingerprintConfirmed, isFalse);
      expect(provider.scanFingerprint(), isTrue);
      expect(provider.fingerprintConfirmed, isTrue);
      expect(provider.step, CivilDocumentV2Step.options);
    });

    test('기본 시나리오는 주민등록번호 뒷자리를 표시하지 않는다', () {
      expect(guidedCivilScenario.options['주민등록번호 뒷자리'], '표시 안 함');
    });

    test('발급 부수는 1~3부만 허용하고 가상 수수료를 계산한다', () {
      provider.document = civilPracticeDocuments.first;
      expect(provider.chooseCopies(0), isFalse);
      expect(provider.chooseCopies(4), isFalse);
      expect(provider.chooseCopies(1), isTrue);
      expect(provider.totalFee, 200);
    });

    test('카드 회수 전에는 출력할 수 없다', () async {
      provider.payment = CivilPaymentMethod.card;
      await provider.processPayment();
      expect(provider.canPrint, isFalse);
      expect(await provider.startPrinting(), isFalse);
      provider.retrieveCard();
      expect(provider.canPrint, isTrue);
    });

    test('현금 결제는 잔돈 회수 전에 출력할 수 없다', () async {
      provider.payment = CivilPaymentMethod.cash;
      await provider.processPayment();
      expect(provider.canPrint, isFalse);
      provider.retrieveChange();
      expect(provider.canPrint, isTrue);
    });

    test('출력 전에 증명서를 회수하거나 완료할 수 없다', () {
      provider.retrieveDocument();
      provider.finishSafely();
      expect(provider.documentRetrieved, isFalse);
      expect(provider.canComplete, isFalse);
    });

    test('결제와 출력을 빠르게 두 번 요청해도 한 번만 처리한다', () async {
      provider.payment = CivilPaymentMethod.card;
      final firstPayment = provider.processPayment();
      final secondPayment = provider.processPayment();
      expect(await secondPayment, isFalse);
      expect(await firstPayment, isTrue);
      provider.retrieveCard();
      final firstPrint = provider.startPrinting();
      final secondPrint = provider.startPrinting();
      expect(await secondPrint, isFalse);
      expect(await firstPrint, isTrue);
      expect(provider.printed, isTrue);
    });

    test('증명서를 변경하면 본인 확인부터 후속 상태가 초기화된다', () {
      provider.identityConfirmed = true;
      provider.printed = true;
      provider.chooseDocument(civilPracticeDocuments.first);
      expect(provider.identityConfirmed, isFalse);
      expect(provider.printed, isFalse);
    });
  });
}
