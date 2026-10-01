import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:han_geoleum_digital/app/app.dart';
import 'package:han_geoleum_digital/app/app_router.dart';
import 'package:han_geoleum_digital/app/app_routes.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';
import 'package:han_geoleum_digital/features/atm_v2/atm_withdrawal_models.dart';

void main() {
  testWidgets('320dp와 아주 큰 글씨에서 ATM V2 주요 화면이 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final progress = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    await progress.setAccessibilityTextSize(AccessibilityTextSize.extraLarge);
    await progress.setScreenContrast(ScreenContrast.vivid);
    appRouter.go(AppRoutes.atmStart);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('ATM 출금 연습'), findsWidgets);
    expect(find.text('따라 해보기'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('혼자 해보기'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('혼자 해보기'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await progress.startAtmLearning(AtmLearningMode.guided);
    atmWithdrawalProvider.begin(AtmLearningMode.guided);
    appRouter.go(AppRoutes.atmV2Services);
    await tester.pumpAndSettle();
    expect(find.text('원하는 업무를 선택해 주세요'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ATM V2 거래 확인은 금액과 가상 수수료를 구분해 표시한다', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final progress = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    await progress.startAtmLearning(AtmLearningMode.guided);
    atmWithdrawalProvider.begin(AtmLearningMode.guided);
    final atm = atmWithdrawalProvider;
    atm.chooseService('현금 출금');
    atm.chooseTransaction('현금 출금');
    atm.insertCard();
    for (final digit in '1234'.split('')) {
      atm.addPinDigit(digit);
    }
    atm.verifyPin();
    atm.chooseAccount(atmPracticeAccounts.first);
    atm.chooseAmount(50000);
    appRouter.go(AppRoutes.atmV2Review);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('거래 내용을 확인해 주세요'), findsOneWidget);
    expect(find.text('가상 수수료'), findsOneWidget);
    expect(find.text('0원'), findsOneWidget);
    expect(find.text('차감 예정 가상 금액'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
