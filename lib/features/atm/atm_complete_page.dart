import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../shared/widgets/large_action_button.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../learning/learning_progress_provider.dart';

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

    return PageScaffold(
      title: '연습 완료',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(22, 30, 22, 26),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
            ),
            child: Column(
              children: [
                Icon(Icons.task_alt_rounded, size: 82, color: colors.primary),
                const SizedBox(height: 18),
                Text(
                  progress.isAtmSoloMode
                      ? '혼자서도 잘하셨어요!'
                      : '잘하셨어요! ATM 출금 연습을 마쳤어요.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  progress.isAtmSoloMode
                      ? '오늘의 ATM 출금 미션을 완성했어요.'
                      : '실제 ATM에서도 카드와 돈을 함께 챙기는 것을 기억해보세요.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (progress.isAtmSoloMode) ...[
                  const SizedBox(height: 10),
                  Text(
                    '실제 ATM에서는 카드와 현금을 꼭 모두 챙겨주세요.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
                const SizedBox(height: 14),
                Text(
                  progress.isAtmSoloMode ? '용기 포인트 +20점' : '+10점',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: colors.primary),
                ),
              ],
            ),
          ),
          if (_showFirstBadge) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.tertiaryContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.tertiary),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.workspace_premium_outlined,
                    size: 48,
                    color: colors.tertiary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '혼자 ATM 출금 첫걸음',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '처음으로 혼자 ATM 출금 미션을 완성했어요.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: colors.secondaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events_outlined, size: 32),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    progress.isAtmSoloMode
                        ? 'ATM 혼자 출금 완료 ${progress.atmSoloCompletionCount}회'
                        : 'ATM 출금 연습 완료 ${progress.atmCompletionCount}회',
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          LargeActionButton(
            label: '처음부터 다시 하기',
            icon: Icons.refresh_rounded,
            onPressed: () async {
              final progress = context.read<LearningProgressProvider>();
              if (progress.isAtmSoloMode) {
                await progress.startAtmLearning(AtmLearningMode.solo);
                if (context.mounted) context.go(AppRoutes.atmMission);
                return;
              }
              await progress.startAtmLearning(AtmLearningMode.guided);
              if (context.mounted) context.go(AppRoutes.atmPractice);
            },
          ),
          const SizedBox(height: 18),
          LargeActionButton(
            label: '홈으로 돌아가기',
            icon: Icons.home_outlined,
            secondary: true,
            onPressed: () => context.go(AppRoutes.home),
          ),
        ],
      ),
    );
  }
}
