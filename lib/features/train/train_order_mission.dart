import 'package:flutter/material.dart';

enum TrainMissionStep { departure, arrival, time, seat }

class TrainOrderMission {
  const TrainOrderMission({
    required this.departure,
    required this.arrival,
    required this.time,
    required this.seat,
  });

  static const today = TrainOrderMission(
    departure: '서울역',
    arrival: '부산역',
    time: '내일 오전',
    seat: '창가 자리',
  );

  final String departure;
  final String arrival;
  final String time;
  final String seat;

  bool isCorrect(TrainMissionStep step, String value) {
    return switch (step) {
      TrainMissionStep.departure => value == departure,
      TrainMissionStep.arrival => value == arrival,
      TrainMissionStep.time => value == time,
      TrainMissionStep.seat => value == seat,
    };
  }
}

void showTrainMissionHint(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('오늘의 예매 내용'),
        content: const Text('서울역 → 부산역\n내일 오전\n창가 자리'),
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
