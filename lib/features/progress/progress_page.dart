import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../learning/learning_progress_provider.dart';
import '../../shared/widgets/page_scaffold.dart';
import 'recent_practice_record.dart';
import '../../shared/widgets/han_geoleum_character.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({this.isTabPage = false, super.key});

  final bool isTabPage;

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<LearningProgressProvider>();

    return PageScaffold(
      title: isTabPage ? '내 정보' : '나의 디지털 걸음',
      showBackButton: !isTabPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _LocalRecordIntro(),
          const SizedBox(height: AppSpacing.md),
          _GrowthSummary(progress: progress),
          const SizedBox(height: AppSpacing.lg),
          const _SectionHeading(
            title: '콘텐츠별 연습 현황',
            description: '따라 해보기와 혼자 해보기 완료 횟수를 합쳐서 보여줘요.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _ContentProgressSection(progress: progress),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeading(
            title: '배지',
            description: '${_earnedBadgeCount(progress)}개를 획득했어요.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _BadgeCard(progress: progress),
          const SizedBox(height: AppSpacing.lg),
          const _SectionHeading(
            title: '최근 활동',
            description: '최근에 완료한 연습부터 차례로 보여줘요.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _RecentPracticeSection(records: progress.recentPracticeRecords),
          const SizedBox(height: AppSpacing.lg),
          const _SectionHeading(
            title: '설정 및 관리',
            description: '화면을 편하게 바꾸고 저장된 기록을 관리해요.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoLinkCard(
            title: '화면 설정',
            description: _settingsDescription(progress),
            icon: Icons.settings_outlined,
            onPressed: () => context.push(AppRoutes.accessibilitySettings),
          ),
          const SizedBox(height: AppSpacing.md),
          _RecordManagement(onReset: () => _confirmPracticeReset(context)),
          if (!isTabPage) ...[
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.home),
              icon: const Icon(Icons.home_outlined),
              label: const Text('홈으로'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmPracticeReset(BuildContext context) async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        title: const Text('연습 기록을 초기화할까요?', softWrap: true),
        content: const Text(
          '연습 포인트, 완료 횟수, 배지와 최근 기록이 처음 상태로 돌아가요. '
          '글씨 크기, 화면 대비와 시작 안내 완료 상태는 유지돼요.',
          softWrap: true,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('취소', textAlign: TextAlign.center),
              ),
              const SizedBox(height: AppSpacing.sm),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(
                    dialogContext,
                  ).colorScheme.errorContainer,
                  foregroundColor: Theme.of(
                    dialogContext,
                  ).colorScheme.onErrorContainer,
                ),
                child: const Text('초기화하기', textAlign: TextAlign.center),
              ),
            ],
          ),
        ],
      ),
    );
    if (shouldReset != true || !context.mounted) return;

    await context.read<LearningProgressProvider>().resetPracticeRecords();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('연습 기록을 처음 상태로 되돌렸어요.')));
  }
}

String _settingsDescription(LearningProgressProvider progress) {
  final textSize = switch (progress.accessibilityTextSize) {
    AccessibilityTextSize.normal => '보통',
    AccessibilityTextSize.large => '크게',
    AccessibilityTextSize.extraLarge => '아주 크게',
  };
  final contrast = switch (progress.screenContrast) {
    ScreenContrast.comfortable => '편안한 화면',
    ScreenContrast.vivid => '선명한 화면',
  };
  return '글씨 크기 $textSize · $contrast';
}

int _earnedBadgeCount(LearningProgressProvider progress) => [
  progress.soloFirstBadgeEarned,
  progress.cafeFamiliarBadgeEarned,
  progress.hospitalSoloFirstBadgeEarned,
  progress.photoSoloFirstBadgeEarned,
  progress.trainSoloFirstBadgeEarned,
  progress.hamburgerSoloFirstBadgeEarned,
  progress.atmSoloFirstBadgeEarned,
  progress.civilDocumentSoloFirstBadgeEarned,
].where((earned) => earned).length;

