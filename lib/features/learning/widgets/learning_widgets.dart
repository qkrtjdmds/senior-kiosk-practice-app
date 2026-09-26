import 'package:flutter/material.dart';

import '../../../shared/widgets/large_action_button.dart';
import '../../../shared/widgets/page_scaffold.dart';

const learningSageSurface = Color(0xFFEDF2EA);
const learningSageBorder = Color(0xFFBAC9B7);

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
        ? learningSageSurface
        : colors.surfaceContainerLowest;
    final foreground = colors.onSurface;
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
              color: secondary ? learningSageBorder : colors.primary,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: learningSageSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 34, color: colors.primary),
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
    this.panelLabel,
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
  final String? panelLabel;

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
                  if (panelLabel == null) ...[
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
                  ],
                  phonePanel
                      ? PhonePanel(child: child)
                      : customPanel
                      ? child
                      : KioskPanel(
                          calmStyle: calmKioskStyle,
                          label: panelLabel,
                          question: panelLabel == null ? null : question,
                          detail: panelLabel == null ? null : guidanceDetail,
                          child: child,
                        ),
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
            backgroundColor: learningSageSurface,
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
        color: learningSageSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: learningSageBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 30,
            color: Theme.of(context).colorScheme.primary,
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
  const KioskPanel({
    required this.child,
    this.calmStyle = false,
    this.label,
    this.question,
    this.detail,
    super.key,
  });

  final Widget child;
  final bool calmStyle;
  final String? label;
  final String? question;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(label == null ? 20 : 16),
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
      child: label == null
          ? child
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  label!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  question!,
                  softWrap: true,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (detail != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    detail!,
                    softWrap: true,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
                const Divider(height: 30, color: learningSageBorder),
                child,
              ],
            ),
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
    this.insideKioskPanel = false,
    this.visualState,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool secondary;
  final bool highlighted;
  final bool calmStyle;
  final bool insideKioskPanel;
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
              ? learningSageSurface
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
      borderRadius: BorderRadius.circular(insideKioskPanel ? 14 : 18),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(insideKioskPanel ? 14 : 18),
        child: Container(
          constraints: BoxConstraints(minHeight: insideKioskPanel ? 88 : 92),
          padding: EdgeInsets.symmetric(
            horizontal: insideKioskPanel ? 14 : 20,
            vertical: insideKioskPanel ? 14 : 16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(insideKioskPanel ? 14 : 18),
            border: Border.all(
              color: isEmphasized
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              width: insideKioskPanel
                  ? isEmphasized
                        ? 1.5
                        : 1
                  : isEmphasized
                  ? 2.5
                  : 1.5,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final vertical =
                  insideKioskPanel &&
                  (constraints.maxWidth < 300 ||
                      MediaQuery.textScalerOf(context).scale(1) > 1.15);
              final iconBox = Container(
                width: insideKioskPanel ? 44 : 54,
                height: insideKioskPanel ? 44 : 54,
                decoration: calmStyle
                    ? BoxDecoration(
                        color: learningSageSurface,
                        borderRadius: BorderRadius.circular(14),
                      )
                    : null,
                child: Icon(
                  isSelected ? Icons.check_rounded : icon,
                  size: insideKioskPanel ? 28 : 34,
                  color: foregroundColor,
                ),
              );
              final text = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    softWrap: true,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: foregroundColor,
                      fontSize: insideKioskPanel ? 20 : null,
                    ),
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
              );
              if (vertical) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [iconBox, const SizedBox(height: 10), text],
                );
              }
              return Row(
                children: [
                  iconBox,
                  SizedBox(width: insideKioskPanel ? 12 : 18),
                  Expanded(child: text),
                  if (!calmStyle)
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 32,
                      color: foregroundColor,
                    ),
                ],
              );
            },
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
    this.restartLabel = '처음부터 다시 하기',
    this.homeLabel = '홈으로 돌아가기',
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
  final String restartLabel;
  final String homeLabel;

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
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: learningSageBorder),
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
                    color: learningSageSurface,
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
            label: restartLabel,
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
            label: homeLabel,
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
                color: learningSageSurface,
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
