import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:han_geoleum_digital/app/app.dart';
import 'package:han_geoleum_digital/app/app_router.dart';
import 'package:han_geoleum_digital/app/app_routes.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';
import 'package:han_geoleum_digital/features/civil_document_v2/civil_document_models.dart';
import 'package:han_geoleum_digital/features/civil_document_v2/civil_document_provider.dart';

void main() {
  testWidgets('무인민원발급기 V2 혼자 해보기 전체 미션을 완료한다', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final progress = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    appRouter.go(AppRoutes.civilDocumentMission);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('오늘의 서류 발급 미션'), findsOneWidget);
    expect(find.textContaining('주민등록표 등본'), findsWidgets);
    await tester.tap(find.text('혼자 발급해 보기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('주민등록'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('주민등록표 등본'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('발급 안내를 확인했어요'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('본인 확인 연습 시작'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('지문 인식 시도'));
    await tester.pump();
    expect(find.textContaining('인식이 잘되지 않았어요'), findsOneWidget);
    await tester.tap(find.text('다시 인식하기'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -120));
    await tester.pump();
    await tester.tap(find.text('주민등록번호 뒷자리: 표시 안 함'));
    await tester.pump();
    await tester.ensureVisible(find.text('옵션 선택 완료'));
    await tester.tap(find.text('옵션 선택 완료'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('1부'));
    await tester.tap(find.text('1부'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('******-*******'));
    expect(find.text('******-*******'), findsOneWidget);
    await tester.tap(find.text('신청 내용 확인'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('카드'));
    await tester.pump();
    final kiosk = Provider.of<CivilDocumentV2Provider>(
      tester.element(find.text('가상 결제 연습')),
      listen: false,
    );
    expect(kiosk.payment, CivilPaymentMethod.card);
    await tester.tap(find.text('가상 결제 연습'));
    expect(kiosk.paymentProcessed, isTrue);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('카드를 챙겼어요'),
      160,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('카드를 챙겼어요'));
    await tester.pump();
    await tester.tap(find.text('증명서 출력으로'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('가상 출력 시작'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    await tester.tap(find.text('증명서 챙기기').last);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    await tester.tap(find.text('증명서 챙기기').last);
    await tester.pump();
    await tester.tap(find.text('개인정보 안전 종료'));
    await tester.pump();
    await tester.tap(find.text('연습 완료하기'));
    await tester.pumpAndSettle();

    expect(find.text('증명서 발급 연습 완료'), findsOneWidget);
    expect(find.textContaining('용기 포인트 +20점'), findsOneWidget);
    expect(progress.civilDocumentSoloCompletionCount, 1);
    expect(progress.totalPoints, 20);
    expect(tester.takeException(), isNull);
  });
  test('무인민원발급기 혼자 해보기 보상과 첫 배지는 한 번만 저장한다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);

    await progress.startCivilDocumentLearning(CivilDocumentLearningMode.solo);
    progress.selectCivilDocumentContent('기본 내용');
    progress.selectCivilDocumentCopies('한 부');
    expect(await progress.completeCivilDocumentSoloLearning(), isTrue);

    final reentered = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    expect(reentered.isCivilDocumentSoloMode, isTrue);
    expect(await reentered.completeCivilDocumentSoloLearning(), isFalse);
    expect(reentered.civilDocumentSoloCompletionCount, 1);
    expect(reentered.civilDocumentSoloFirstBadgeEarned, isTrue);
    expect(reentered.totalPoints, 20);
    expect(reentered.recentPracticeRecords, hasLength(1));
    expect(reentered.recentPracticeRecords.single.learningName, '무인민원발급기');
    expect(reentered.recentPracticeRecords.single.modeName, '혼자 해보기');

    final reloaded = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    expect(reloaded.civilDocumentSoloCompletionCount, 1);
    expect(reloaded.civilDocumentSoloFirstBadgeEarned, isTrue);
    expect(reloaded.totalPoints, 20);
  });
}
