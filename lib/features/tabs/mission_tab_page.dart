import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_theme.dart';
import '../../shared/widgets/han_geoleum_character.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../daily_mission/daily_mission.dart';
import '../daily_mission/daily_mission_provider.dart';
import '../learning/learning_progress_provider.dart';

class MissionTabPage extends StatelessWidget {
  const MissionTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final daily = context.watch<DailyMissionProvider>();
    return PageScaffold(
      title: '오늘의 미션',
      showBackButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _MissionEncouragement(),
          const SizedBox(height: AppSpacing.sm),
          _MissionProgressSummary(
            dateLabel: daily.koreanDateLabel,
            completedCount: daily.completedCount,
            progress: daily.progress,
          ),
          if (daily.inlineMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _InlineMessage(message: daily.inlineMessage!),
          ],
          const SizedBox(height: AppSpacing.md),
          for (final mission in daily.missions) ...[
            _DailyMissionTile(
              mission: mission,
              onPressed: () => _startMission(context, mission),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (daily.allCompleted) ...[
            const _InlineMessage(
              message: '오늘의 미션을 모두 마쳤어요. 천천히 멋지게 해내셨어요!',
              icon: Icons.celebration_outlined,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _startMission(BuildContext context, DailyMission mission) async {
    final daily = context.read<DailyMissionProvider>();
    final progress = context.read<LearningProgressProvider>();
    switch (mission.definition.contentType) {
      case MissionContentType.cafe:
        progress.selectMode(CafeLearningMode.solo);
      case MissionContentType.hamburger:
        await progress.startHamburgerSoloMission();
      case MissionContentType.hospital:
        progress.selectHospitalMode(HospitalLearningMode.solo);
      case MissionContentType.train:
        progress.selectTrainMode(TrainLearningMode.solo);
      case MissionContentType.atm:
        await progress.startAtmLearning(AtmLearningMode.solo);
      case MissionContentType.civilDocument:
        await progress.startCivilDocumentLearning(
          CivilDocumentLearningMode.solo,
        );
      case MissionContentType.photo:
        progress.selectPhotoMode(PhotoLearningMode.solo);
    }
    daily.startMission(mission.definition.id);
    if (context.mounted) context.go(mission.definition.route);
  }
}

class _MissionEncouragement extends StatelessWidget {
  const _MissionEncouragement();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Row(
        children: [
          const HanGeoleumCharacter(mood: HanGeoleumMood.cheer, size: 52),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  label: '오늘도 한 걸음 해볼까요?',
                  header: true,
                  child: ExcludeSemantics(
                    child: Wrap(
                      spacing: AppSpacing.xs,
                      children: [
                        Text(
                          '오늘도 한 걸음',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '해볼까요?',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '세 가지 연습 중 하나부터 천천히 시작해 보세요.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionProgressSummary extends StatelessWidget {
  const _MissionProgressSummary({
    required this.dateLabel,
    required this.completedCount,
    required this.progress,
  });

  final String dateLabel;
  final int completedCount;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return Container(
      key: const Key('daily-mission-summary'),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: LayoutBuilder(
        builder: (context, _) {
          final vertical =
              MediaQuery.sizeOf(context).width <= 340 || scale >= 1.25;
          final date = Text(
            '$dateLabel 오늘의 미션',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          );
          final count = ExcludeSemantics(
            child: Text(
              '$completedCount / 3 완료',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: colors.primary),
            ),
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (vertical) ...[
                date,
                const SizedBox(height: AppSpacing.xs),
                count,
              ] else
                Row(
                  children: [
                    Expanded(child: date),
                    const SizedBox(width: AppSpacing.sm),
                    count,
                  ],
                ),
              const SizedBox(height: AppSpacing.xs),
              Semantics(
                label: '오늘의 미션 3개 중 $completedCount개 완료',
                value: '${(progress * 100).round()}퍼센트',
                child: ExcludeSemantics(
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '모두 완료하면 추가 포인트를 최대 30점 받을 수 있어요.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DailyMissionTile extends StatelessWidget {
  const _DailyMissionTile({required this.mission, required this.onPressed});
  final DailyMission mission;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final completed = mission.isCompleted;
    final title = _missionTitle(mission.definition.contentType);
    final description = _missionDescription(mission.definition.contentType);
    final semanticsLabel = completed
        ? '$title. $description. 완료. 추가 보상 10점 지급 완료.'
        : '$title. $description. 미완료. 미션 보상 10점. 연습 시작하기.';
    return Semantics(
      key: Key('daily-mission-card-${mission.definition.id}'),
      container: true,
      button: !completed,
      enabled: !completed,
      label: semanticsLabel,
      onTap: completed ? null : onPressed,
      child: ExcludeSemantics(
        child: Material(
          color: completed
              ? colors.secondaryContainer.withValues(alpha: 0.72)
              : colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.small),
          child: InkWell(
            onTap: completed ? null : onPressed,
            borderRadius: BorderRadius.circular(AppRadius.small),
            child: Container(
              constraints: const BoxConstraints(minHeight: 120),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                border: Border.all(color: colors.outlineVariant),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: LayoutBuilder(
                builder: (context, _) {
                  final scale = MediaQuery.textScalerOf(context).scale(1);
                  final vertical =
                      MediaQuery.sizeOf(context).width <= 340 || scale >= 1.25;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: completed
                                  ? colors.surface.withValues(alpha: 0.7)
                                  : colors.secondaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              completed
                                  ? Icons.check_rounded
                                  : mission.definition.icon,
                              size: 26,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                if (completed) ...[
                                  const SizedBox(height: AppSpacing.xxs),
                                  _StatusBadge(
                                    icon: Icons.check_rounded,
                                    label: '완료',
                                    color: colors.primary,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        description,
                        maxLines: vertical ? 3 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (completed)
                        _StatusBadge(
                          key: Key(
                            'daily-mission-reward-${mission.definition.id}',
                          ),
                          icon: Icons.verified_outlined,
                          label: '추가 보상 10점 지급 완료',
                          color: colors.primary,
                        )
                      else if (vertical)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _StatusBadge(
                              key: Key(
                                'daily-mission-reward-${mission.definition.id}',
                              ),
                              icon: Icons.add_circle_outline_rounded,
                              label: '미션 보상 +10점',
                              color: AppColors.sage,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            _MissionStartButton(
                              missionId: mission.definition.id,
                              onPressed: onPressed,
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: _StatusBadge(
                                key: Key(
                                  'daily-mission-reward-${mission.definition.id}',
                                ),
                                icon: Icons.add_circle_outline_rounded,
                                label: '미션 보상 +10점',
                                color: AppColors.sage,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            SizedBox(
                              width: 174,
                              child: _MissionStartButton(
                                missionId: mission.definition.id,
                                onPressed: onPressed,
                              ),
                            ),
                          ],
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MissionStartButton extends StatelessWidget {
  const _MissionStartButton({required this.missionId, required this.onPressed});

  final String missionId;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
    key: Key('daily-mission-action-$missionId'),
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(AppSizes.touchTarget),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
    ),
    child: const Text('연습 시작하기', textAlign: TextAlign.center, softWrap: true),
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.icon,
    required this.label,
    required this.color,
    super.key,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppRadius.small),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            softWrap: true,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

String _missionTitle(MissionContentType type) => switch (type) {
  MissionContentType.cafe => '카페 주문',
  MissionContentType.hamburger => '햄버거 주문',
  MissionContentType.hospital => '병원 접수',
  MissionContentType.train => '기차표 예매',
  MissionContentType.atm => 'ATM 출금',
  MissionContentType.civilDocument => '서류 발급',
  MissionContentType.photo => '사진 보내기',
};

String _missionDescription(MissionContentType type) => switch (type) {
  MissionContentType.cafe => '가상 키오스크 주문 연습을 혼자 완료해 보세요.',
  MissionContentType.hamburger => '햄버거 주문 연습을 혼자 완료해 보세요.',
  MissionContentType.hospital => '병원 접수 순서 연습을 혼자 완료해 보세요.',
  MissionContentType.train => '기차표 예매 연습을 혼자 완료해 보세요.',
  MissionContentType.atm => '5만 원 출금 연습을 완료해 보세요.',
  MissionContentType.civilDocument => '주민등록등본 발급 연습을 완료해 보세요.',
  MissionContentType.photo => '사진 보내기 연습을 혼자 완료해 보세요.',
};

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({
    required this.message,
    this.icon = Icons.info_outline_rounded,
  });
  final String message;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.sm),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(AppRadius.small),
    ),
    child: Row(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            message,
            softWrap: true,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    ),
  );
}
