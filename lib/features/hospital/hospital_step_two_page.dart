import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../learning/learning_progress_provider.dart';
import '../learning/widgets/learning_widgets.dart';
import 'hospital_mission.dart';

class HospitalStepTwoPage extends StatelessWidget {
  const HospitalStepTwoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isSolo = context.watch<LearningProgressProvider>().isHospitalSoloMode;

    return LearningStepLayout(
      title: '병원 접수 연습',
      step: 2,
      guidance: isSolo ? '접수 방법을 선택해보세요.' : '접수 방법을 선택하는 화면이에요.',
      question: '어떤 방법으로 접수할까요?',
      onBack: () => context.go(AppRoutes.hospitalStepOne),
      onPrevious: () => context.go(AppRoutes.hospitalStepOne),
      onRestart: () {
        context.read<LearningProgressProvider>().resetHospitalLearning();
        context.go(AppRoutes.hospitalStepOne);
      },
      onHint: isSolo ? () => showHospitalMissionHint(context) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LearningChoiceCard(
            label: '처음 방문이에요',
            icon: Icons.person_add_alt_1_outlined,
            highlighted: !isSolo,
            onPressed: () => _select(context, '처음 방문이에요'),
          ),
          const SizedBox(height: 16),
          LearningChoiceCard(
            label: '다시 방문했어요',
            icon: Icons.history_rounded,
            secondary: true,
            highlighted: !isSolo,
            onPressed: () => _select(context, '다시 방문했어요'),
          ),
        ],
      ),
    );
  }

  void _select(BuildContext context, String method) {
    final progress = context.read<LearningProgressProvider>();
    if (progress.isHospitalSoloMode &&
        !HospitalMission.today.isCorrect(
          HospitalMissionStep.registration,
          method,
        )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '괜찮아요. 오늘의 접수 내용을 다시 확인해볼까요?\n'
            '힌트 보기를 누르면 접수 내용을 확인할 수 있어요.',
          ),
        ),
      );
      return;
    }
    progress.selectHospitalRegistrationMethod(method);
    context.go(AppRoutes.hospitalStepThree);
  }
}
