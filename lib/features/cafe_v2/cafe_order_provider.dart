import 'package:flutter/material.dart';

import '../learning/learning_progress_provider.dart';

enum CafeCategory { coffee, latte, tea, beverage, dessert }

enum CafeTemperature { hot, iced, none }

enum CafeSize { regular, large }

enum CafeDineOption { dineIn, takeout }

enum CafePointMethod { phone, messenger, none }

enum CafePaymentMethod { creditCard, mobilePay, simplePay, cash }

extension CafeCategoryLabel on CafeCategory {
  String get label => switch (this) {
    CafeCategory.coffee => '커피',
    CafeCategory.latte => '라떼',
    CafeCategory.tea => '차',
    CafeCategory.beverage => '음료',
    CafeCategory.dessert => '디저트',
  };
}

extension CafeTemperatureLabel on CafeTemperature {
  String get label => switch (this) {
    CafeTemperature.hot => '따뜻하게',
    CafeTemperature.iced => '차갑게',
    CafeTemperature.none => '선택하지 않음',
  };
}

extension CafeSizeLabel on CafeSize {
  String get label => switch (this) {
    CafeSize.regular => '보통',
    CafeSize.large => '큰 사이즈',
  };
}

extension CafeDineOptionLabel on CafeDineOption {
  String get label => switch (this) {
    CafeDineOption.dineIn => '매장에서 먹기',
    CafeDineOption.takeout => '포장',
  };
}

extension CafePointMethodLabel on CafePointMethod {
  String get label => switch (this) {
    CafePointMethod.phone => '전화번호로 적립',
    CafePointMethod.messenger => '카카오톡으로 적립',
    CafePointMethod.none => '적립하지 않기',
  };
}

extension CafePaymentMethodLabel on CafePaymentMethod {
  String get label => switch (this) {
    CafePaymentMethod.creditCard => '신용카드',
    CafePaymentMethod.mobilePay => '카카오페이',
    CafePaymentMethod.simplePay => '삼성페이',
    CafePaymentMethod.cash => '현금 결제',
  };
}

@immutable
class CafeMenuItem {
  const CafeMenuItem({
    required this.id,
    required this.category,
    required this.name,
    required this.practicePrice,
    required this.icon,
    this.temperatures = const {CafeTemperature.hot, CafeTemperature.iced},
  });

  final String id;
  final CafeCategory category;
  final String name;
  final int practicePrice;
  final IconData icon;
  final Set<CafeTemperature> temperatures;
}

@immutable
class CafeCartItem {
  const CafeCartItem({
    required this.id,
    required this.menu,
    required this.temperature,
    required this.size,
    required this.dineOption,
    required this.quantity,
  });

  final int id;
  final CafeMenuItem menu;
  final CafeTemperature temperature;
  final CafeSize size;
  final CafeDineOption dineOption;
  final int quantity;

  int get unitPrice => menu.practicePrice + (size == CafeSize.large ? 500 : 0);
  int get totalPrice => unitPrice * quantity;

  CafeCartItem copyWith({int? quantity}) => CafeCartItem(
    id: id,
    menu: menu,
    temperature: temperature,
    size: size,
    dineOption: dineOption,
    quantity: quantity ?? this.quantity,
  );
}