int _totalCompletionCount(LearningProgressProvider progress) =>
    progress.cafeCompletionCount +
    progress.hospitalCompletionCount +
    progress.hospitalSoloCompletionCount +
    progress.hospitalReservationCompletionCount +
    progress.hospitalReservationSoloCompletionCount +
    progress.hospitalPaymentCompletionCount +
    progress.hospitalPaymentSoloCompletionCount +
    progress.hospitalDocumentCompletionCount +
    progress.hospitalDocumentSoloCompletionCount +
    progress.photoCompletionCount +
    progress.photoSoloCompletionCount +
    progress.trainCompletionCount +
    progress.trainSoloCompletionCount +
    progress.hamburgerCompletionCount +
    progress.hamburgerSoloCompletionCount +
    progress.atmCompletionCount +
    progress.atmSoloCompletionCount +
    progress.civilDocumentCompletionCount +
    progress.civilDocumentSoloCompletionCount;

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Semantics(
        header: true,
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      const SizedBox(height: AppSpacing.xxs),
      Text(description, style: Theme.of(context).textTheme.bodyMedium),
    ],
  );
}

class _RecordManagement extends StatelessWidget {
  const _RecordManagement({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('record-management-section'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: 0.72),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.history_toggle_off_rounded,
                size: 30,
                color: AppColors.warning,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '연습 기록 초기화',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '포인트, 완료 횟수, 배지와 최근 기록을 처음 상태로 되돌려요.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            button: true,
            label:
                '연습 기록 초기화. 포인트, 완료 횟수, 배지와 최근 기록을 '
                '처음 상태로 되돌리는 위험 동작입니다. 확인 창이 열립니다.',
            child: ExcludeSemantics(
              child: OutlinedButton.icon(
                key: const Key('progress-reset-button'),
                onPressed: onReset,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('연습 기록 초기화', textAlign: TextAlign.center),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  side: BorderSide(
                    color: AppColors.warning.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLinkCard extends StatelessWidget {
  const _InfoLinkCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: '$title. $description. 시작 안내, 개인정보 안내와 앱 정보를 확인할 수 있어요.',
      child: ExcludeSemantics(
        child: Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.small),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppRadius.small),
            child: Container(
              constraints: const BoxConstraints(
                minHeight: AppSizes.buttonHeight,
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.small),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 30, color: colors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(Icons.chevron_right_rounded, color: colors.primary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentPracticeSection extends StatelessWidget {
  const _RecentPracticeSection({required this.records});

  final List<RecentPracticeRecord> records;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Container(
        key: const Key('empty-recent-activity'),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Column(
          children: [
            const HanGeoleumCharacter(mood: HanGeoleumMood.empty, size: 52),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '아직 완료한 연습이 없어요.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '홈이나 연습하기에서 천천히 시작해 보세요.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.practice),
              icon: const Icon(Icons.apps_outlined),
              label: const Text('연습하러 가기'),
            ),
          ],
        ),
      );
    }
    return _FlatSection(
      key: const Key('recent-activity-section'),
      children: records
          .map((record) => _RecentPracticeCard(record: record))
          .toList(growable: false),
    );
  }
}

class _RecentPracticeCard extends StatelessWidget {
  const _RecentPracticeCard({required this.record});

  final RecentPracticeRecord record;

  @override
  Widget build(BuildContext context) {
    final time = formatRecentPracticeTime(record.completedAt, DateTime.now());
    return Semantics(
      container: true,
      label:
          '${record.learningName}. ${record.modeName}. 연습 포인트 ${record.points}점. '
          '${record.detail == null ? '' : '${record.detail}. '}$time.',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.history_rounded,
                size: 28,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.learningName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${record.modeName} · 연습 포인트 +${record.points}점',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (record.detail != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        record.detail!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      time,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
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

class _LocalRecordIntro extends StatelessWidget {
  const _LocalRecordIntro();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      label:
          '나의 디지털 걸음. 이 기기에 저장된 연습 기록이에요. '
          '로그인 없이 사용할 수 있어요. 앱을 삭제하거나 기기를 바꾸면 기록이 사라질 수 있어요.',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: colors.secondaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Builder(
            builder: (context) {
              final useVerticalLayout =
                  MediaQuery.sizeOf(context).width <= 330 ||
                  MediaQuery.textScalerOf(context).scale(1) >= 1.25;
              final text = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '나의 디지털 걸음',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '이 기기에 저장된 연습 기록이에요.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '로그인 없이 사용할 수 있어요. 앱을 삭제하거나 기기를 바꾸면 기록이 사라질 수 있어요.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              );
              if (useVerticalLayout) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HanGeoleumCharacter(
                      mood: HanGeoleumMood.guide,
                      size: 52,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    text,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HanGeoleumCharacter(
                    mood: HanGeoleumMood.guide,
                    size: 52,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: text),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GrowthSummary extends StatelessWidget {
  const _GrowthSummary({required this.progress});

  final LearningProgressProvider progress;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final completionCount = _totalCompletionCount(progress);
    final badgeCount = _earnedBadgeCount(progress);
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return Semantics(
      key: const Key('growth-summary'),
      container: true,
      label:
          '성장 요약. 연습 포인트 ${progress.totalPoints}점. '
          '전체 연습 $completionCount회 완료. 배지 $badgeCount개 획득.',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.outlineVariant),
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final vertical = constraints.maxWidth < 330 || scale >= 1.25;
              final items = [
                _SummaryMetric(
                  value: '${progress.totalPoints}점',
                  label: '연습 포인트',
                  icon: Icons.favorite_outline_rounded,
                ),
                _SummaryMetric(
                  value: '$completionCount회',
                  label: '전체 연습 완료',
                  icon: Icons.task_alt_rounded,
                ),
                _SummaryMetric(
                  value: '$badgeCount개',
                  label: '획득 배지',
                  icon: Icons.workspace_premium_outlined,
                ),
              ];
              if (vertical) {
                return Column(
                  children: [
                    for (var index = 0; index < items.length; index++) ...[
                      items[index],
                      if (index < items.length - 1)
                        const Divider(height: AppSpacing.lg),
                    ],
                  ],
                );
              }
              return IntrinsicHeight(
                child: Row(
                  children: [
                    for (var index = 0; index < items.length; index++) ...[
                      Expanded(child: items[index]),
                      if (index < items.length - 1)
                        const VerticalDivider(width: AppSpacing.lg),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: AppSpacing.xs),
      Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              softWrap: false,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    ],
  );
}

class _ContentProgressSection extends StatelessWidget {
  const _ContentProgressSection({required this.progress});

  final LearningProgressProvider progress;

  @override
  Widget build(BuildContext context) {
    final hospitalVisit =
        progress.hospitalCompletionCount + progress.hospitalSoloCompletionCount;
    final hospitalReservation =
        progress.hospitalReservationCompletionCount +
        progress.hospitalReservationSoloCompletionCount;
    final hospitalPayment =
        progress.hospitalPaymentCompletionCount +
        progress.hospitalPaymentSoloCompletionCount;
    final hospitalDocument =
        progress.hospitalDocumentCompletionCount +
        progress.hospitalDocumentSoloCompletionCount;
    return _FlatSection(
      key: const Key('content-progress-section'),
      children: [
        _RecordRow(
          icon: Icons.local_cafe_outlined,
          label: '카페 주문',
          count: progress.cafeCompletionCount,
        ),
        _RecordRow(
          icon: Icons.lunch_dining_outlined,
          label: '햄버거 주문',
          count:
              progress.hamburgerCompletionCount +
              progress.hamburgerSoloCompletionCount,
        ),
        _RecordRow(
          icon: Icons.local_hospital_outlined,
          label: '병원 무인접수',
          count:
              hospitalVisit +
              hospitalReservation +
              hospitalPayment +
              hospitalDocument,
          detail:
              '진료 접수 $hospitalVisit회 · 예약 확인 $hospitalReservation회 · '
              '진료비 수납 $hospitalPayment회 · 서류 발급 $hospitalDocument회',
        ),
        _RecordRow(
          icon: Icons.train_outlined,
          label: '기차표 예매',
          count:
              progress.trainCompletionCount + progress.trainSoloCompletionCount,
        ),
        _RecordRow(
          icon: Icons.local_atm_outlined,
          label: 'ATM 출금',
          count: progress.atmCompletionCount + progress.atmSoloCompletionCount,
        ),
        _RecordRow(
          icon: Icons.print_outlined,
          label: '무인민원발급기',
          count:
              progress.civilDocumentCompletionCount +
              progress.civilDocumentSoloCompletionCount,
        ),
        _RecordRow(
          icon: Icons.photo_outlined,
          label: '사진 보내기',
          count:
              progress.photoCompletionCount + progress.photoSoloCompletionCount,
        ),
      ],
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.progress});

  final LearningProgressProvider progress;

  @override
  Widget build(BuildContext context) {
    final items = [
      _BadgeItem(
        icon: Icons.emoji_events_outlined,
        name: '혼자 주문 첫걸음',
        description: '카페 주문 혼자 해보기를 처음 완료하면 받을 수 있어요.',
        earned: progress.soloFirstBadgeEarned,
      ),
      _BadgeItem(
        icon: Icons.local_cafe_outlined,
        name: '카페 주문 익숙해졌어요',
        description: '카페 주문 혼자 해보기를 3회 완료하면 받을 수 있어요.',
        earned: progress.cafeFamiliarBadgeEarned,
      ),
      _BadgeItem(
        icon: Icons.local_hospital_outlined,
        name: '혼자 병원 접수 첫걸음',
        description: '병원 접수 혼자 해보기를 처음 완료하면 받을 수 있어요.',
        earned: progress.hospitalSoloFirstBadgeEarned,
      ),
      _BadgeItem(
        icon: Icons.photo_outlined,
        name: '혼자 사진 보내기 첫걸음',
        description: '사진 보내기 혼자 해보기를 처음 완료하면 받을 수 있어요.',
        earned: progress.photoSoloFirstBadgeEarned,
      ),
      _BadgeItem(
        icon: Icons.train_outlined,
        name: '기차표 예매 첫걸음',
        description: '기차표 예매 혼자 해보기를 처음 완료하면 받을 수 있어요.',
        earned: progress.trainSoloFirstBadgeEarned,
      ),
      _BadgeItem(
        icon: Icons.lunch_dining_outlined,
        name: '혼자 햄버거 주문 첫걸음',
        description: '햄버거 주문 혼자 해보기를 처음 완료하면 받을 수 있어요.',
        earned: progress.hamburgerSoloFirstBadgeEarned,
      ),
      _BadgeItem(
        icon: Icons.local_atm_outlined,
        name: '혼자 ATM 출금 첫걸음',
        description: 'ATM 출금 혼자 해보기를 처음 완료하면 받을 수 있어요.',
        earned: progress.atmSoloFirstBadgeEarned,
      ),
      _BadgeItem(
        icon: Icons.print_outlined,
        name: '혼자 서류 발급 첫걸음',
        description: '서류 발급 혼자 해보기를 처음 완료하면 받을 수 있어요.',
        earned: progress.civilDocumentSoloFirstBadgeEarned,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_earnedBadgeCount(progress) == 0) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: const Row(
              children: [
                HanGeoleumCharacter(mood: HanGeoleumMood.cheer, size: 48),
                SizedBox(width: AppSpacing.sm),
                Expanded(child: Text('첫 연습을 완료하면 배지를 받을 수 있어요.')),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        _FlatSection(key: const Key('badge-section'), children: items),
      ],
    );
  }
}

class _FlatSection extends StatelessWidget {
  const _FlatSection({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1)
              const Divider(
                height: 1,
                indent: AppSpacing.md,
                endIndent: AppSpacing.md,
              ),
          ],
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({
    required this.icon,
    required this.label,
    required this.count,
    this.detail,
  });

  final IconData icon;
  final String label;
  final int count;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return Semantics(
      container: true,
      label: '$label, $count회 완료${detail == null ? '' : ', $detail'}',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 30,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.titleMedium),
                    if (detail != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        detail!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    if (scale >= 1.25) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '$count회 완료',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              if (scale < 1.25) ...[
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '$count회 완료',
                  softWrap: false,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
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
  });

  final IconData icon;
  final String name;
  final String description;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      label: '$name. $description. ${earned ? '획득' : '아직 획득 전'}.',
      child: ExcludeSemantics(
        child: Container(
          color: earned
              ? colorScheme.secondaryContainer.withValues(alpha: 0.65)
              : Colors.transparent,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                earned ? icon : Icons.lock_outline_rounded,
                size: 32,
                color: earned
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          earned
                              ? Icons.check_circle_outline_rounded
                              : Icons.schedule_rounded,
                          size: 20,
                          color: earned
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Flexible(
                          child: Text(
                            earned ? '획득' : '아직 획득 전',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: earned
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
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
