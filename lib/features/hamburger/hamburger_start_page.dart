import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../shared/widgets/large_action_button.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../learning/learning_progress_provider.dart';

class HamburgerStartPage extends StatelessWidget {
  const HamburgerStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PageScaffold(
      title: '햄버거 주문 연습',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('햄버거 주문 연습', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 18),
          Text(
            '키오스크에서 햄버거를 주문하는 순서를 천천히 연습해볼 수 있어요.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.outlineVariant, width: 2),
            ),
            child: Column(
              children: [
                Container(
                  width: 180,
                  height: 132,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.tablet_mac_outlined,
                        size: 112,
                        color: colors.primary,
                      ),
                      Positioned(
                        top: 38,
                        child: Row(
                          children: [
                            Icon(
                              Icons.lunch_dining,
                              size: 34,
                              color: colors.primary,
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.local_drink,
                              size: 30,
                              color: colors.tertiary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  '연습용 햄버거 키오스크',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '메뉴를 고르고 장바구니를 확인해보세요.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _ModeCard(
            title: '따라 해보기',
            description: '화면의 안내를 보며 천천히 주문 순서를 연습해요.',
            icon: Icons.menu_book_outlined,
            onPressed: () {
              context.read<LearningProgressProvider>().selectHamburgerMode(
                HamburgerLearningMode.guided,
              );
              context.go(AppRoutes.hamburgerPractice);
            },
          ),
          const SizedBox(height: 18),
          _ModeCard(
            title: '혼자 해보기',
            description: '오늘의 햄버거 주문 미션을 기억하고 직접 주문해봐요.',
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

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onPressed,
    this.secondary = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onPressed;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: secondary
          ? colors.surfaceContainerHighest
          : colors.primaryContainer,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: const BoxConstraints(minHeight: 112),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.outlineVariant, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, size: 42, color: colors.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}