const cafeMenuItems = <CafeMenuItem>[
  CafeMenuItem(
    id: 'americano',
    category: CafeCategory.coffee,
    name: '아메리카노',
    practicePrice: 3000,
    icon: Icons.coffee_outlined,
  ),
  CafeMenuItem(
    id: 'decaf_americano',
    category: CafeCategory.coffee,
    name: '디카페인 아메리카노',
    practicePrice: 3500,
    icon: Icons.coffee_outlined,
  ),
  CafeMenuItem(
    id: 'cold_brew',
    category: CafeCategory.coffee,
    name: '콜드브루',
    practicePrice: 3500,
    icon: Icons.local_drink_outlined,
    temperatures: {CafeTemperature.iced},
  ),
  CafeMenuItem(
    id: 'cappuccino',
    category: CafeCategory.coffee,
    name: '카푸치노',
    practicePrice: 3800,
    icon: Icons.coffee_maker_outlined,
  ),
  CafeMenuItem(
    id: 'cafe_latte',
    category: CafeCategory.latte,
    name: '카페 라떼',
    practicePrice: 3800,
    icon: Icons.local_cafe_outlined,
  ),
  CafeMenuItem(
    id: 'vanilla_latte',
    category: CafeCategory.latte,
    name: '바닐라 라떼',
    practicePrice: 4300,
    icon: Icons.local_cafe_outlined,
  ),
  CafeMenuItem(
    id: 'caramel_latte',
    category: CafeCategory.latte,
    name: '카라멜 라떼',
    practicePrice: 4300,
    icon: Icons.local_cafe_outlined,
  ),
  CafeMenuItem(
    id: 'green_tea_latte',
    category: CafeCategory.latte,
    name: '녹차 라떼',
    practicePrice: 4200,
    icon: Icons.emoji_food_beverage_outlined,
  ),
  CafeMenuItem(
    id: 'citron_tea',
    category: CafeCategory.tea,
    name: '유자차',
    practicePrice: 3500,
    icon: Icons.emoji_food_beverage_outlined,
  ),
  CafeMenuItem(
    id: 'peppermint',
    category: CafeCategory.tea,
    name: '페퍼민트 차',
    practicePrice: 3300,
    icon: Icons.emoji_food_beverage_outlined,
  ),
  CafeMenuItem(
    id: 'chamomile',
    category: CafeCategory.tea,
    name: '캐모마일 차',
    practicePrice: 3300,
    icon: Icons.emoji_food_beverage_outlined,
  ),
  CafeMenuItem(
    id: 'black_tea',
    category: CafeCategory.tea,
    name: '홍차',
    practicePrice: 3200,
    icon: Icons.emoji_food_beverage_outlined,
  ),
  CafeMenuItem(
    id: 'lemon_ade',
    category: CafeCategory.beverage,
    name: '레몬 에이드',
    practicePrice: 4000,
    icon: Icons.local_drink_outlined,
    temperatures: {CafeTemperature.iced},
  ),
  CafeMenuItem(
    id: 'grapefruit_ade',
    category: CafeCategory.beverage,
    name: '자몽 에이드',
    practicePrice: 4200,
    icon: Icons.local_drink_outlined,
    temperatures: {CafeTemperature.iced},
  ),
  CafeMenuItem(
    id: 'orange_juice',
    category: CafeCategory.beverage,
    name: '오렌지 주스',
    practicePrice: 3800,
    icon: Icons.local_drink_outlined,
    temperatures: {CafeTemperature.iced},
  ),
  CafeMenuItem(
    id: 'strawberry_juice',
    category: CafeCategory.beverage,
    name: '딸기 주스',
    practicePrice: 4200,
    icon: Icons.local_drink_outlined,
    temperatures: {CafeTemperature.iced},
  ),
  CafeMenuItem(
    id: 'cheese_cake',
    category: CafeCategory.dessert,
    name: '치즈 케이크',
    practicePrice: 4500,
    icon: Icons.cake_outlined,
    temperatures: {CafeTemperature.none},
  ),
  CafeMenuItem(
    id: 'cookie',
    category: CafeCategory.dessert,
    name: '쿠키',
    practicePrice: 2200,
    icon: Icons.cookie_outlined,
    temperatures: {CafeTemperature.none},
  ),
  CafeMenuItem(
    id: 'sandwich',
    category: CafeCategory.dessert,
    name: '샌드위치',
    practicePrice: 4800,
    icon: Icons.lunch_dining_outlined,
    temperatures: {CafeTemperature.none},
  ),
  CafeMenuItem(
    id: 'muffin',
    category: CafeCategory.dessert,
    name: '머핀',
    practicePrice: 3000,
    icon: Icons.bakery_dining_outlined,
    temperatures: {CafeTemperature.none},
  ),
];

