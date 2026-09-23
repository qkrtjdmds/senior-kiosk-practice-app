import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../learning/learning_progress_provider.dart';
import '../learning/widgets/learning_widgets.dart';

class HamburgerStartPage extends StatelessWidget {
  const HamburgerStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: '햄버거 주문 연습',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('햄버거 주문 연습', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 18),
          Text(
            '메뉴와 세트를 고르는 순서를 천천히 연습해요.',
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
                    Icons.lunch_dining_outlined,
                    size: 46,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  '메뉴와 세트를 고르는 순서를 천천히 연습해요.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          LearningModeCard(
            title: '따라 해보기',
            description: '화면의 안내를 보며 하나씩 주문해요.',
            icon: Icons.menu_book_outlined,
            onPressed: () {
              context.read<LearningProgressProvider>().selectHamburgerMode(
                HamburgerLearningMode.guided,
              );
              context.go(AppRoutes.hamburgerPractice);
            },
          ),
          const SizedBox(height: 18),
          LearningModeCard(
            title: '혼자 해보기',
            description: '오늘의 주문 미션을 기억하고 직접 골라봐요.',
            icon: Icons.self_improvement_outlined,
            secondary: true,
            onPressed: () async {
              await context
                  .read<LearningProgressProvider>()
                  .startHamburgerSoloMission();
              if (context.mounted) {
                context.go(AppRoutes.hamburgerMission);
              }
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
