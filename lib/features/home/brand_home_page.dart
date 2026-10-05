import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../shared/widgets/app_ui.dart';
import '../../shared/widgets/han_geoleum_character.dart';
import '../daily_mission/daily_mission_provider.dart';
import '../learning/learning_progress_provider.dart';
import '../practice/practice_launcher.dart';

class BrandHomePage extends StatelessWidget {
  const BrandHomePage({super.key});

  static final _items =
      <
        ({
          String title,
          String description,
          IconData icon,
          PracticeContent content,
        })
      >[
        (
          title: '카페 주문',
          description: '메뉴를 고르고 주문하는 순서를 연습해요.',
          icon: Icons.local_cafe_outlined,
          content: PracticeContent.cafe,
        ),
        (
          title: '햄버거 주문',
          description: '메뉴와 세트를 골라 주문해요.',
          icon: Icons.lunch_dining_outlined,
          content: PracticeContent.hamburger,
        ),
        (
          title: '병원',
          description: '접수와 병원 무인기기 사용을 연습해요.',
          icon: Icons.local_hospital_outlined,
          content: PracticeContent.hospital,
        ),
        (
          title: '기차표 예매',
          description: '여정과 좌석을 골라 예매해요.',
          icon: Icons.train_outlined,
          content: PracticeContent.train,
        ),
        (
          title: 'ATM 출금',
          description: '카드와 현금을 안전하게 챙겨요.',
          icon: Icons.account_balance_outlined,
          content: PracticeContent.atm,
        ),
        (
          title: '무인민원발급기',
          description: '필요한 서류를 골라 발급해요.',
          icon: Icons.description_outlined,
          content: PracticeContent.civilDocument,
        ),
        (
          title: '사진 보내기',
          description: '받는 사람과 사진을 확인해 보내요.',
          icon: Icons.photo_outlined,
          content: PracticeContent.photo,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final daily = context.watch<DailyMissionProvider>();
    final progress = context.watch<LearningProgressProvider>();
    final horizontal = MediaQuery.sizeOf(context).width <= 340 ? 16.0 : 20.0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('한걸음 디지털'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.accessibilitySettings),
            icon: const Icon(Icons.settings_outlined),
            tooltip: '화면 설정',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CharacterMessage(
                title: '오늘도 한 걸음씩 연습해요',
                message: '실수해도 괜찮아요. 원하는 연습부터 편하게 시작해 보세요.',
                mood: HanGeoleumMood.welcome,
              ),
              const SizedBox(height: 24),
              _MissionSummary(
                completed: daily.completedCount,
                progress: daily.progress,
                allCompleted: daily.allCompleted,
                onTap: () => context.go(AppRoutes.missions),
              ),
              const SizedBox(height: 28),
              Text(
                '원하는 연습을 바로 시작해 보세요',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                '홈에서는 점수 없이 자유롭게 반복할 수 있어요.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              for (final item in _items) ...[
                AppListRow(
                  icon: item.icon,
                  title: item.title,
                  description: item.description,
                  label: '자유 연습',
                  onTap: () =>
                      PracticeLauncher.startFree(context, item.content),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 20),
              Text('최근 활동', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (progress.recentPracticeRecords.isEmpty)
                const CharacterMessage(
                  title: '첫 연습을 시작해 보세요',
                  message: '따라 해보기나 혼자 해보기를 마치면 여기에 기록이 보여요.',
                  mood: HanGeoleumMood.empty,
                )
              else
                AppListRow(
                  icon: Icons.history_rounded,
                  title: progress.recentPracticeRecords.first.learningName,
                  description: progress.recentPracticeRecords.first.modeName,
                  label: '${progress.recentPracticeRecords.first.points}점',
                  onTap: () => context.go(AppRoutes.progress),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionSummary extends StatelessWidget {
  const _MissionSummary({
    required this.completed,
    required this.progress,
    required this.allCompleted,
    required this.onTap,
  });
  final int completed;
  final double progress;
  final bool allCompleted;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(AppRadius.medium),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  allCompleted ? Icons.task_alt_rounded : Icons.flag_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '오늘의 미션 $completed / 3',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 10),
            Text(
              allCompleted ? '오늘도 한 걸음 나아갔어요' : '미션 보러 가기',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  );
}
