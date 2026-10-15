import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import 'reward_models.dart';
import 'reward_progress_provider.dart';

class RewardSummaryPanel extends StatelessWidget {
  const RewardSummaryPanel({
    required this.rewards,
    required this.actionLabel,
    required this.onPressed,
    this.compact = false,
    this.showRewardCount = false,
    super.key,
  });

  final RewardProgressProvider rewards;
  final String actionLabel;
  final VoidCallback onPressed;
  final bool compact;
  final bool showRewardCount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final target = rewards.nextRequiredPoints;
    final progressLabel = target == null
        ? '모든 성장 보상을 획득했어요'
        : '다음 보상 $target점까지 ${rewards.currentPoints}점, '
              '${rewards.pointsUntilNextReward}점 남음';

    return Container(
      key: const Key('reward-summary-panel'),
      padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final vertical =
                  constraints.maxWidth < 310 ||
                  MediaQuery.textScalerOf(context).scale(1) >= 1.25;
              final points = _SummaryValue(
                label: '현재 연습 포인트',
                value: '${rewards.currentPoints}점',
              );
              final stage = _SummaryValue(
                label: '현재 성장 단계',
                value: rewards.currentGrowthStage,
              );
              if (vertical) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    points,
                    const SizedBox(height: AppSpacing.sm),
                    stage,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: points),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: stage),
                ],
              );
            },
          ),
          if (showRewardCount) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              '획득한 보상 ${rewards.unlockedCount} / ${rewards.totalRewardCount}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            target == null
                ? '모든 성장 보상을 획득했어요'
                : '다음 보상: ${rewards.nextRewardName}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            target == null
                ? '꾸준히 이어 온 연습을 축하해요.'
                : '${rewards.pointsUntilNextReward}점 더 모으면 받을 수 있어요.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            label: progressLabel,
            value: '${(rewards.progressToNextReward * 100).round()}퍼센트',
            child: ExcludeSemantics(
              child: LinearProgressIndicator(
                key: const Key('reward-progress-indicator'),
                value: rewards.progressToNextReward,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            key: const Key('open-rewards-button'),
            onPressed: onPressed,
            icon: const Icon(Icons.redeem_outlined),
            label: Text(actionLabel, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

class RewardListRow extends StatelessWidget {
  const RewardListRow({
    required this.reward,
    required this.status,
    required this.unlocked,
    required this.applied,
    super.key,
  });

  final RewardDefinition reward;
  final String status;
  final bool unlocked;
  final bool applied;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final statusColor = unlocked ? colors.primary : colors.onSurfaceVariant;
    final semanticLabel =
        '${reward.title}. ${reward.description}. ${rewardTypeLabel(reward.rewardType)}. '
        '누적 ${reward.requiredPoints}점. $status.';

    return Semantics(
      container: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.choiceHeight),
          padding: const EdgeInsets.all(AppSpacing.md),
          color: applied
              ? colors.secondaryContainer.withValues(alpha: 0.65)
              : Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: unlocked
                      ? colors.secondaryContainer
                      : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Icon(
                  rewardIcon(reward.rewardType),
                  color: statusColor,
                  size: 27,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.title,
                      softWrap: true,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      reward.description,
                      softWrap: true,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xxs,
                      children: [
                        _StatusLabel(
                          text: rewardTypeLabel(reward.rewardType),
                          emphasized: false,
                        ),
                        _StatusLabel(
                          text: '누적 ${reward.requiredPoints}점',
                          emphasized: false,
                        ),
                        _StatusLabel(text: status, emphasized: unlocked),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData rewardIcon(RewardType type) => switch (type) {
  RewardType.title => Icons.military_tech_outlined,
  RewardType.accessory => Icons.checkroom_outlined,
  RewardType.theme => Icons.palette_outlined,
  RewardType.expression => Icons.sentiment_very_satisfied_outlined,
  RewardType.unknown => Icons.help_outline_rounded,
};

String rewardTypeLabel(RewardType type) => switch (type) {
  RewardType.title => '칭호',
  RewardType.accessory => '한걸음이 꾸미기',
  RewardType.theme => '홈 테마',
  RewardType.expression => '특별 축하 표현',
  RewardType.unknown => '알 수 없는 보상',
};

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: AppSpacing.xxs),
      Text(
        value,
        softWrap: true,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    ],
  );
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.text, required this.emphasized});

  final String text;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: emphasized ? colors.secondaryContainer : colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: emphasized ? colors.primary : colors.onSurfaceVariant,
          fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}
