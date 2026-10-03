import 'package:flutter/foundation.dart';

import '../learning/learning_progress_provider.dart';

enum BurgerOrderStep {
  dine,
  menu,
  type,
  side,
  drink,
  extras,
  cart,
  point,
  payment,
}

enum BurgerOrderType { single, set }

@immutable
class BurgerMenu {
  const BurgerMenu(this.id, this.name, this.description, this.price);
  final String id;
  final String name;
  final String description;
  final int price;
}

@immutable
class BurgerCartItem {
  const BurgerCartItem({
    required this.menu,
    required this.type,
    this.side,
    this.drink,
    this.extras = const {},
    this.quantity = 1,
  });
  final BurgerMenu menu;
  final BurgerOrderType type;
  final String? side;
  final String? drink;
  final Set<String> extras;
  final int quantity;

  int get unitPrice =>
      menu.price +
      (type == BurgerOrderType.set ? 2500 : 0) +
      extras.fold(
        0,
        (sum, option) => sum + (BurgerOrderProvider.extraPrices[option] ?? 0),
      );
  int get totalPrice => unitPrice * quantity;
  BurgerCartItem copyWith({int? quantity}) => BurgerCartItem(
    menu: menu,
    type: type,
    side: side,
    drink: drink,
    extras: extras,
    quantity: quantity ?? this.quantity,
  );
}

class BurgerOrderProvider extends ChangeNotifier {
  static const menus = <BurgerMenu>[
    BurgerMenu('bulgogi', '불고기버거', '달콤한 불고기 소스', 5200),
    BurgerMenu('cheese', '치즈버거', '고소한 치즈 한 장', 4900),
    BurgerMenu('shrimp', '새우버거', '바삭한 새우 패티', 5600),
    BurgerMenu('chicken', '치킨버거', '담백한 치킨 패티', 5900),
    BurgerMenu('double', '더블비프버거', '두 장의 소고기 패티', 7200),
    BurgerMenu('veggie', '채소버거', '신선한 채소 중심', 5400),
  ];
  static const sides = ['감자튀김', '치즈스틱', '치킨너겟', '어니언링', '샐러드'];
  static const drinks = ['콜라', '제로 콜라', '사이다', '오렌지주스', '생수', '커피'];
  static const extraPrices = {
    '치즈 추가': 500,
    '패티 추가': 1500,
    '양상추 추가': 300,
    '소스 빼기': 0,
    '피클 빼기': 0,
  };

  BurgerOrderStep step = BurgerOrderStep.dine;
  HamburgerLearningMode mode = HamburgerLearningMode.guided;
  bool isFreePractice = false;
  String? dineOption;
  BurgerMenu? selectedMenu;
  BurgerOrderType? orderType;
  String? side;
  String? drink;
  final Set<String> extras = {};
  final List<BurgerCartItem> cart = [];
  String? pointMethod;
  String? paymentMethod;
  String? inlineMessage;
  bool showHint = false;

  bool get isSolo => mode == HamburgerLearningMode.solo;
  int get cartCount => cart.fold(0, (sum, item) => sum + item.quantity);
  int get totalPrice => cart.fold(0, (sum, item) => sum + item.totalPrice);

  void begin(HamburgerLearningMode value) {
    mode = value;
    isFreePractice = false;
    resetOrder();
  }

  void beginFreePractice() {
    mode = HamburgerLearningMode.guided;
    isFreePractice = true;
    resetOrder();
  }

  void resetOrder() {
    step = BurgerOrderStep.dine;
    dineOption = null;
    selectedMenu = null;
    orderType = null;
    side = null;
    drink = null;
    extras.clear();
    cart.clear();
    pointMethod = null;
    paymentMethod = null;
    inlineMessage = null;
    showHint = false;
    notifyListeners();
  }

