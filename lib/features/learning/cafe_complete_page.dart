import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../shared/widgets/large_action_button.dart';
import '../../shared/widgets/page_scaffold.dart';
import 'learning_progress_provider.dart';

class CafeCompletePage extends StatefulWidget {
  const CafeCompletePage({super.key});

  @override
  State<CafeCompletePage> createState() => _CafeCompletePageState();
}

class _CafeCompletePageState extends State<CafeCompletePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LearningProgressProvider>().completeCafeLearning();
    });
  }

  @override
  Widget build(BuildContext context) {
    final completionCount = context
        .watch<LearningProgressProvider>()
        .cafeCompletionCount;
    final progress = context.watch<LearningProgressProvider>();
    final isSolo = progress.isSoloMode;
    final title = isSolo ? '혼자서도 잘하셨어요!' : '잘하셨어요!';
    final message = isSolo
        ? '배운 순서를 떠올리며 주문을 완성했어요.'
        : '카페 주문 순서를 천천히 잘 따라오셨어요.';
    final reward = isSolo ? '용기 포인트 +20점' : '한걸음 포인트 +10점';

    return PageScaffold(
      title: '연습 완료',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(22, 30, 22, 26),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.celebration_outlined,
                  size: 82,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  reward,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events_outlined, size: 32),
                const SizedBox(width: 12),
                Text(
                  '카페 연습 완료 $completionCount회',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          LargeActionButton(
            label: '같은 방식으로 다시 하기',
            icon: Icons.refresh_rounded,
            onPressed: () {
              context.read<LearningProgressProvider>().resetCafeLearning();
              context.go(AppRoutes.cafeStepOne);
            },
          ),
          const SizedBox(height: 18),
          LargeActionButton(
            label: '다른 방식으로 연습하기',
            icon: Icons.swap_horiz_rounded,
            secondary: true,
            onPressed: () {
              context.read<LearningProgressProvider>().clearCafeMode();
              context.go(AppRoutes.cafeStart);
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
