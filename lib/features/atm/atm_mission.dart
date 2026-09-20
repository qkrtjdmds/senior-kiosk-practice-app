import 'package:flutter/material.dart';

abstract final class AtmMission {
  static const amount = '5만 원';

  static void showHint(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('오늘의 출금 내용'),
          content: const Text('돈을 찾기\n5만 원\n카드와 현금 챙기기'),
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
}
