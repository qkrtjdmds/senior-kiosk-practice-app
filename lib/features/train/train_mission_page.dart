import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../shared/widgets/large_action_button.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../learning/learning_progress_provider.dart';

class TrainMissionPage extends StatelessWidget {
  const TrainMissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: '혼자 해보기',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '오늘의 기차표 예매 미션',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
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
                  Icons.confirmation_number_outlined,
                  size: 76,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 18),
                Text(
                  '서울역에서 부산역까지',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 14),
                Text(
                  '내일 오전 · 창가 자리',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                Text(
                  '예매 내용을 기억하고 직접 선택해보세요.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          LargeActionButton(
            label: '혼자 예매해보기',
            icon: Icons.play_arrow_rounded,
            onPressed: () => context.go(AppRoutes.trainStepOne),
          ),
          const SizedBox(height: 16),
          LargeActionButton(
            label: '기차표 예매 연습으로 돌아가기',
            icon: Icons.arrow_back_rounded,
            secondary: true,
            onPressed: () {
              context.read<LearningProgressProvider>().resetTrainLearning();
              context.go(AppRoutes.trainStart);
            },
          ),
        ],
      ),
    );
  }
}
