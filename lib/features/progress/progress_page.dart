import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../learning/learning_progress_provider.dart';
import '../../shared/widgets/page_scaffold.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<LearningProgressProvider>();

    return PageScaffold(
      title: '나의 디지털 걸음',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PointsCard(points: progress.totalPoints),
          const SizedBox(height: 18),
          _CafeRecordCard(
            guidedCount: progress.guidedCompletionCount,
            soloCount: progress.soloCompletionCount,
          ),
          const SizedBox(height: 18),
          _BadgeCard(progress: progress),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.home),
            icon: const Icon(Icons.home_outlined),
            label: const Text('홈으로 돌아가기'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(66),
            ),
          ),
        ],
      ),
    );
  }
}

class _PointsCard extends StatelessWidget {
  const _PointsCard({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.favorite_outline_rounded,
            size: 46,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text('지금까지 모은 포인트', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            '$points점',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontSize: 38),
          ),
          const SizedBox(height: 8),
          Text(
            '한 번씩 연습할수록 디지털 자신감이 자라요.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _CafeRecordCard extends StatelessWidget {
  const _CafeRecordCard({required this.guidedCount, required this.soloCount});

  final int guidedCount;
  final int soloCount;

  @override
  Widget build(BuildContext context) {
    final totalCount = guidedCount + soloCount;

    return _SectionCard(
      title: '카페 키오스크 연습',
      icon: Icons.local_cafe_outlined,
      child: Column(
        children: [
          _RecordRow(label: '따라 해보기', value: '$guidedCount회'),
          const SizedBox(height: 12),
          _RecordRow(label: '혼자 해보기', value: '$soloCount회'),
          const Divider(height: 30),
          Text(
            '카페 주문을 모두 $totalCount번 연습했어요.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.progress});

  final LearningProgressProvider progress;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '내가 받은 배지',
      icon: Icons.workspace_premium_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BadgeItem(
            icon: Icons.emoji_events_outlined,
            name: '혼자 주문 첫걸음',
            description: '처음으로 혼자 주문 미션을 완성했어요.',
            earned: progress.soloFirstBadgeEarned,
            emptyTitle: '첫 배지를 향해 연습해볼까요?',
            emptyDescription: '혼자 해보기를 한 번 완료하면 받을 수 있어요.',
          ),
          const SizedBox(height: 16),
          _BadgeItem(
            icon: Icons.local_cafe_outlined,
            name: '카페 주문 익숙해졌어요',
            description: '혼자 해보기 3회 완료',
            earned: progress.cafeFamiliarBadgeEarned,
            emptyTitle: null,
            emptyDescription: null,
            progressLabel: '${progress.soloCompletionCount.clamp(0, 3)} / 3회',
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  const _BadgeItem({
    required this.icon,
    required this.name,
    required this.description,
    required this.earned,
    required this.emptyTitle,
    required this.emptyDescription,
    this.progressLabel,
  });

  final IconData icon;
  final String name;
  final String description;
  final bool earned;
  final String? emptyTitle;
  final String? emptyDescription;
  final String? progressLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: earned
            ? colorScheme.tertiaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: earned ? colorScheme.tertiary : colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            earned ? icon : Icons.lock_outline_rounded,
            size: 46,
            color: earned ? colorScheme.tertiary : colorScheme.outline,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  earned ? name : (emptyTitle ?? name),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 5),
                Text(
                  earned ? description : (emptyDescription ?? description),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (progressLabel != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    earned ? '달성했어요' : progressLabel!,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
