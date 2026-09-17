import 'package:flutter/material.dart';

enum HospitalMissionStep { purpose, registration, department }

class HospitalMission {
  const HospitalMission({
    required this.purpose,
    required this.registration,
    required this.department,
    required this.departmentLabel,
  });

  static const today = HospitalMission(
    purpose: '진료를 받으러 왔어요',
    registration: '다시 방문했어요',
    department: '정형외과',
    departmentLabel: '무릎이나 허리가 불편해요',
  );

  final String purpose;
  final String registration;
  final String department;
  final String departmentLabel;

  bool isCorrect(HospitalMissionStep step, String value) {
    return switch (step) {
      HospitalMissionStep.purpose => value == purpose,
      HospitalMissionStep.registration => value == registration,
      HospitalMissionStep.department => value == departmentLabel,
    };
  }
}

void showHospitalMissionHint(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('오늘의 접수 내용'),
        content: const Text('진료를 받으러 왔어요\n다시 방문했어요\n정형외과'),
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
