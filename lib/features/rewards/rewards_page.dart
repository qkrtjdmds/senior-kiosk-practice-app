import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_theme.dart';
import '../../shared/widgets/page_scaffold.dart';
import 'reward_models.dart';
import 'reward_progress_provider.dart';
import 'reward_widgets.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final rewards = context.watch<RewardProgressProvider>();
    return PageScaffold(
      title: '나의 보상',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RewardSummaryPanel(
            rewards: rewards,
            actionLabel: '보상 목록 보기',
            onPressed: () => _scrollToRewards(context),
          ),
          const SizedBox(height: AppSpacing.md),
          _PointPolicyNotice(unlockedCount: rewards.unlockedCount),
          const SizedBox(height: AppSpacing.lg),
          Text('보상 종류', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          const _RewardTypeGuide(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '전체 보상 ${rewards.unlockedCount} / ${rewards.totalRewardCount}',
            key: _rewardListKey,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '연습 포인트가 기준에 도달하면 자동으로 획득해요.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          _RewardList(rewards: rewards),
        ],
      ),
    );
  }

  static final _rewardListKey = GlobalKey();

  void _scrollToRewards(BuildContext context) {
    final targetContext = _rewardListKey.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }
}

class _PointPolicyNotice extends StatelessWidget {
  const _PointPolicyNotice({required this.unlockedCount});

  final int unlockedCount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      label:
          '연습 포인트 안내. 현재 $unlockedCount개 보상을 획득했습니다. '
          '누적 포인트는 보상을 받아도 줄어들지 않으며 현금 가치가 없습니다.',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: colors.secondaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: colors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '연습 포인트는 보상을 받아도 줄어들지 않아요. '
                  '현금으로 바꾸거나 다른 사람에게 보낼 수 없는 앱 안의 기록이에요.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardTypeGuide extends StatelessWidget {
  const _RewardTypeGuide();

  static const _items = <(RewardType, String)>[
    (RewardType.title, '칭호'),
    (RewardType.accessory, '한걸음이 꾸미기'),
    (RewardType.theme, '홈 테마'),
    (RewardType.expression, '특별 축하 표현'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final item in _items)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(rewardIcon(item.$1), size: 22),
                const SizedBox(width: AppSpacing.xs),
                Text(item.$2),
              ],
            ),
          ),
      ],
    );
  }
}

class _RewardList extends StatelessWidget {
  const _RewardList({required this.rewards});

  final RewardProgressProvider rewards;

  @override
  Widget build(BuildContext context) {
    final items = rewards.activeRewards;
    return Container(
      key: const Key('reward-list'),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            RewardListRow(
              reward: items[index],
              status: rewards.statusFor(items[index]),
              unlocked: rewards.isUnlocked(items[index]),
              applied: rewards.isApplied(items[index]),
            ),
            if (index < items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}
