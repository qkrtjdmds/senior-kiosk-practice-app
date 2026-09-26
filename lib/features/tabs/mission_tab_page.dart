import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
          Text(
            '오늘 준비된 세 가지 연습에 도전해 보세요.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '${daily.koreanDateLabel} 자정까지',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${daily.completedCount} / 3 완료',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Semantics(
            label: '오늘의 미션 ${daily.completedCount}개 완료',
            child: LinearProgressIndicator(value: daily.progress, minHeight: 8),
          ),
          if (daily.inlineMessage != null) ...[
            const SizedBox(height: 16),
            _InlineMessage(message: daily.inlineMessage!),
          ],
          const SizedBox(height: 24),
          for (final mission in daily.missions) ...[
            _DailyMissionTile(
              mission: mission,
              onPressed: () => _startMission(context, mission),
            ),
            const SizedBox(height: 12),
          ],
          if (daily.allCompleted) ...[
            const SizedBox(height: 4),
            const _InlineMessage(
              message: '오늘의 미션을 모두 마쳤어요. 천천히 멋지게 해내셨어요!',
              icon: Icons.celebration_outlined,
            ),
          ],
          const SizedBox(height: 14),
          Text(
            '일반 연습은 오늘의 미션과 관계없이 언제든 계속할 수 있어요.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
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

class _DailyMissionTile extends StatelessWidget {
  const _DailyMissionTile({required this.mission, required this.onPressed});
  final DailyMission mission;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final completed = mission.isCompleted;
    return Material(
      color: completed
          ? colors.secondaryContainer.withValues(alpha: 0.65)
          : colors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: colors.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                completed
                    ? Icons.check_circle_rounded
                    : mission.definition.icon,
                size: 38,
                color: colors.primary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.definition.title,
                      softWrap: true,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      mission.definition.description,
                      softWrap: true,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      completed ? '완료 · 추가 보상 지급 완료' : '완료하면 추가 포인트 10점',
                      softWrap: true,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      completed ? '완료' : '연습 시작하기',
                      softWrap: true,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                completed
                    ? Icons.replay_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: 22,
                color: colors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({
    required this.message,
    this.icon = Icons.info_outline_rounded,
  });
  final String message;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            softWrap: true,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    ),
  );
}
