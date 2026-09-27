import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:han_geoleum_digital/app/app.dart';
import 'package:han_geoleum_digital/app/app_router.dart';
import 'package:han_geoleum_digital/app/app_routes.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';
import 'package:han_geoleum_digital/features/hamburger_v2/burger_order_provider.dart';
import 'package:han_geoleum_digital/features/hamburger_v2/burger_scenario.dart';

void main() {
  testWidgets('320dp 아주 큰 글씨에서 햄버거 V2 시작과 주문 화면이 넘치지 않는다', (tester) async {
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
    appRouter.go(AppRoutes.hamburgerStart);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('가상 키오스크로 주문 순서를 천천히 연습해요.'), findsOneWidget);
    expect(find.text('따라 해보기'), findsOneWidget);
    expect(find.text('혼자 해보기'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('따라 해보기'));
    await tester.pumpAndSettle();
    expect(find.text('1 / 9 단계'), findsOneWidget);
    expect(find.text('어디에서 드시나요?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  test('장바구니는 복수 메뉴, 수량, 옵션 가격과 삭제를 관리한다', () {
    final order = BurgerOrderProvider()..begin(HamburgerLearningMode.guided);
    order.chooseDine('포장하기', correct: true);
    order.chooseMenu(BurgerOrderProvider.menus.first, correct: true);
    order.chooseType(BurgerOrderType.set, correct: true);
    order.chooseSide('감자튀김', correct: true);
    order.chooseDrink('콜라', correct: true);
    order.toggleExtra('치즈 추가');
    order.addToCart();
    expect(order.cartCount, 1);
    expect(order.totalPrice, BurgerOrderProvider.menus.first.price + 3000);
    order.changeQuantity(0, 1);
    expect(order.cartCount, 2);
    order.addAnother();
    order.chooseMenu(BurgerOrderProvider.menus[1], correct: true);
    order.chooseType(BurgerOrderType.single, correct: true);
    order.addToCart();
    expect(order.cart, hasLength(2));
    order.removeItem(1);
    expect(order.cart, hasLength(1));
    order.removeItem(0);
    expect(order.cart, isEmpty);
  });

  test('혼자 해보기 세 시나리오는 모두 실제 주문 데이터와 일치한다', () {
    const ids = [
      'cheese_set_takeout',
      'bulgogi_single_dine_in',
      'shrimp_set_dine_in',
    ];
    const pointMethods = {'전화번호로 적립', '간편 적립', '적립하지 않기'};
    const paymentMethods = {'카드', '간편결제', '현금'};
    for (final id in ids) {
      final scenario = BurgerScenario.fromMissionId(id);
      expect(
        BurgerOrderProvider.menus.any((menu) => menu.name == scenario.menu),
        isTrue,
      );
      if (scenario.side != null) {
        expect(BurgerOrderProvider.sides, contains(scenario.side));
      }
      if (scenario.drink != null) {
        expect(BurgerOrderProvider.drinks, contains(scenario.drink));
      }
      expect(
        scenario.extras.every(BurgerOrderProvider.extraPrices.containsKey),
        isTrue,
      );
      expect(pointMethods, contains(scenario.point));
      expect(paymentMethods, contains(scenario.payment));
    }
  });
  test('세트에서 단품으로 바꾸면 사이드와 음료가 완전히 정리된다', () {
    final order = BurgerOrderProvider()..begin(HamburgerLearningMode.guided);
    order.chooseDine('포장하기', correct: true);
    order.chooseMenu(BurgerOrderProvider.menus.first, correct: true);
    order.chooseType(BurgerOrderType.set, correct: true);
    order.chooseSide('감자튀김', correct: true);
    order.chooseDrink('콜라', correct: true);
    order.previous();
    order.previous();
    order.previous();
    order.chooseType(BurgerOrderType.single, correct: true);

    expect(order.step, BurgerOrderStep.extras);
    expect(order.side, isNull);
    expect(order.drink, isNull);
  });

  test('메뉴를 바꾸면 이전 메뉴의 하위 선택과 옵션을 정리한다', () {
    final order = BurgerOrderProvider()..begin(HamburgerLearningMode.guided);
    order.chooseDine('포장하기', correct: true);
    order.chooseMenu(BurgerOrderProvider.menus.first, correct: true);
    order.chooseType(BurgerOrderType.single, correct: true);
    order.toggleExtra('치즈 추가');
    order.previous();
    order.previous();
    order.chooseMenu(BurgerOrderProvider.menus[1], correct: true);

    expect(order.orderType, isNull);
    expect(order.side, isNull);
    expect(order.drink, isNull);
    expect(order.extras, isEmpty);
  });

  test('서로 다른 메뉴 세 개를 담고 중간 항목을 삭제해 합계를 다시 계산한다', () {
    final order = BurgerOrderProvider()..begin(HamburgerLearningMode.guided);
    order.chooseDine('포장하기', correct: true);
    for (var i = 0; i < 3; i++) {
      order.chooseMenu(BurgerOrderProvider.menus[i], correct: true);
      order.chooseType(BurgerOrderType.single, correct: true);
      order.addToCart();
      if (i < 2) order.addAnother();
    }
    final originalTotal = order.totalPrice;
    final middlePrice = order.cart[1].totalPrice;

    order.removeItem(1);

    expect(order.cart, hasLength(2));
    expect(order.totalPrice, originalTotal - middlePrice);
    order.removeItem(1);
    order.removeItem(0);
    expect(order.cart, isEmpty);
    order.proceedFromCart();
    expect(order.step, BurgerOrderStep.cart);
  });
  test('추가 옵션은 복수 선택과 해제가 가격에 정확히 반영된다', () {
    final order = BurgerOrderProvider()..begin(HamburgerLearningMode.guided);
    order.chooseDine('포장하기', correct: true);
    order.chooseMenu(BurgerOrderProvider.menus.first, correct: true);
    order.chooseType(BurgerOrderType.single, correct: true);
    order.toggleExtra('치즈 추가');
    order.toggleExtra('패티 추가');
    order.toggleExtra('소스 빼기');
    order.toggleExtra('소스 빼기');
    order.addToCart();

    expect(order.cart.single.extras, {'치즈 추가', '패티 추가'});
    expect(order.totalPrice, BurgerOrderProvider.menus.first.price + 2000);
  });
  test('장바구니에서 이전으로 가면 담은 메뉴를 유지하고 메뉴판으로 돌아간다', () {
    final order = BurgerOrderProvider()..begin(HamburgerLearningMode.guided);
    order.chooseDine('포장하기', correct: true);
    order.chooseMenu(BurgerOrderProvider.menus.first, correct: true);
    order.chooseType(BurgerOrderType.single, correct: true);
    order.addToCart();

    order.previous();

    expect(order.step, BurgerOrderStep.menu);
    expect(order.cart, hasLength(1));
  });
  test('단품은 사이드와 음료를 건너뛰고 혼자 해보기 오선택은 현재 단계에 머문다', () {
    final order = BurgerOrderProvider()..begin(HamburgerLearningMode.solo);
    order.chooseDine('매장에서 먹기', correct: false);
    expect(order.step, BurgerOrderStep.dine);
    expect(order.inlineMessage, isNotNull);
    order.chooseDine('포장하기', correct: true);
    order.chooseMenu(BurgerOrderProvider.menus[1], correct: true);
    order.chooseType(BurgerOrderType.single, correct: true);
    expect(order.step, BurgerOrderStep.extras);
    expect(order.side, isNull);
    expect(order.drink, isNull);
  });
}
