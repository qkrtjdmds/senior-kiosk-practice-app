import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../shared/widgets/page_scaffold.dart';
import 'learning_progress_provider.dart';

class CafeStartPage extends StatelessWidget {
  const CafeStartPage({super.key});

  void _selectMode(BuildContext context, CafeLearningMode mode) {
    context.read<LearningProgressProvider>().selectMode(mode);
    context.go(
      mode == CafeLearningMode.solo
          ? AppRoutes.cafeMission
          : AppRoutes.cafeStepOne,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: '카페 키오스크 연습',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('카페 키오스크 연습', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 18),
          Text(
            '실제 주문 전에 화면을 보며 천천히 연습해볼 수 있어요.',
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
                    Icons.touch_app_rounded,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 18),
                Text('연습용 키오스크', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  '화면을 천천히 보고\n원하는 곳을 눌러보세요.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _ModeCard(
            title: '따라 해보기',
            description: '화면의 안내를 보며 천천히 연습해요.',
            icon: Icons.menu_book_outlined,
            onPressed: () => _selectMode(context, CafeLearningMode.guided),
          ),
          const SizedBox(height: 18),
          _ModeCard(
            title: '혼자 해보기',
            description: '배운 순서를 떠올리며 직접 주문해봐요.',
            icon: Icons.self_improvement_outlined,
            secondary: true,
            onPressed: () => _selectMode(context, CafeLearningMode.solo),
          ),
          const SizedBox(height: 22),
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
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = secondary
        ? colorScheme.surfaceContainerHighest
        : colorScheme.primaryContainer;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colorScheme.outlineVariant, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, size: 46, color: colorScheme.primary),
              const SizedBox(width: 18),
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
              Icon(
                Icons.chevron_right_rounded,
                size: 34,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
