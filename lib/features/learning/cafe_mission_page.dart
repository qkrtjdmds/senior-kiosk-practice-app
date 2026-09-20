import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../shared/widgets/large_action_button.dart';
import '../../shared/widgets/page_scaffold.dart';
import 'cafe_order_mission.dart';
import 'learning_progress_provider.dart';

class CafeMissionPage extends StatelessWidget {
  const CafeMissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mission = CafeOrderMission.today;

    return PageScaffold(
      title: '혼자 해보기',
      backRoute: AppRoutes.cafeStart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '오늘의 주문 미션',
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
                  Icons.assignment_outlined,
                  size: 76,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 18),
                Text(
                  mission.displayOrder,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
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
            onPressed: () => context.go(AppRoutes.cafeStepOne),
          ),
          const SizedBox(height: 16),
          LargeActionButton(
            label: '카페 학습으로 돌아가기',
            icon: Icons.arrow_back_rounded,
            secondary: true,
            onPressed: () {
              context.read<LearningProgressProvider>().clearCafeMode();
              context.go(AppRoutes.cafeStart);
            },
          ),
        ],
      ),
    );
  }
}
