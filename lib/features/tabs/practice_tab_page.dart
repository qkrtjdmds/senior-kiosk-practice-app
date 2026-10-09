import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../shared/widgets/app_ui.dart';
import '../../shared/widgets/han_geoleum_character.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../daily_mission/daily_mission_provider.dart';

class PracticeTabPage extends StatelessWidget {
  const PracticeTabPage({super.key});

  static const _items =
      <({String title, String description, IconData icon, String route})>[
        (
          title: '카페 주문',
          description: '음료를 골라 주문하는 순서를 연습해요.',
          icon: Icons.local_cafe_outlined,
          route: AppRoutes.cafeStart,
        ),
        (
          title: '햄버거 주문',
          description: '메뉴와 세트를 골라 주문해요.',
          icon: Icons.lunch_dining_outlined,
          route: AppRoutes.hamburgerStart,
        ),
        (
          title: '병원 무인접수',
          description: '접수와 병원 무인기기 사용을 연습해요.',
          icon: Icons.local_hospital_outlined,
          route: AppRoutes.hospitalStart,
        ),
        (
          title: '기차표 예매',
          description: '여정과 좌석을 골라 예매해요.',
          icon: Icons.train_outlined,
          route: AppRoutes.trainStart,
        ),
        (
          title: 'ATM 출금',
          description: '카드와 현금을 챙기는 순서를 연습해요.',
          icon: Icons.account_balance_outlined,
          route: AppRoutes.atmStart,
        ),
        (
          title: '무인민원발급기',
          description: '필요한 서류를 고르고 발급해요.',
          icon: Icons.description_outlined,
          route: AppRoutes.civilDocumentStart,
        ),
        (
          title: '사진 보내기',
          description: '받는 사람과 사진을 확인해 보내요.',
          icon: Icons.photo_outlined,
          route: AppRoutes.photoStart,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: '연습하기',
      showBackButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _PracticeIntro(),
          const SizedBox(height: AppSpacing.sm),
          const _ModeGuide(),
          const SizedBox(height: AppSpacing.lg),
          Text('연습을 선택하세요', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          for (final item in _items) ...[
            AppListRow(
              icon: item.icon,
              title: item.title,
              description: item.description,
              compact: true,
              onTap: () {
                context.read<DailyMissionProvider>().cancelActiveMission();
                context.push(item.route);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _PracticeIntro extends StatelessWidget {
  const _PracticeIntro();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.sm),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(AppRadius.medium),
    ),
    child: const Row(
      children: [
        ExcludeSemantics(
          child: HanGeoleumCharacter(mood: HanGeoleumMood.guide, size: 52),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(child: Text('도움을 받으며 따라 하거나, 혼자 도전해 보세요.')),
      ],
    ),
  );
}

class _ModeGuide extends StatelessWidget {
  const _ModeGuide();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(1);
      final horizontal = constraints.maxWidth >= 320 && scale <= 1.2;
      final guided = const _ModeSummary(
        icon: Icons.menu_book_outlined,
        title: '따라 해보기',
        description: '화면의 안내를 따라 한 단계씩 연습해요.',
        reward: '완료하면 연습 포인트 10점',
      );
      final solo = const _ModeSummary(
        icon: Icons.outlined_flag,
        title: '혼자 해보기',
        description: '목표를 보고 스스로 순서를 선택해요. 힌트도 볼 수 있어요.',
        reward: '완료하면 연습 포인트 20점',
      );
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: horizontal
            ? IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(child: guided),
                    VerticalDivider(
                      width: 1,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    Expanded(child: solo),
                  ],
                ),
              )
            : Column(
                children: [
                  guided,
                  Divider(
                    height: 1,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  solo,
                ],
              ),
      );
    },
  );
}

class _ModeSummary extends StatelessWidget {
  const _ModeSummary({
    required this.icon,
    required this.title,
    required this.description,
    required this.reward,
  });

  final IconData icon;
  final String title;
  final String description;
  final String reward;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: '$title. $description $reward',
    child: ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(description, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              reward,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
