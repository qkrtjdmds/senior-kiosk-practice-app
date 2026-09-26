import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:han_geoleum_digital/app/app.dart';
import 'package:han_geoleum_digital/app/app_router.dart';
import 'package:han_geoleum_digital/app/app_routes.dart';
import 'package:han_geoleum_digital/features/cafe_v2/cafe_kiosk_widgets.dart';
import 'package:han_geoleum_digital/features/cafe_v2/cafe_order_provider.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';

void main() {
  test('카페 V2 장바구니는 여러 메뉴와 수량, 가상 금액을 계산한다', () {
    final order = CafeOrderProvider()..start(CafeLearningMode.guided);

    void add(String id, CafeTemperature temperature, CafeSize size) {
      final menu = cafeMenuItems.firstWhere((item) => item.id == id);
      expect(order.selectMenu(menu), isTrue);
      expect(order.selectTemperature(temperature), isTrue);
      expect(order.selectSize(size), isTrue);
      expect(order.selectDineOption(CafeDineOption.takeout), isTrue);
      order.addCurrentItem();
    }

    add('americano', CafeTemperature.iced, CafeSize.regular);
    add('vanilla_latte', CafeTemperature.hot, CafeSize.large);

    expect(order.cart, hasLength(2));
    expect(order.cartCount, 2);
    expect(order.totalPrice, 7800);

    order.changeQuantity(order.cart.first.id, 1);
    expect(order.cartCount, 3);
    expect(order.totalPrice, 10800);

    order.removeItem(order.cart.last.id);
    expect(order.cart, hasLength(1));
    expect(order.totalPrice, 6000);
  });

  test('혼자 해보기는 미션과 다른 선택에서 현재 상태를 유지한다', () {
    final order = CafeOrderProvider()..start(CafeLearningMode.solo);
    final wrongMenu = cafeMenuItems.firstWhere(
      (item) => item.id == 'cappuccino',
    );

    expect(order.selectMenu(wrongMenu), isFalse);
    expect(order.selectedMenu, isNull);
    expect(order.selectMenu(CafeOrderProvider.soloTargetMenu), isTrue);
    expect(order.selectTemperature(CafeTemperature.hot), isFalse);
    expect(order.temperature, isNull);
    expect(order.selectTemperature(CafeTemperature.iced), isTrue);
    expect(order.selectSize(CafeSize.large), isFalse);
    expect(order.selectSize(CafeSize.regular), isTrue);
    expect(order.selectDineOption(CafeDineOption.dineIn), isFalse);
    expect(order.selectDineOption(CafeDineOption.takeout), isTrue);
  });

  testWidgets('320dp 아주 큰 글씨에서 카페 V2 주요 화면이 넘치지 않는다', (tester) async {
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
    progress.selectMode(CafeLearningMode.guided);
    cafeOrderProvider.start(CafeLearningMode.guided);
    appRouter.go(AppRoutes.cafeV2Menu);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('커피'), findsOneWidget);
    expect(find.text('아메리카노'), findsOneWidget);
    final menuCards = find.byType(CafeMenuCard);
    expect(menuCards, findsWidgets);
    expect(
      tester.getTopLeft(menuCards.at(0)).dy,
      tester.getTopLeft(menuCards.at(1)).dy,
    );
    expect(tester.takeException(), isNull);

    expect(
      cafeOrderProvider.selectMenu(CafeOrderProvider.soloTargetMenu),
      isTrue,
    );
    appRouter.go(AppRoutes.cafeV2Temperature);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    cafeOrderProvider
      ..selectTemperature(CafeTemperature.iced)
      ..selectSize(CafeSize.regular)
      ..selectDineOption(CafeDineOption.takeout)
      ..addCurrentItem();
    final latte = cafeMenuItems.firstWhere(
      (item) => item.id == 'vanilla_latte',
    );
    cafeOrderProvider
      ..selectMenu(latte)
      ..selectTemperature(CafeTemperature.hot)
      ..selectSize(CafeSize.large)
      ..selectDineOption(CafeDineOption.takeout)
      ..addCurrentItem();
    final sandwich = cafeMenuItems.firstWhere((item) => item.id == 'sandwich');
    cafeOrderProvider
      ..selectMenu(sandwich)
      ..selectTemperature(CafeTemperature.none)
      ..selectSize(CafeSize.regular)
      ..selectDineOption(CafeDineOption.takeout)
      ..addCurrentItem();
    expect(cafeOrderProvider.cart, hasLength(3));
    appRouter.go(AppRoutes.cafeV2Cart);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('총 가상 금액'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('총 가상 금액'), findsOneWidget);
    expect(tester.takeException(), isNull);

    appRouter.go(AppRoutes.cafeV2Point);
    await tester.pumpAndSettle();
    expect(find.text('연습 화면입니다. 실제 적립은 되지 않아요.'), findsOneWidget);
    expect(tester.takeException(), isNull);

    cafeOrderProvider.selectPointMethod(CafePointMethod.none);
    appRouter.go(AppRoutes.cafeV2Payment);
    await tester.pumpAndSettle();
    expect(find.textContaining('실제 결제가 진행되지 않습니다.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
