import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../learning/learning_progress_provider.dart';
import '../learning/widgets/learning_widgets.dart';

class AtmCompletePage extends StatefulWidget {
  const AtmCompletePage({super.key});

  @override
  State<AtmCompletePage> createState() => _AtmCompletePageState();
}

class _AtmCompletePageState extends State<AtmCompletePage> {
  bool _showFirstBadge = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final progress = context.read<LearningProgressProvider>();
      var firstBadge = false;
      if (progress.isAtmSoloMode) {
        firstBadge = await progress.completeAtmSoloLearning();
      } else {
        await progress.completeAtmLearning();
      }
      if (mounted && firstBadge) {
        setState(() => _showFirstBadge = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<LearningProgressProvider>();
    final colors = Theme.of(context).colorScheme;
    final isSolo = progress.isAtmSoloMode;

    return LearningCompletionLayout(
      title: isSolo ? '혼자서도 잘하셨어요!' : '잘하셨어요! ATM 출금 연습을 마쳤어요.',
      message: isSolo ? '오늘의 ATM 출금 미션을 완성했어요.' : '실제 ATM에서도 카드와 돈을 함께 챙겨보세요.',
      reward: isSolo ? '용기 포인트 +20점' : '+10점',
      badge: _showFirstBadge ? _buildBadge(context, colors) : null,
      summary: LearningSummaryCard(
        title: '연습 완료 내역',
        icon: Icons.emoji_events_outlined,
        items: [
          LearningSummaryItem(
            label: '완료 횟수',
            value: isSolo
                ? '${progress.atmSoloCompletionCount}회'
                : '${progress.atmCompletionCount}회',
          ),
        ],
        footer: isSolo
            ? '실제 ATM에서는 카드와 현금을 꼭 모두 챙겨주세요.'
            : '카드와 돈을 함께 챙기는 것을 기억해보세요.',
      ),
      onRestart: () async {
        final progress = context.read<LearningProgressProvider>();
        if (progress.isAtmSoloMode) {
          await progress.startAtmLearning(AtmLearningMode.solo);
          if (context.mounted) context.go(AppRoutes.atmMission);
          return;
        }
        await progress.startAtmLearning(AtmLearningMode.guided);
        if (context.mounted) context.go(AppRoutes.atmPractice);
      },
      onHome: () => context.go(AppRoutes.home),
    );
  }

  Widget _buildBadge(BuildContext context, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.tertiary),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            size: 46,
            color: colors.tertiary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '혼자 ATM 출금 첫걸음',
                  softWrap: true,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '처음으로 혼자 ATM 출금 미션을 완성했어요.',
                  softWrap: true,
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
