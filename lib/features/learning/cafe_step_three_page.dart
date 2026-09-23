import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import 'cafe_order_mission.dart';
import 'learning_progress_provider.dart';
import 'widgets/learning_widgets.dart';

class CafeStepThreePage extends StatelessWidget {
  const CafeStepThreePage({super.key});

  void _select(BuildContext context, String temperature) {
    final progress = context.read<LearningProgressProvider>();
    if (progress.isSoloMode &&
        !CafeOrderMission.today.isCorrect(
          CafeOrderStep.temperature,
          temperature,
        )) {
      _showMissionReminder(context);
      return;
    }

    progress.selectTemperature(temperature);
    context.go(AppRoutes.cafeStepFour);
  }

  void _showMissionReminder(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            '괜찮아요. 오늘의 주문을 다시 확인해볼까요?\n'
            '힌트 보기를 누르면 주문 내용을 확인할 수 있어요.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _restart(BuildContext context) {
    context.read<LearningProgressProvider>().resetCafeLearning();
    context.go(AppRoutes.cafeStepOne);
  }

  @override
  Widget build(BuildContext context) {
    final isSolo = context.watch<LearningProgressProvider>().isSoloMode;

    return LearningStepLayout(
      title: '카페 키오스크 연습',
      step: 3,
      guidance: isSolo ? '음료 온도를 선택해보세요.' : '좋아요! 음료 온도를 고르는 화면이에요.',
      question: '차갑게 드실까요, 따뜻하게 드실까요?',
      guidanceDetail: isSolo ? '미션을 기억하고 직접 골라보세요.' : '화면의 안내를 보고 선택해보세요.',
      questionInGuidance: true,
      calmKioskStyle: true,
      onBack: () => context.go(AppRoutes.cafeStepTwo),
      onPrevious: () => context.go(AppRoutes.cafeStepTwo),
      onRestart: () => _restart(context),
      onHint: isSolo ? () => showCafeMissionHint(context) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LearningChoiceCard(
            label: '차갑게 먹을게요',
            icon: Icons.ac_unit_outlined,
            visualState: isSolo
                ? LearningChoiceVisualState.normal
                : LearningChoiceVisualState.guided,
            calmStyle: true,
            onPressed: () => _select(context, '차갑게'),
          ),
          const SizedBox(height: 16),
          LearningChoiceCard(
            label: '따뜻하게 먹을게요',
            icon: Icons.local_fire_department_outlined,
            secondary: true,
            visualState: isSolo
                ? LearningChoiceVisualState.normal
                : LearningChoiceVisualState.guided,
            calmStyle: true,
            onPressed: () => _select(context, '따뜻하게'),
          ),
        ],
      ),
    );
  }
}
