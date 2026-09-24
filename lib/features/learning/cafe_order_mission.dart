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
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
        actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        title: Text(
          '오늘의 주문',
          softWrap: true,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFEDF2EA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBAC9B7)),
          ),
          child: Text(
            CafeOrderMission.today.displayOrder,
            textAlign: TextAlign.center,
            softWrap: true,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: TextButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            child: const Text('다시 해볼게요'),
          ),
        ],
      );
    },
  );
}
