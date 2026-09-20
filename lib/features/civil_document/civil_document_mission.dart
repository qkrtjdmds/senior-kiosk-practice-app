import 'package:flutter/material.dart';

abstract final class CivilDocumentMission {
  static const document = '주민등록등본';
  static const content = '기본 내용';
  static const copies = '한 부';

  static void showHint(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오늘의 발급 내용'),
        content: const Text('주민등록등본\n기본 내용\n한 부\n서류 챙기기'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('다시 해볼게요'),
          ),
        ],
      ),
    );
  }
}
