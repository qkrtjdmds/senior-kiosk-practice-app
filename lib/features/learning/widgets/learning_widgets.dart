import 'package:flutter/material.dart';

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
                  GuidanceCard(message: guidance),
                  const SizedBox(height: 24),
                  Text(
                    question,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  phonePanel
                      ? PhonePanel(child: child)
                      : customPanel
                      ? child
                      : KioskPanel(child: child),
                  if (onHint != null) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: onHint,
                        icon: const Icon(Icons.lightbulb_outline_rounded),
                        label: const Text('힌트 보기'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
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
  const GuidanceCard({required this.message, super.key});

  final String message;

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
            child: Text(message, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

class KioskPanel extends StatelessWidget {
  const KioskPanel({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 2,
        ),
        boxShadow: const [
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
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool secondary;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = highlighted
        ? colorScheme.primaryContainer
        : secondary
        ? colorScheme.surfaceContainerHighest
        : colorScheme.primaryContainer;
    final foregroundColor = highlighted
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
              color: highlighted
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              width: highlighted ? 2.5 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 38, color: foregroundColor),
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
                    if (highlighted) ...[
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
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text('주문 연습 내역', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const Divider(height: 28),
          _ReceiptRow(label: '매장/포장', value: dineOption),
          _ReceiptRow(label: '음료', value: drink),
          _ReceiptRow(label: '차가움/따뜻함', value: temperature),
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
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
