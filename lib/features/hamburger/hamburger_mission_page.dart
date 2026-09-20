import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../shared/widgets/large_action_button.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../learning/learning_progress_provider.dart';

class HamburgerMissionPage extends StatelessWidget {
  const HamburgerMissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final mission = context
        .watch<LearningProgressProvider>()
        .currentHamburgerMission;

    return PageScaffold(
      title: '혼자 해보기',
      backRoute: AppRoutes.hamburgerStart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '오늘의 햄버거 주문 미션',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
            decoration: BoxDecoration(
              color: colors.secondaryContainer,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colors.secondary.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 76,
                  color: colors.secondary,
                ),
                const SizedBox(height: 18),
                Text(
                  mission.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 14),
                Text(
                  mission.displayText,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                Text(
                  '주문 내용을 기억하고 직접 선택해보세요.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          LargeActionButton(
            label: '혼자 주문해보기',
            icon: Icons.play_arrow_rounded,
            onPressed: () => context.go(AppRoutes.hamburgerPractice),
          ),
          const SizedBox(height: 16),
          LargeActionButton(
            label: '햄버거 주문 연습으로 돌아가기',
            icon: Icons.arrow_back_rounded,
            secondary: true,
            onPressed: () {
              context.read<LearningProgressProvider>().resetHamburgerLearning();
              context.go(AppRoutes.hamburgerStart);
            },
          ),
        ],
      ),
    );
  }
}
