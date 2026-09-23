import 'package:flutter/material.dart';

import '../../../shared/widgets/large_action_button.dart';
import '../../../shared/widgets/page_scaffold.dart';

enum LearningChoiceVisualState { normal, guided, selected }

class LearningModeCard extends StatelessWidget {
  const LearningModeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onPressed,
    this.secondary = false,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onPressed;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = secondary
        ? colors.surfaceContainerLowest
        : colors.primary;
    final foreground = secondary ? colors.onSurface : colors.onPrimary;
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 112),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: secondary ? const Color(0xFF9FCBB4) : colors.primary,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: secondary
                      ? const Color(0xFFE4F3EA)
                      : colors.onPrimary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 34, color: foreground),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      softWrap: true,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: foreground),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      softWrap: true,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: foreground),
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

class LearningStepLayout extends StatelessWidget {
  const LearningStepLayout({
    required this.step,
    required this.guidance,
    required this.question,
    required this.onBack,
    required this.onPrevious,
    required this.onRestart,
    required this.child,
    this.title = '카페 주문 연습',
    this.phonePanel = false,
    this.customPanel = false,
    this.totalSteps = 4,
    this.onHint,
    this.onHome,
    this.guidanceDetail,
    this.questionInGuidance = false,
    this.calmKioskStyle = false,
    super.key,
  });

  final int step;
  final String guidance;
  final String question;
  final VoidCallback onBack;
  final VoidCallback onPrevious;
  final VoidCallback onRestart;
  final Widget child;
  final String title;
  final bool phonePanel;
  final bool customPanel;
  final int totalSteps;
  final VoidCallback? onHint;
  final VoidCallback? onHome;
  final String? guidanceDetail;
  final bool questionInGuidance;
  final bool calmKioskStyle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight:
            56 +
            (MediaQuery.textScalerOf(context).scale(1) - 1).clamp(0, 0.5) * 64,
        title: Text(
          title,
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.fade,
        ),
        leading: IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
          tooltip: '이전 화면으로 돌아가기',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProgressHeader(step: step, totalSteps: totalSteps),
                  const SizedBox(height: 22),
                  GuidanceCard(
                    message: questionInGuidance ? question : guidance,
                    detail: guidanceDetail,
                  ),
                  if (!questionInGuidance) ...[
                    const SizedBox(height: 24),
                    Text(
                      question,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                  const SizedBox(height: 24),
                  phonePanel
                      ? PhonePanel(child: child)
                      : customPanel
                      ? child
                      : KioskPanel(calmStyle: calmKioskStyle, child: child),
                  const SizedBox(height: 24),
                  if (onHint != null) ...[
                    _LearningFooterButton(
                      label: '힌트 보기',
                      icon: Icons.lightbulb_outline_rounded,
                      onPressed: onHint!,
                    ),
                    const SizedBox(height: 12),
                  ],
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final useColumn =
                          constraints.maxWidth < 500 ||
                          MediaQuery.textScalerOf(context).scale(1) > 1.15;
                      final previousButton = _LearningFooterButton(
                        label: '이전',
                        icon: Icons.chevron_left_rounded,
                        onPressed: onPrevious,
                      );
                      final restartButton = _LearningFooterButton(
                        label: '처음부터 다시 하기',
                        icon: Icons.refresh_rounded,
                        onPressed: onRestart,
                      );
                      if (useColumn) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            previousButton,
                            const SizedBox(height: 12),
                            restartButton,
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: previousButton),
                          const SizedBox(width: 12),
                          Expanded(child: restartButton),
                        ],
                      );
                    },
                  ),
                  if (onHome != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: onHome,
                      icon: const Icon(Icons.home_outlined),
                      label: const Text('홈으로 돌아가기'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(58),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LearningFooterButton extends StatelessWidget {
  const _LearningFooterButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(58),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Flexible(
            child: Text(label, textAlign: TextAlign.center, softWrap: true),
          ),
        ],
      ),
    );
  }
}

class ProgressHeader extends StatelessWidget {
  const ProgressHeader({required this.step, this.totalSteps = 4, super.key});

  final int step;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final useColumn =
                constraints.maxWidth < 420 ||
                MediaQuery.textScalerOf(context).scale(1) > 1.15;
            final prompt = Text(
              '천천히 한 단계씩',
              softWrap: true,
              style: Theme.of(context).textTheme.titleLarge,
            );
            final count = Text(
              '$step / $totalSteps 단계',
              softWrap: true,
              style: Theme.of(context).textTheme.titleLarge,
            );
            if (useColumn) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [prompt, const SizedBox(height: 6), count],
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [prompt, count],
            );
          },
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: step / totalSteps,
            minHeight: 14,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
      ],
    );
  }
}

class GuidanceCard extends StatelessWidget {
  const GuidanceCard({required this.message, this.detail, super.key});

  final String message;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.secondary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 30,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: Theme.of(context).textTheme.titleLarge),
                if (detail != null) ...[
                  const SizedBox(height: 8),
                  Text(detail!, style: Theme.of(context).textTheme.bodyLarge),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class KioskPanel extends StatelessWidget {
  const KioskPanel({required this.child, this.calmStyle = false, super.key});

  final Widget child;
  final bool calmStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: calmStyle
            ? Theme.of(context).colorScheme.surfaceContainerLowest
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(calmStyle ? 16 : 24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: calmStyle ? 1.5 : 2,
        ),
        boxShadow: calmStyle
            ? null
            : const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 16,
                  offset: Offset(0, 7),
                ),
              ],
      ),
      child: child,
    );
  }
}

