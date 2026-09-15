import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import 'learning_progress_provider.dart';
import 'widgets/learning_widgets.dart';

class CafeStepThreePage extends StatelessWidget {
  const CafeStepThreePage({super.key});

  void _select(BuildContext context, String temperature) {
    context.read<LearningProgressProvider>().selectTemperature(temperature);
    context.go(AppRoutes.cafeStepFour);
  }

  void _restart(BuildContext context) {
    context.read<LearningProgressProvider>().resetCafeLearning();
    context.go(AppRoutes.cafeStepOne);
  }

  @override
  Widget build(BuildContext context) {
    final isSolo = context.watch<LearningProgressProvider>().isSoloMode;

    return LearningStepLayout(
      step: 3,
      guidance: isSolo ? '음료 온도를 선택해보세요.' : '좋아요! 음료 온도를 고르는 화면이에요.',
      question: '차갑게 드실까요, 따뜻하게 드실까요?',
      onBack: () => context.go(AppRoutes.cafeStepTwo),
      onPrevious: () => context.go(AppRoutes.cafeStepTwo),
      onRestart: () => _restart(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LearningChoiceCard(
            label: '차갑게 먹을게요',
            icon: Icons.ac_unit_outlined,
            onPressed: () => _select(context, '차갑게'),
          ),
          const SizedBox(height: 16),
          LearningChoiceCard(
            label: '따뜻하게 먹을게요',
            icon: Icons.local_fire_department_outlined,
            secondary: true,
            onPressed: () => _select(context, '따뜻하게'),
          ),
        ],
      ),
    );
  }
}
