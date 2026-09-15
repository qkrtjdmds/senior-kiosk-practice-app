import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import 'learning_progress_provider.dart';
import 'widgets/learning_widgets.dart';

class CafePracticePage extends StatelessWidget {
  const CafePracticePage({super.key});

  void _select(BuildContext context, String option) {
    context.read<LearningProgressProvider>().selectDineOption(option);
    context.go(AppRoutes.cafeStepTwo);
  }

  void _restart(BuildContext context) {
    context.read<LearningProgressProvider>().resetCafeLearning();
    context.go(AppRoutes.cafeStepOne);
  }

  @override
  Widget build(BuildContext context) {
    final isSolo = context.watch<LearningProgressProvider>().isSoloMode;

    return LearningStepLayout(
      step: 1,
      guidance: isSolo ? '주문 방식을 선택해보세요.' : '첫 번째로, 어디에서 드실지 골라볼까요?',
      question: '매장에서 드시나요, 포장하시나요?',
      onBack: () => context.go(AppRoutes.cafeStart),
      onPrevious: () => context.go(AppRoutes.cafeStart),
      onRestart: () => _restart(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LearningChoiceCard(
            label: '매장에서 먹을게요',
            icon: Icons.restaurant_outlined,
            onPressed: () => _select(context, '매장'),
          ),
          const SizedBox(height: 16),
          LearningChoiceCard(
            label: '포장할게요',
            icon: Icons.takeout_dining_outlined,
            secondary: true,
            onPressed: () => _select(context, '포장'),
          ),
        ],
      ),
    );
  }
}
