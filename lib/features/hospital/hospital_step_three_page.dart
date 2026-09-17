import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../learning/learning_progress_provider.dart';
import '../learning/widgets/learning_widgets.dart';
import 'hospital_mission.dart';

class HospitalStepThreePage extends StatelessWidget {
  const HospitalStepThreePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isSolo = context.watch<LearningProgressProvider>().isHospitalSoloMode;

    return LearningStepLayout(
      title: '병원 접수 연습',
      step: 3,
      guidance: isSolo ? '진료과를 선택해보세요.' : '진료를 받을 곳을 선택해볼까요?',
      question: '어디가 불편하신가요?',
      onBack: () => context.go(AppRoutes.hospitalStepTwo),
      onPrevious: () => context.go(AppRoutes.hospitalStepTwo),
      onRestart: () {
        context.read<LearningProgressProvider>().resetHospitalLearning();
        context.go(AppRoutes.hospitalStepOne);
      },
      onHint: isSolo ? () => showHospitalMissionHint(context) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LearningChoiceCard(
            label: '속이 불편해요',
            icon: Icons.favorite_border_rounded,
            highlighted: !isSolo,
            onPressed: () => _selectDepartment(context, '내과', '속이 불편해요'),
          ),
          const SizedBox(height: 16),
          LearningChoiceCard(
            label: '무릎이나 허리가 불편해요',
            icon: Icons.accessibility_new_outlined,
            secondary: true,
            highlighted: !isSolo,
            onPressed: () =>
                _selectDepartment(context, '정형외과', '무릎이나 허리가 불편해요'),
          ),
          const SizedBox(height: 16),
          LearningChoiceCard(
            label: '잘 모르겠어요',
            icon: Icons.help_outline_rounded,
            secondary: true,
            highlighted: !isSolo,
            onPressed: () =>
                _selectDepartment(context, '안내데스크 도움 요청', '잘 모르겠어요'),
          ),
        ],
      ),
    );
  }

  void _selectDepartment(
    BuildContext context,
    String department,
    String label,
  ) {
    final progress = context.read<LearningProgressProvider>();
    if (progress.isHospitalSoloMode &&
        !HospitalMission.today.isCorrect(
          HospitalMissionStep.department,
          label,
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
    progress.selectHospitalDepartment(department);
    context.go(AppRoutes.hospitalStepFour);
  }
}
