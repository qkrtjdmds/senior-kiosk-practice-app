import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import 'cafe_order_mission.dart';
import 'learning_progress_provider.dart';
import 'widgets/learning_widgets.dart';

class CafeStepTwoPage extends StatelessWidget {
  const CafeStepTwoPage({super.key});

  void _select(BuildContext context, String drink) {
    final progress = context.read<LearningProgressProvider>();
    if (progress.isSoloMode &&
        !CafeOrderMission.today.isCorrect(CafeOrderStep.drink, drink)) {
      _showMissionReminder(context);
      return;
    }

    progress.selectDrink(drink);
    context.go(AppRoutes.cafeStepThree);
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
      step: 2,
      guidance: isSolo ? '음료를 선택해보세요.' : '좋아요! 이제 마시고 싶은 음료를 골라볼까요?',
      question: '어떤 음료를 선택할까요?',
      guidanceDetail: isSolo ? '미션을 기억하고 직접 골라보세요.' : '화면을 보며 하나씩 선택해 볼까요?',
      questionInGuidance: true,
      calmKioskStyle: true,
      panelLabel: '카페 주문',
      onBack: () => context.go(AppRoutes.cafeStepOne),
      onPrevious: () => context.go(AppRoutes.cafeStepOne),
      onRestart: () => _restart(context),
      onHint: isSolo ? () => showCafeMissionHint(context) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LearningChoiceCard(
            label: '아메리카노',
            icon: Icons.coffee_outlined,
            visualState: isSolo
                ? LearningChoiceVisualState.normal
                : LearningChoiceVisualState.guided,
            calmStyle: true,
            insideKioskPanel: true,
            onPressed: () => _select(context, '아메리카노'),
          ),
          const SizedBox(height: 16),
          LearningChoiceCard(
            label: '카페라떼',
            icon: Icons.local_cafe_outlined,
            secondary: true,
            visualState: isSolo
                ? LearningChoiceVisualState.normal
                : LearningChoiceVisualState.guided,
            calmStyle: true,
            insideKioskPanel: true,
            onPressed: () => _select(context, '카페라떼'),
          ),
          const SizedBox(height: 16),
          LearningChoiceCard(
            label: '따뜻한 차',
            icon: Icons.emoji_food_beverage_outlined,
            secondary: true,
            visualState: isSolo
                ? LearningChoiceVisualState.normal
                : LearningChoiceVisualState.guided,
            calmStyle: true,
            insideKioskPanel: true,
            onPressed: () => _select(context, '따뜻한 차'),
          ),
        ],
      ),
    );
  }
}
