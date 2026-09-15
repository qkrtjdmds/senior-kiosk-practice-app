import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import 'cafe_order_mission.dart';
import 'learning_progress_provider.dart';
import 'widgets/learning_widgets.dart';

class CafeStepFourPage extends StatelessWidget {
  const CafeStepFourPage({super.key});

  void _restart(BuildContext context) {
    context.read<LearningProgressProvider>().resetCafeLearning();
    context.go(AppRoutes.cafeStepOne);
  }

  void _pay(BuildContext context, LearningProgressProvider progress) {
    final mission = CafeOrderMission.today;
    final completed =
        mission.isCorrect(
          CafeOrderStep.dineOption,
          progress.dineOption ?? '',
        ) &&
        mission.isCorrect(CafeOrderStep.drink, progress.drink ?? '') &&
        mission.isCorrect(
          CafeOrderStep.temperature,
          progress.temperature ?? '',
        );

    if (progress.isSoloMode && !completed) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              '괜찮아요. 오늘의 주문을 다시 확인해볼까요?\n'
              '이전 단계에서 다시 선택해볼 수 있어요.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    context.go(AppRoutes.cafeComplete);
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<LearningProgressProvider>();
    final guidance = progress.isSoloMode
        ? '주문 내용을 확인해보세요.'
        : '좋아요! 마지막으로 주문 내용을 확인해볼까요?';

    return LearningStepLayout(
      step: 4,
      guidance: guidance,
      question: '주문 내용을 확인해볼까요?',
      onBack: () => context.go(AppRoutes.cafeStepThree),
      onPrevious: () => context.go(AppRoutes.cafeStepThree),
      onRestart: () => _restart(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OrderReceiptCard(
            dineOption: progress.dineOption ?? '선택하지 않았어요',
            drink: progress.drink ?? '선택하지 않았어요',
            temperature: progress.temperature ?? '선택하지 않았어요',
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => _pay(context, progress),
            icon: const Icon(Icons.credit_card_outlined, size: 30),
            label: const Text('결제하기'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(78),
              textStyle: Theme.of(context).textTheme.labelLarge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
