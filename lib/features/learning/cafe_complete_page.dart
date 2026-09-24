import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import 'learning_progress_provider.dart';
import 'widgets/learning_widgets.dart';

class CafeCompletePage extends StatefulWidget {
  const CafeCompletePage({super.key});

  @override
  State<CafeCompletePage> createState() => _CafeCompletePageState();
}

class _CafeCompletePageState extends State<CafeCompletePage> {
  bool _showFirstBadge = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final firstBadge = await context
          .read<LearningProgressProvider>()
          .completeCafeLearning();
      if (mounted && firstBadge) {
        setState(() => _showFirstBadge = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final completionCount = context
        .watch<LearningProgressProvider>()
        .cafeCompletionCount;
    final progress = context.watch<LearningProgressProvider>();
    final isSolo = progress.isSoloMode;
    const title = '잘하셨어요!';
    const message = '카페 주문 순서를 한 걸음 더 익혔어요.';
    final reward = isSolo ? '용기 포인트 +20점' : '한걸음 포인트 +10점';

    return LearningCompletionLayout(
      title: title,
      message: message,
      reward: reward,
      badge: _showFirstBadge ? const _CafeFirstBadgeCard() : null,
      summary: LearningSummaryCard(
        title: '연습 기록',
        icon: Icons.check_circle_outline_rounded,
        items: [
          LearningSummaryItem(label: '카페 연습 완료', value: '$completionCount회'),
        ],
        footer: '오늘의 연습이 차곡차곡 쌓였어요.',
      ),
      onRestart: () {
        context.read<LearningProgressProvider>().resetCafeLearning();
        context.go(AppRoutes.cafeStepOne);
      },
      secondaryActionLabel: '다른 방식으로 연습하기',
      onSecondaryAction: () {
        context.read<LearningProgressProvider>().clearCafeMode();
        context.go(AppRoutes.cafeStart);
      },
      onHome: () => context.go(AppRoutes.home),
    );
  }
}

class _CafeFirstBadgeCard extends StatelessWidget {
  const _CafeFirstBadgeCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: learningSageSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: learningSageBorder),
      ),
      child: Row(
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            size: 48,
            color: colors.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '혼자 주문 첫걸음',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '처음으로 혼자 주문 미션을 완성했어요.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