  void chooseDine(String value, {required bool correct}) =>
      _choose(correct, () {
        dineOption = value;
        selectedMenu = null;
        orderType = null;
        side = null;
        drink = null;
        extras.clear();
        step = BurgerOrderStep.menu;
      });
  void chooseMenu(BurgerMenu value, {required bool correct}) =>
      _choose(correct, () {
        selectedMenu = value;
        orderType = null;
        side = null;
        drink = null;
        extras.clear();
        step = BurgerOrderStep.type;
      });
  void chooseType(BurgerOrderType value, {required bool correct}) =>
      _choose(correct, () {
        orderType = value;
        side = null;
        drink = null;
        extras.clear();
        step = value == BurgerOrderType.set
            ? BurgerOrderStep.side
            : BurgerOrderStep.extras;
      });
  void chooseSide(String value, {required bool correct}) =>
      _choose(correct, () {
        side = value;
        drink = null;
        step = BurgerOrderStep.drink;
      });
  void chooseDrink(String value, {required bool correct}) =>
      _choose(correct, () {
        drink = value;
        step = BurgerOrderStep.extras;
      });
  void toggleExtra(String value) {
    extras.contains(value) ? extras.remove(value) : extras.add(value);
    notifyListeners();
  }

  void addToCart() {
    if (selectedMenu == null || orderType == null || dineOption == null) return;
    cart.add(
      BurgerCartItem(
        menu: selectedMenu!,
        type: orderType!,
        side: side,
        drink: drink,
        extras: Set.unmodifiable(extras),
      ),
    );
    _clearDraft();
    step = BurgerOrderStep.cart;
    notifyListeners();
  }

  void addAnother() {
    _clearDraft();
    step = BurgerOrderStep.menu;
    notifyListeners();
  }

  void changeQuantity(int index, int delta) {
    final next = cart[index].quantity + delta;
    if (next < 1) return;
    cart[index] = cart[index].copyWith(quantity: next);
    notifyListeners();
  }

  void removeItem(int index) {
    cart.removeAt(index);
    notifyListeners();
  }

  void proceedFromCart() {
    if (cart.isEmpty) return;
    step = BurgerOrderStep.point;
    notifyListeners();
  }

  void choosePoint(String value, {required bool correct}) =>
      _choose(correct, () {
        pointMethod = value;
        step = BurgerOrderStep.payment;
      });
  bool choosePayment(String value, {required bool correct}) {
    if (!_accept(correct)) return false;
    paymentMethod = value;
    notifyListeners();
    return true;
  }

  void revealHint() {
    showHint = true;
    inlineMessage = null;
    notifyListeners();
  }

  bool validateExtras(Set<String> target) {
    if (isFreePractice || !isSolo || setEquals(extras, target)) return true;
    inlineMessage = '괜찮아요. 주문 내용을 다시 살펴볼까요?';
    notifyListeners();
    return false;
  }

  void previous() {
    inlineMessage = null;
    showHint = false;
    step = switch (step) {
      BurgerOrderStep.dine => BurgerOrderStep.dine,
      BurgerOrderStep.menu => BurgerOrderStep.dine,
      BurgerOrderStep.type => BurgerOrderStep.menu,
      BurgerOrderStep.side => BurgerOrderStep.type,
      BurgerOrderStep.drink => BurgerOrderStep.side,
      BurgerOrderStep.extras =>
        orderType == BurgerOrderType.set
            ? BurgerOrderStep.drink
            : BurgerOrderStep.type,
      // The draft is cleared when an item is added, so return to the menu.
      BurgerOrderStep.cart => BurgerOrderStep.menu,
      BurgerOrderStep.point => BurgerOrderStep.cart,
      BurgerOrderStep.payment => BurgerOrderStep.point,
    };
    notifyListeners();
  }

  void _choose(bool correct, VoidCallback apply) {
    if (!_accept(correct)) return;
    apply();
    inlineMessage = null;
    showHint = false;
    notifyListeners();
  }

  bool _accept(bool correct) {
    if (isFreePractice || correct) return true;
    inlineMessage = isSolo
        ? '괜찮아요. 주문 내용을 다시 살펴볼까요?'
        : '괜찮아요. 안내된 선택을 천천히 눌러볼까요?';
    notifyListeners();
    return false;
  }

  void _clearDraft() {
    selectedMenu = null;
    orderType = null;
    side = null;
    drink = null;
    extras.clear();
  }

  String get summary => [
    ?dineOption,
    if (selectedMenu != null) selectedMenu!.name,
    if (orderType != null) orderType == BurgerOrderType.set ? '세트' : '단품',
    ?side,
    ?drink,
  ].join(' · ');
}
