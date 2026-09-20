import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../shared/widgets/large_action_button.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../learning/learning_progress_provider.dart';

class CivilDocumentStartPage extends StatelessWidget {
  const CivilDocumentStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PageScaffold(
      title: '무인민원발급기 연습',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('무인민원발급기 연습', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 18),
          Text(
            '무인민원발급기에서 서류를 고르는 순서를 천천히 연습해볼 수 있어요.',
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
                  width: 190,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colors.primary, width: 2),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.desktop_windows_outlined,
                        size: 68,
                        color: colors.primary,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.description_outlined, size: 34),
                          const SizedBox(width: 18),
                          Icon(
                            Icons.print_outlined,
                            size: 34,
                            color: colors.tertiary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  '안전한 연습용 발급기',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '필요한 서류와 내용을 차례로 골라보세요.',
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
              color: colors.tertiaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 30,
                  color: colors.tertiary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '이 화면은 실제 서류를 발급하지 않는 연습용 화면이에요.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _ModeCard(
            title: '따라 해보기',
            description: '안내를 보며 순서대로 연습해요.',
            icon: Icons.menu_book_outlined,
            onPressed: () async {
              await context
                  .read<LearningProgressProvider>()
                  .startCivilDocumentLearning(CivilDocumentLearningMode.guided);
              if (context.mounted) {
                context.go(AppRoutes.civilDocumentPractice);
              }
            },
          ),
          const SizedBox(height: 18),
          _ModeCard(
            title: '혼자 해보기',
            description: '오늘의 미션을 보고 직접 선택해봐요.',
            icon: Icons.self_improvement_outlined,
            secondary: true,
            onPressed: () async {
              await context
                  .read<LearningProgressProvider>()
                  .startCivilDocumentLearning(CivilDocumentLearningMode.solo);
              if (context.mounted) {
                context.go(AppRoutes.civilDocumentMission);
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