class PhonePanel extends StatelessWidget {
  const PhonePanel({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 20),
      decoration: BoxDecoration(
        color: colorScheme.onSurface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: child,
      ),
    );
  }
}

class LearningChoiceCard extends StatelessWidget {
  const LearningChoiceCard({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.secondary = false,
    this.highlighted = false,
    this.calmStyle = false,
    this.visualState,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool secondary;
  final bool highlighted;
  final bool calmStyle;
  final LearningChoiceVisualState? visualState;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final state =
        visualState ??
        (highlighted
            ? LearningChoiceVisualState.guided
            : LearningChoiceVisualState.normal);
    final isEmphasized = state != LearningChoiceVisualState.normal;
    final isSelected = state == LearningChoiceVisualState.selected;
    final backgroundColor = calmStyle
        ? isEmphasized
              ? const Color(0xFFE4F3EA)
              : colorScheme.surfaceContainerLowest
        : isEmphasized
        ? colorScheme.primaryContainer
        : secondary
        ? colorScheme.surfaceContainerHighest
        : colorScheme.primaryContainer;
    final foregroundColor = isEmphasized
        ? colorScheme.onPrimaryContainer
        : secondary
        ? colorScheme.onSurface
        : colorScheme.onPrimaryContainer;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: const BoxConstraints(minHeight: 92),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isEmphasized
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              width: isEmphasized ? 2.5 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: calmStyle
                    ? BoxDecoration(
                        color: const Color(0xFFE4F3EA),
                        borderRadius: BorderRadius.circular(14),
                      )
                    : null,
                child: Icon(
                  isSelected ? Icons.check_rounded : icon,
                  size: 34,
                  color: foregroundColor,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: foregroundColor),
                    ),
                    if (state == LearningChoiceVisualState.guided) ...[
                      const SizedBox(height: 4),
                      Text(
                        '여기를 눌러보세요',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          color: foregroundColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!calmStyle)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 32,
                  color: foregroundColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class LearningCompletionLayout extends StatelessWidget {
  const LearningCompletionLayout({
    required this.title,
    required this.message,
    required this.reward,
    required this.onRestart,
    required this.onHome,
    this.badge,
    this.summary,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.pageTitle = '연습 완료',
    super.key,
  });

  final String title;
  final String message;
  final String reward;
  final VoidCallback onRestart;
  final VoidCallback onHome;
  final Widget? badge;
  final Widget? summary;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final String pageTitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return PageScaffold(
      title: pageTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
            decoration: BoxDecoration(
              color: const Color(0xFFE4F3EA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF9FCBB4)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 76,
                  color: colors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Text(
                    reward,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ),
          if (badge != null) ...[const SizedBox(height: 18), badge!],
          if (summary != null) ...[const SizedBox(height: 18), summary!],
          const SizedBox(height: 36),
          LargeActionButton(
            label: '처음부터 다시 하기',
            icon: Icons.refresh_rounded,
            onPressed: onRestart,
          ),
          if (secondaryActionLabel != null && onSecondaryAction != null) ...[
            const SizedBox(height: 16),
            LargeActionButton(
              label: secondaryActionLabel!,
              icon: Icons.swap_horiz_rounded,
              secondary: true,
              onPressed: onSecondaryAction!,
            ),
          ],
          const SizedBox(height: 16),
          LargeActionButton(
            label: '홈으로 돌아가기',
            icon: Icons.home_outlined,
            secondary: true,
            onPressed: onHome,
          ),
        ],
      ),
    );
  }
}

class OrderReceiptCard extends StatelessWidget {
  const OrderReceiptCard({
    required this.dineOption,
    required this.drink,
    required this.temperature,
    super.key,
  });

  final String dineOption;
  final String drink;
  final String temperature;

  @override
  Widget build(BuildContext context) {
    return LearningSummaryCard(
      title: '주문 연습 내역',
      items: [
        LearningSummaryItem(label: '주문 방식', value: dineOption),
        LearningSummaryItem(label: '음료', value: drink),
        LearningSummaryItem(label: '온도', value: temperature),
      ],
      footer: '연습용 주문이에요',
    );
  }
}

class LearningSummaryItem {
  const LearningSummaryItem({required this.label, required this.value});

  final String label;
  final String value;
}

class LearningSummaryCard extends StatelessWidget {
  const LearningSummaryCard({
    required this.title,
    required this.items,
    this.icon = Icons.receipt_long_outlined,
    this.footer,
    super.key,
  });

  final String title;
  final List<LearningSummaryItem> items;
  final IconData icon;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  softWrap: true,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          for (final item in items)
            _ReceiptRow(label: item.label, value: item.value),
          if (footer != null) ...[
            const Divider(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE4F3EA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                footer!,
                textAlign: TextAlign.center,
                softWrap: true,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useColumn =
              constraints.maxWidth < 360 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.15;
          final labelText = Text(
            label,
            softWrap: true,
            style: Theme.of(context).textTheme.bodyLarge,
          );
          final valueText = Text(
            value,
            softWrap: true,
            textAlign: useColumn ? TextAlign.start : TextAlign.end,
            style: Theme.of(context).textTheme.titleLarge,
          );
          if (useColumn) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [labelText, const SizedBox(height: 4), valueText],
            );
          }
          return Row(
            children: [
              Expanded(child: labelText),
              const SizedBox(width: 16),
              Flexible(child: valueText),
            ],
          );
        },
      ),
    );
  }
}
