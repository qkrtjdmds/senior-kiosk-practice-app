import 'package:flutter/material.dart';

enum HamburgerMissionStep { dineOption, menu, orderType, drink }

class HamburgerMission {
  const HamburgerMission({
    required this.id,
    required this.title,
    required this.dineOption,
    required this.dineLabel,
    required this.menu,
    required this.isSet,
    required this.drink,
    required this.displayText,
  });

  static const missions = [
    HamburgerMission(
      id: 'cheese_set_takeout',
      title: '치즈버거 세트 주문',
      dineOption: '포장',
      dineLabel: '포장',
      menu: '치즈버거',
      isSet: true,
      drink: '콜라',
      displayText: '포장 · 치즈버거 세트 · 콜라',
    ),
    HamburgerMission(
      id: 'bulgogi_single_dine_in',
      title: '불고기버거 단품 주문',
      dineOption: '매장 식사',
      dineLabel: '매장',
      menu: '불고기버거',
      isSet: false,
      drink: null,
      displayText: '매장 · 불고기버거 단품',
    ),
    HamburgerMission(
      id: 'shrimp_set_dine_in',
      title: '새우버거 세트 주문',
      dineOption: '매장 식사',
      dineLabel: '매장',
      menu: '새우버거',
      isSet: true,
      drink: '사이다',
      displayText: '매장 · 새우버거 세트 · 사이다',
    ),
  ];

  final String id;
  final String title;
  final String dineOption;
  final String dineLabel;
  final String menu;
  final bool isSet;
  final String? drink;
  final String displayText;

  String get orderLabel => isSet ? '세트 주문' : '햄버거만 주문';
  String get hintText => [
    dineLabel,
    '$menu ${isSet ? '세트' : '단품'}',
    drink ?? '음료 선택하지 않음',
  ].join('\n');

  static HamburgerMission byId(String? id) {
    return missions.firstWhere(
      (mission) => mission.id == id,
      orElse: () => missions.first,
    );
  }

  bool isCorrect(HamburgerMissionStep step, Object value) {
    return switch (step) {
      HamburgerMissionStep.dineOption => value == dineOption,
      HamburgerMissionStep.menu => value == menu,
      HamburgerMissionStep.orderType => value == isSet,
      HamburgerMissionStep.drink => value == drink,
    };
  }
}

void showHamburgerMissionHint(BuildContext context, HamburgerMission mission) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('오늘의 주문 내용'),
        content: Text(mission.hintText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('다시 해볼게요'),
          ),
        ],
      );
    },
  );
}
