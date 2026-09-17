import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../shared/widgets/large_action_button.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../learning/learning_progress_provider.dart';

class TrainStartPage extends StatelessWidget {
  const TrainStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: '기차표 예매 연습',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('기차표 예매 연습', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 18),
          Text(
            '기차를 타기 전에 표를 고르는 순서를 천천히 연습해볼 수 있어요.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.train_outlined,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 18),
                Text('연습용 승차권', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  '출발역과 도착역을 고르고\n가상 승차권을 만들어보세요.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          LargeActionButton(
            label: '따라 해보기',
            icon: Icons.menu_book_outlined,
            onPressed: () {
              context.read<LearningProgressProvider>().selectTrainMode(
                TrainLearningMode.guided,
              );
              context.go(AppRoutes.trainStepOne);
            },
          ),
          const SizedBox(height: 16),
          Text(
            '화면의 안내를 보며 천천히 순서를 연습해요.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          LargeActionButton(
            label: '혼자 해보기',
            icon: Icons.self_improvement_outlined,
            secondary: true,
            onPressed: () {
              context.read<LearningProgressProvider>().selectTrainMode(
                TrainLearningMode.solo,
              );
              context.go(AppRoutes.trainMission);
            },
          ),
          const SizedBox(height: 16),
          Text(
            '오늘의 예매 미션을 기억하고 직접 선택해봐요.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
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
