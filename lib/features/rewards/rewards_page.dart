import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_theme.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/han_geoleum_character.dart';
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
          _RewardPreview(rewards: rewards),
          if (rewards.selectionMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Semantics(
              liveRegion: true,
              child: Container(
                key: const Key('reward-selection-message'),
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Text(rewards.selectionMessage!),
              ),
            ),
          ],
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
    final groups = <RewardType, List<RewardDefinition>>{
      for (final type in RewardType.values)
        if (type != RewardType.unknown)
          type: rewards.activeRewards
              .where((reward) => reward.rewardType == type)
              .toList(),
    };
    return Column(
      key: const Key('reward-list'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in groups.entries)
          if (entry.value.isNotEmpty) ...[
            Text(
              rewardTypeLabel(entry.key),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            if (entry.key == RewardType.title)
              _DefaultChoice(
                label: '칭호 사용 안 함',
                selected: rewards.state.selectedTitleId == null,
                onTap: () => rewards.selectTitle(null),
              ),
            if (entry.key == RewardType.accessory)
              _DefaultChoice(
                label: '장식 모두 벗기기',
                selected: rewards.selectedAccessoryIds.isEmpty,
                onTap: rewards.clearAccessories,
              ),
            if (entry.key == RewardType.theme)
              _DefaultChoice(
                label: '기본 아이보리',
                selected: rewards.state.selectedThemeId == null,
                onTap: () => rewards.selectTheme(null),
              ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var index = 0; index < entry.value.length; index++) ...[
                    RewardListRow(
                      reward: entry.value[index],
                      status: rewards.statusFor(entry.value[index]),
                      unlocked: rewards.isUnlocked(entry.value[index]),
                      applied: rewards.isApplied(entry.value[index]),
                      onTap: _actionFor(rewards, entry.value[index]),
                    ),
                    if (index < entry.value.length - 1)
                      const Divider(height: 1),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
      ],
    );
  }

  VoidCallback? _actionFor(
    RewardProgressProvider rewards,
    RewardDefinition reward,
  ) {
    if (!rewards.isUnlocked(reward) || !reward.isActive) return null;
    return switch (reward.rewardType) {
      RewardType.title => () => rewards.selectTitle(reward.rewardId),
      RewardType.accessory => () => rewards.toggleAccessory(reward.rewardId),
      RewardType.theme => () => rewards.selectTheme(reward.rewardId),
      RewardType.expression || RewardType.unknown => null,
    };
  }
}

class _RewardPreview extends StatelessWidget {
  const _RewardPreview({required this.rewards});

  final RewardProgressProvider rewards;

  @override
  Widget build(BuildContext context) {
    final title = rewards.selectedTitle?.title ?? '선택한 칭호 없음';
    final accessories = rewards.selectedAccessoryIds
        .map((id) => rewards.catalog.byId(id)?.title)
        .whereType<String>()
        .join(', ');
    return Semantics(
      container: true,
      label:
          '현재 보상 미리보기. $title. ${rewards.selectedThemeName} 테마. '
          '${accessories.isEmpty ? '착용한 장식 없음' : '착용한 장식 $accessories'}.',
      child: ExcludeSemantics(
        child: Container(
          key: const Key('reward-preview'),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: RewardHomePalette.of(
              context,
              rewards.state.selectedThemeId,
            ).welcome,
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final copy = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('현재 모습', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(rewards.selectedThemeName),
                ],
              );
              final character = HanGeoleumCharacter(
                mood: HanGeoleumMood.cheer,
                size: 92,
                accessoryIds: rewards.selectedAccessoryIds,
              );
              if (constraints.maxWidth < 290) {
                return Column(children: [character, copy]);
              }
              return Row(
                children: [
                  character,
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: copy),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DefaultChoice extends StatelessWidget {
  const _DefaultChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Future<bool> Function() onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: '$label, ${selected ? '적용 중' : '선택 가능'}',
    onTap: onTap,
    child: ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(
            selected ? Icons.check_circle_rounded : Icons.undo_rounded,
          ),
          label: Text(label),
        ),
      ),
    ),
  );
}
