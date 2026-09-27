import 'burger_order_provider.dart';

class BurgerScenario {
  const BurgerScenario({
    required this.title,
    required this.dine,
    required this.menu,
    required this.type,
    this.side,
    this.drink,
    this.extras = const {},
    required this.point,
    required this.payment,
  });
  final String title;
  final String dine;
  final String menu;
  final BurgerOrderType type;
  final String? side;
  final String? drink;
  final Set<String> extras;
  final String point;
  final String payment;

  static BurgerScenario fromMissionId(String id) => switch (id) {
    'bulgogi_single_dine_in' => const BurgerScenario(
      title: '불고기버거 세트 포장 주문',
      dine: '포장하기',
      menu: '불고기버거',
      type: BurgerOrderType.set,
      side: '감자튀김',
      drink: '제로 콜라',
      point: '간편 적립',
      payment: '간편결제',
    ),
    'shrimp_set_dine_in' => const BurgerScenario(
      title: '새우버거 세트 매장 주문',
      dine: '매장에서 먹기',
      menu: '새우버거',
      type: BurgerOrderType.set,
      side: '치즈스틱',
      drink: '사이다',
      point: '전화번호로 적립',
      payment: '현금',
    ),
    _ => const BurgerScenario(
      title: '치즈버거 단품 매장 주문',
      dine: '매장에서 먹기',
      menu: '치즈버거',
      type: BurgerOrderType.single,
      extras: {'치즈 추가'},
      point: '적립하지 않기',
      payment: '카드',
    ),
  };

  String get summary => [
    dine,
    menu,
    type == BurgerOrderType.set ? '세트' : '단품',
    side,
    drink,
    ...extras,
    point,
    payment,
  ].whereType<String>().join(' · ');
}
