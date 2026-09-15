import 'package:flutter/material.dart';

enum CafeOrderStep { dineOption, drink, temperature }

class CafeOrderMission {
  const CafeOrderMission({
    required this.dineOption,
    required this.drink,
    required this.temperature,
  });

  static const today = CafeOrderMission(
    dineOption: '포장',
    drink: '아메리카노',
    temperature: '차갑게',
  );

  final String dineOption;
  final String drink;
  final String temperature;

  String get displayOrder => '$dineOption · 아이스 $drink';

  bool isCorrect(CafeOrderStep step, String value) {
    return switch (step) {
      CafeOrderStep.dineOption => value == dineOption,
      CafeOrderStep.drink => value == drink,
      CafeOrderStep.temperature => value == temperature,
    };
  }
}

void showCafeMissionHint(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('오늘의 주문'),
        content: Text(CafeOrderMission.today.displayOrder),
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
