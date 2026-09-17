import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../features/learning/learning_progress_provider.dart';
import '../../features/learning/widgets/learning_widgets.dart';
import 'hospital_mission.dart';

class HospitalStepOnePage extends StatelessWidget {
  const HospitalStepOnePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isSolo = context.watch<LearningProgressProvider>().isHospitalSoloMode;

    return LearningStepLayout(
      title: '병원 접수 연습',
      step: 1,
      guidance: isSolo ? '방문 목적을 선택해보세요.' : '먼저 어떤 도움을 받을지 선택해볼까요?',
      question: '무엇을 하러 오셨나요?',
      onBack: () => context.go(AppRoutes.hospitalStart),
      onPrevious: () => context.go(AppRoutes.hospitalStart),
      onRestart: () {
        context.read<LearningProgressProvider>().resetHospitalLearning();
        context.go(AppRoutes.hospitalStepOne);
      },
      onHint: isSolo ? () => showHospitalMissionHint(context) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LearningChoiceCard(
            label: '진료를 받으러 왔어요',
            icon: Icons.medical_services_outlined,
            highlighted: !isSolo,
            onPressed: () => _select(context, '진료를 받으러 왔어요'),
          ),
          const SizedBox(height: 16),
          LearningChoiceCard(
            label: '예약을 확인하고 싶어요',
            icon: Icons.event_note_outlined,
            secondary: true,
            highlighted: !isSolo,
            onPressed: () => _select(context, '예약을 확인하고 싶어요'),
          ),
        ],
      ),
    );
  }

  void _select(BuildContext context, String purpose) {
    final progress = context.read<LearningProgressProvider>();
    if (progress.isHospitalSoloMode &&
        !HospitalMission.today.isCorrect(
          HospitalMissionStep.purpose,
          purpose,
        )) {
      _showReminder(context);
      return;
    }
    progress.selectHospitalVisitPurpose(purpose);
    context.go(AppRoutes.hospitalStepTwo);
  }

  void _showReminder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '괜찮아요. 오늘의 접수 내용을 다시 확인해볼까요?\n'
          '힌트 보기를 누르면 접수 내용을 확인할 수 있어요.',
        ),
      ),
    );
  }
}
