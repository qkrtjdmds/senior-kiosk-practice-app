import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../learning/learning_progress_provider.dart';
import '../learning/widgets/learning_widgets.dart';

class AtmStartPage extends StatelessWidget {
  const AtmStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'ATM 출금 연습',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('ATM 출금 연습', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 18),
          Text(
            '실제 돈이 나가지 않는 연습 화면이에요.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFFE4F3EA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF9FCBB4)),
            ),
            child: Column(
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.local_atm_outlined,
                    size: 46,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'ATM에서 돈을 찾는 순서를 천천히 연습해요.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 30,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '이 화면은 실제 은행 업무가 아닌 연습용 화면이에요.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          LearningModeCard(
            title: '따라 해보기',
            description: '화면의 안내를 보며 하나씩 연습해요.',
            icon: Icons.menu_book_outlined,
            onPressed: () async {
              await context.read<LearningProgressProvider>().startAtmLearning(
                AtmLearningMode.guided,
              );
              if (context.mounted) context.go(AppRoutes.atmPractice);
            },
          ),
          const SizedBox(height: 18),
          LearningModeCard(
            title: '혼자 해보기',
            description: '오늘의 출금 미션을 기억하고 직접 해봐요.',
            icon: Icons.self_improvement_outlined,
            secondary: true,
            onPressed: () async {
              await context.read<LearningProgressProvider>().startAtmLearning(
                AtmLearningMode.solo,
              );
              if (context.mounted) context.go(AppRoutes.atmMission);
            },
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.home),
            icon: const Icon(Icons.home_outlined),
            label: const Text('홈으로 돌아가기'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(62),
            ),
          ),
        ],
      ),
    );
  }
}
