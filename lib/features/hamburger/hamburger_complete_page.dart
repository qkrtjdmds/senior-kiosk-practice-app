import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../learning/learning_progress_provider.dart';
import '../daily_mission/daily_mission.dart';
import '../daily_mission/daily_mission_provider.dart';
import '../learning/widgets/learning_widgets.dart';

class HamburgerCompletePage extends StatefulWidget {
  const HamburgerCompletePage({super.key});

  @override
  State<HamburgerCompletePage> createState() => _HamburgerCompletePageState();
}

class _HamburgerCompletePageState extends State<HamburgerCompletePage> {
  bool _showFirstBadge = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final progress = context.read<LearningProgressProvider>();
      final daily = context.read<DailyMissionProvider>();
      var firstBadge = false;
      if (progress.isHamburgerSoloMode) {
        final before = progress.hamburgerSoloCompletionCount;
        firstBadge = await progress.completeHamburgerSoloLearning();
        if (progress.hamburgerSoloCompletionCount > before) {
          await daily.completeActiveMission(MissionContentType.hamburger);
        }
      } else {
        await progress.completeHamburgerLearning();
      }
      if (mounted && firstBadge) {
        setState(() => _showFirstBadge = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<LearningProgressProvider>();
    final colors = Theme.of(context).colorScheme;
    final mission = progress.currentHamburgerMission;
    final isSolo = progress.isHamburgerSoloMode;

    return LearningCompletionLayout(
      title: isSolo ? '혼자서도 잘하셨어요!' : '잘하셨어요!',
      message: isSolo ? '오늘의 햄버거 주문 미션을 완성했어요.' : '햄버거 주문 순서를 천천히 잘 따라오셨어요.',
      reward: isSolo ? '용기 포인트 +20점' : '한걸음 포인트 +10점',
      badge: _showFirstBadge
          ? Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.tertiaryContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.tertiary),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.workspace_premium_outlined,
                    size: 46,
                    color: colors.tertiary,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '혼자 햄버거 주문 첫걸음',
                          softWrap: true,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '처음으로 혼자 햄버거 주문 미션을 완성했어요.',
                          softWrap: true,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : null,
      summary: LearningSummaryCard(
        title: '연습 완료 내역',
        icon: Icons.emoji_events_outlined,
        items: [
          if (isSolo)
            LearningSummaryItem(label: '오늘의 미션', value: mission.title),
          LearningSummaryItem(
            label: '완료 횟수',
            value: isSolo
                ? '${progress.hamburgerSoloCompletionCount}회'
                : '${progress.hamburgerCompletionCount}회',
          ),
        ],
        footer: '메뉴를 고른 뒤 장바구니를 확인하는 것을 기억해보세요.',
      ),
      onRestart: () async {
        final progress = context.read<LearningProgressProvider>();
        if (progress.isHamburgerSoloMode) {
          await progress.startHamburgerSoloMission();
          if (context.mounted) context.go(AppRoutes.hamburgerMission);
          return;
        }
        progress.resetHamburgerLearning();
        context.go(AppRoutes.hamburgerPractice);
      },
      onHome: () => context.go(AppRoutes.home),
    );
  }
}
