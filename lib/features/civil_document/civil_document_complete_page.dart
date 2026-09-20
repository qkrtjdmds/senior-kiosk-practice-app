import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../shared/widgets/large_action_button.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../learning/learning_progress_provider.dart';

class CivilDocumentCompletePage extends StatefulWidget {
  const CivilDocumentCompletePage({super.key});

  @override
  State<CivilDocumentCompletePage> createState() =>
      _CivilDocumentCompletePageState();
}

class _CivilDocumentCompletePageState extends State<CivilDocumentCompletePage> {
  bool _showFirstBadge = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final progress = context.read<LearningProgressProvider>();
      var firstBadge = false;
      if (progress.isCivilDocumentSoloMode) {
        firstBadge = await progress.completeCivilDocumentSoloLearning();
      } else {
        await progress.completeCivilDocumentLearning();
      }
      if (mounted && firstBadge) {
        setState(() => _showFirstBadge = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<LearningProgressProvider>();
    final isSolo = progress.isCivilDocumentSoloMode;
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
                  isSolo ? '혼자서도 잘하셨어요!' : '잘하셨어요!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  isSolo
                      ? '무인민원발급기에서 서류를 고르는 연습을 마쳤어요.'
                      : '무인민원발급기에서 서류를 발급하는 순서를 천천히 잘 따라오셨어요.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  '실제 발급기에서는 필요한 서류와 내용을 한 번 더 확인하면 돼요.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 14),
                Text(
                  isSolo ? '+20점' : '한걸음 포인트 +10점',
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
                          '새 배지: 혼자 서류 발급 첫걸음',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '처음으로 혼자 서류 발급 미션을 완성했어요.',
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
                    isSolo
                        ? '무인민원발급기 혼자 해보기 완료 ${progress.civilDocumentSoloCompletionCount}회'
                        : '무인민원발급기 연습 완료 ${progress.civilDocumentCompletionCount}회',
                    textAlign: TextAlign.center,
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
              if (isSolo) {
                await progress.startCivilDocumentLearning(
                  CivilDocumentLearningMode.solo,
                );
                if (context.mounted) {
                  context.go(AppRoutes.civilDocumentPractice);
                }
                return;
              }
              await progress.startCivilDocumentLearning(
                CivilDocumentLearningMode.guided,
              );
              if (context.mounted) {
                context.go(AppRoutes.civilDocumentPractice);
              }
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
