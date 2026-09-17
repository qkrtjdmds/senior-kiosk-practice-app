import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../shared/widgets/large_action_button.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../learning/learning_progress_provider.dart';

class TrainCompletePage extends StatefulWidget {
  const TrainCompletePage({super.key});

  @override
  State<TrainCompletePage> createState() => _TrainCompletePageState();
}

class _TrainCompletePageState extends State<TrainCompletePage> {
  bool _showFirstBadge = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final progress = context.read<LearningProgressProvider>();
      var firstBadge = false;
      if (progress.isTrainSoloMode) {
        firstBadge = await progress.completeTrainSoloLearning();
      } else {
        await progress.completeTrainLearning();
      }
      if (mounted && firstBadge) {
        setState(() => _showFirstBadge = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<LearningProgressProvider>();

    return PageScaffold(
      title: '기차표 예매 연습 완료',
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
                  Icons.check_circle_outline_rounded,
                  size: 82,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 18),
                Text(
                  progress.isTrainSoloMode ? '혼자서도 잘하셨어요!' : '잘하셨어요!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  progress.isTrainSoloMode
                      ? '오늘의 기차표 예매 미션을 완성했어요.'
                      : '기차표 예매 순서를 천천히 잘 따라오셨어요.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '실제 예매 화면에서도 출발역, 도착역, 시간, 좌석 순서로 고르면 돼요.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  progress.isTrainSoloMode ? '용기 포인트 +20점' : '한걸음 포인트 +10점',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          if (_showFirstBadge) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.workspace_premium_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '기차표 예매 첫걸음',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '처음으로 혼자 기차표 예매 미션을 완성했어요.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          LargeActionButton(
            label: '처음부터 다시 하기',
            icon: Icons.refresh_rounded,
            onPressed: () {
              context.read<LearningProgressProvider>().resetTrainLearning();
              context.go(AppRoutes.trainStepOne);
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
