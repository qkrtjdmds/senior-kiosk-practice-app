import 'package:flutter/material.dart';

enum PhotoMissionStep { recipient, photo, message }

class PhotoMission {
  const PhotoMission({
    required this.recipient,
    required this.photo,
    required this.message,
  });

  static const today = PhotoMission(
    recipient: '가족',
    photo: '꽃 사진',
    message: '사진 보세요!',
  );

  final String recipient;
  final String photo;
  final String message;

  bool isCorrect(PhotoMissionStep step, String value) {
    return switch (step) {
      PhotoMissionStep.recipient => value == recipient,
      PhotoMissionStep.photo => value == photo,
      PhotoMissionStep.message => value == message,
    };
  }
}

void showPhotoMissionHint(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('오늘 보낼 내용'),
        content: const Text('가족에게 보내기\n꽃 사진\n사진 보세요!'),
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
