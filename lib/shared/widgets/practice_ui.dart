import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../features/practice/practice_mode.dart';
import 'han_geoleum_character.dart';

String practiceModeLabel(PracticeMode mode, {bool dailyMission = false}) {
  if (dailyMission) return '오늘의 미션';
  return switch (mode) {
    PracticeMode.free => '자유 연습',
    PracticeMode.guided => '따라 해보기',
    PracticeMode.solo => '혼자 해보기',
  };
}

String practiceSessionLabel({
  required bool isFreePractice,
  required bool isSolo,
  bool dailyMission = false,
}) {
  if (isFreePractice) return '자유 연습';
  if (dailyMission) return '오늘의 미션';
  return isSolo ? '혼자 해보기' : '따라 해보기';
}

class PracticeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PracticeAppBar({
    required this.title,
    required this.onBack,
    this.step,
    this.totalSteps,
    this.stepName,
    this.modeLabel,
    this.actions,
    this.backgroundColor,
    super.key,
  });

  final String title;
  final VoidCallback onBack;
  final int? step;
  final int? totalSteps;
  final String? stepName;
  final String? modeLabel;
  final List<Widget>? actions;
  final Color? backgroundColor;

  bool get _showsProgress => step != null && totalSteps != null;
  @override
  Size get preferredSize => Size.fromHeight(
    68 + (_showsProgress ? 42 : (modeLabel == null ? 1 : 44)),
  );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AppBar(
      toolbarHeight: AppSizes.appBarHeight,
      automaticallyImplyLeading: false,
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 56,
      leading: IconButton(
        onPressed: onBack,
        tooltip: '이전 화면으로 돌아가기',
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        icon: const Icon(Icons.arrow_back),
      ),
      titleSpacing: 0,
      title: Text(
        title,
        maxLines: 2,
        softWrap: true,
        overflow: TextOverflow.fade,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(
          _showsProgress ? 42 : (modeLabel == null ? 1 : 44),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_showsProgress)
              PracticeProgressHeader(
                step: step!,
                totalSteps: totalSteps!,
                stepName: stepName,
                modeLabel: modeLabel,
              ),
            if (!_showsProgress && modeLabel != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.xs,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: PracticeModeBadge(label: modeLabel!),
                ),
              ),
            Divider(height: 1, color: colors.outlineVariant),
          ],
        ),
      ),
    );
  }
}

class PracticeProgressHeader extends StatelessWidget {
  const PracticeProgressHeader({
    required this.step,
    required this.totalSteps,
    this.stepName,
    this.modeLabel,
    super.key,
  });

  final int step;
  final int totalSteps;
  final String? stepName;
  final String? modeLabel;

  @override
  Widget build(BuildContext context) {
    final value = totalSteps <= 0 ? 0.0 : (step / totalSteps).clamp(0.0, 1.0);
    final stepLabel = stepName == null || stepName!.isEmpty
        ? '$step / $totalSteps 단계'
        : '$step / $totalSteps · $stepName';
    final semanticsLabel = modeLabel == null
        ? stepLabel
        : '$stepLabel, 연습 모드 $modeLabel';
    final compactMode =
        MediaQuery.sizeOf(context).width <= 360 ||
        MediaQuery.textScalerOf(context).scale(1) >= 1.3;
    return Semantics(
      label: semanticsLabel,
      value: '${(value * 100).round()}%',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    stepLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (modeLabel != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  PracticeModeBadge(label: modeLabel!, showLabel: !compactMode),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            LinearProgressIndicator(
              value: value,
              minHeight: 6,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
          ],
        ),
      ),
    );
  }
}

class PracticeModeBadge extends StatelessWidget {
  const PracticeModeBadge({
    required this.label,
    this.icon,
    this.showLabel = true,
    super.key,
  });

  final String label;
  final IconData? icon;
  final bool showLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '연습 모드: $label',
    excludeSemantics: true,
    child: Container(
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon ?? Icons.school_outlined, size: 20),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

enum PracticeNoticeTone { information, success, caution }

class PracticeInlineNotice extends StatelessWidget {
  const PracticeInlineNotice({
    required this.message,
    this.tone = PracticeNoticeTone.information,
    this.icon,
    super.key,
  });

  final String message;
  final PracticeNoticeTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (background, foreground, defaultIcon) = switch (tone) {
      PracticeNoticeTone.success => (
        colors.secondaryContainer,
        colors.onSecondaryContainer,
        Icons.check_circle_outline,
      ),
      PracticeNoticeTone.caution => (
        colors.tertiaryContainer,
        colors.onTertiaryContainer,
        Icons.info_outline,
      ),
      PracticeNoticeTone.information => (
        colors.secondaryContainer,
        colors.onSecondaryContainer,
        Icons.lightbulb_outline,
      ),
    };
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon ?? defaultIcon, size: 22, color: foreground),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                softWrap: true,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PracticeBottomActions extends StatelessWidget {
  const PracticeBottomActions({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: DefaultTextStyle.merge(textAlign: TextAlign.center, child: child),
    ),
  );
}

class PracticeCompletionHeader extends StatelessWidget {
  const PracticeCompletionHeader({
    required this.title,
    required this.description,
    this.modeLabel,
    super.key,
  });

  final String title;
  final String description;
  final String? modeLabel;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const HanGeoleumCharacter(mood: HanGeoleumMood.celebrate, size: 48),
      const SizedBox(height: AppSpacing.xs),
      Text(
        title,
        textAlign: TextAlign.center,
        softWrap: true,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: AppSpacing.xs),
      Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xs,
        children: [
          Text(
            description,
            textAlign: TextAlign.center,
            softWrap: true,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (modeLabel != null) PracticeModeBadge(label: modeLabel!),
        ],
      ),
    ],
  );
}

class PracticeRewardSummary extends StatelessWidget {
  const PracticeRewardSummary({required this.message, this.points, super.key});

  final String message;
  final int? points;

  @override
  Widget build(BuildContext context) => PracticeInlineNotice(
    tone: PracticeNoticeTone.success,
    icon: points == null ? Icons.replay_rounded : Icons.favorite_outline,
    message: points == null ? message : '$message +$points점',
  );
}
