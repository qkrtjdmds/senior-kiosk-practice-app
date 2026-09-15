import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import 'learning_progress_provider.dart';
import 'widgets/learning_widgets.dart';

class CafeStepFourPage extends StatelessWidget {
  const CafeStepFourPage({super.key});

  void _restart(BuildContext context) {
    context.read<LearningProgressProvider>().resetCafeLearning();
    context.go(AppRoutes.cafeStepOne);
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
            onPressed: () => context.go(AppRoutes.cafeComplete),
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
