import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import 'cafe_order_mission.dart';
import 'learning_progress_provider.dart';
import 'widgets/learning_widgets.dart';

class CafePracticePage extends StatelessWidget {
  const CafePracticePage({super.key});

  void _select(BuildContext context, String option) {
    final progress = context.read<LearningProgressProvider>();
    if (progress.isSoloMode &&
        !CafeOrderMission.today.isCorrect(CafeOrderStep.dineOption, option)) {
      _showMissionReminder(context);
      return;
    }

    progress.selectDineOption(option);
    context.go(AppRoutes.cafeStepTwo);
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
      title: '카페 주문 연습',
      step: 1,
      guidance: isSolo ? '주문 방식을 선택해보세요.' : '첫 번째로, 어디에서 드실지 골라볼까요?',
      question: '매장에서 드시나요, 포장하시나요?',
      guidanceDetail: isSolo ? '미션을 기억하고 직접 골라보세요.' : '화면을 보며 하나씩 선택해 볼까요?',
      questionInGuidance: true,
      calmKioskStyle: true,
      panelLabel: '카페 주문',
      onBack: () => context.go(AppRoutes.cafeStart),
      onPrevious: () => context.go(AppRoutes.cafeStart),
      onRestart: () => _restart(context),
      onHint: isSolo ? () => showCafeMissionHint(context) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LearningChoiceCard(
            label: '매장에서 먹을게요',
            icon: Icons.restaurant_outlined,
            visualState: isSolo
                ? LearningChoiceVisualState.normal
                : LearningChoiceVisualState.guided,
            calmStyle: true,
            insideKioskPanel: true,
            onPressed: () => _select(context, '매장'),
          ),
          const SizedBox(height: 16),
          LearningChoiceCard(
            label: '포장할게요',
            icon: Icons.takeout_dining_outlined,
            secondary: true,
            visualState: isSolo
                ? LearningChoiceVisualState.normal
                : LearningChoiceVisualState.guided,
            calmStyle: true,
            insideKioskPanel: true,
            onPressed: () => _select(context, '포장'),
          ),
        ],
      ),
    );
  }
}
