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
      title: '카페 주문 연습',
      step: 4,
      guidance: guidance,
      question: '주문 내용을 확인해볼까요?',
      guidanceDetail: progress.isSoloMode
          ? '미션을 기억하고 주문서를 확인해보세요.'
          : '선택한 내용이 맞는지 천천히 확인해보세요.',
      questionInGuidance: true,
      calmKioskStyle: true,
      panelLabel: '주문 확인',
      onBack: () => context.go(AppRoutes.cafeStepThree),
      onPrevious: () => context.go(AppRoutes.cafeStepThree),
      onRestart: () => _restart(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LearningSummaryCard(
            title: '주문 내용을 확인해 볼까요?',
            items: [
              LearningSummaryItem(
                label: '매장 / 포장',
                value: progress.dineOption ?? '선택하지 않았어요',
              ),
              LearningSummaryItem(
                label: '메뉴',
                value: progress.drink ?? '선택하지 않았어요',
              ),
              LearningSummaryItem(
                label: '온도',
                value: progress.temperature ?? '선택하지 않았어요',
              ),
            ],
            footer: '실제 결제가 아닌 연습용 주문이에요.',
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => _pay(context, progress),
            icon: const Icon(Icons.check_circle_outline_rounded, size: 30),
            label: const Text('주문 완료하기'),
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