class CafeOrderProvider extends ChangeNotifier {
  CafeLearningMode _mode = CafeLearningMode.guided;
  CafeCategory _category = CafeCategory.coffee;
  CafeMenuItem? _selectedMenu;
  CafeTemperature? _temperature;
  CafeSize? _size;
  CafeDineOption? _dineOption;
  CafePointMethod? _pointMethod;
  CafePaymentMethod? _paymentMethod;
  final List<CafeCartItem> _cart = [];
  int _nextCartId = 1;

  CafeLearningMode get mode => _mode;
  bool get isSolo => _mode == CafeLearningMode.solo;
  CafeCategory get category => _category;
  CafeMenuItem? get selectedMenu => _selectedMenu;
  CafeTemperature? get temperature => _temperature;
  CafeSize? get size => _size;
  CafeDineOption? get dineOption => _dineOption;
  CafePointMethod? get pointMethod => _pointMethod;
  CafePaymentMethod? get paymentMethod => _paymentMethod;
  List<CafeCartItem> get cart => List.unmodifiable(_cart);
  int get cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);
  int get totalPrice => _cart.fold(0, (sum, item) => sum + item.totalPrice);
  Iterable<CafeMenuItem> get visibleMenuItems =>
      cafeMenuItems.where((item) => item.category == _category);

  static CafeMenuItem get soloTargetMenu =>
      cafeMenuItems.firstWhere((item) => item.id == 'americano');

  void start(CafeLearningMode mode) {
    _mode = mode;
    _category = CafeCategory.coffee;
    _cart.clear();
    _nextCartId = 1;
    _pointMethod = null;
    _paymentMethod = null;
    _clearCurrentItem();
    notifyListeners();
  }

  void selectCategory(CafeCategory value) {
    _category = value;
    notifyListeners();
  }

  bool selectMenu(CafeMenuItem value) {
    if (isSolo && value.id != soloTargetMenu.id) return false;
    _selectedMenu = value;
    _temperature = value.temperatures.length == 1
        ? value.temperatures.first
        : null;
    _size = null;
    _dineOption = null;
    notifyListeners();
    return true;
  }

  bool selectTemperature(CafeTemperature value) {
    if (isSolo && value != CafeTemperature.iced) return false;
    _temperature = value;
    notifyListeners();
    return true;
  }

  bool selectSize(CafeSize value) {
    if (isSolo && value != CafeSize.regular) return false;
    _size = value;
    notifyListeners();
    return true;
  }

  bool selectDineOption(CafeDineOption value) {
    if (isSolo && value != CafeDineOption.takeout) return false;
    _dineOption = value;
    notifyListeners();
    return true;
  }

  void addCurrentItem() {
    final menu = _selectedMenu;
    final temperature = _temperature;
    final size = _size;
    final dineOption = _dineOption;
    if (menu == null ||
        temperature == null ||
        size == null ||
        dineOption == null) {
      return;
    }
    _cart.add(
      CafeCartItem(
        id: _nextCartId++,
        menu: menu,
        temperature: temperature,
        size: size,
        dineOption: dineOption,
        quantity: 1,
      ),
    );
    _clearCurrentItem();
    notifyListeners();
  }

  void changeQuantity(int id, int delta) {
    final index = _cart.indexWhere((item) => item.id == id);
    if (index < 0) return;
    final next = (_cart[index].quantity + delta).clamp(1, 99);
    _cart[index] = _cart[index].copyWith(quantity: next);
    notifyListeners();
  }

  void removeItem(int id) {
    _cart.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void selectPointMethod(CafePointMethod value) {
    _pointMethod = value;
    notifyListeners();
  }

  void selectPaymentMethod(CafePaymentMethod value) {
    _paymentMethod = value;
    notifyListeners();
  }

  void _clearCurrentItem() {
    _selectedMenu = null;
    _temperature = null;
    _size = null;
    _dineOption = null;
  }
}

String formatPracticePrice(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) buffer.write(',');
    buffer.write(digits[index]);
  }
  return '$buffer원';
}
