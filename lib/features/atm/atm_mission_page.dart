import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_routes.dart';
import '../../shared/widgets/large_action_button.dart';
import '../../shared/widgets/page_scaffold.dart';

class AtmMissionPage extends StatelessWidget {
  const AtmMissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PageScaffold(
      title: '혼자 해보기',
      backRoute: AppRoutes.atmStart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '오늘의 ATM 출금 미션',
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
                  '5만 원 찾기',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 14),
                Text(
                  '마지막에 카드와 현금을 챙겨주세요.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                Text(
                  '출금 순서를 기억하고 직접 선택해보세요.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          LargeActionButton(
            label: '혼자 출금해보기',
            icon: Icons.play_arrow_rounded,
            onPressed: () => context.go(AppRoutes.atmPractice),
          ),
          const SizedBox(height: 16),
          LargeActionButton(
            label: 'ATM 출금 연습으로 돌아가기',
            icon: Icons.arrow_back_rounded,
            secondary: true,
            onPressed: () => context.go(AppRoutes.atmStart),
          ),
        ],
      ),
    );
  }
}
