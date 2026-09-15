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
    super.key,
  });

  final int step;
  final String guidance;
  final String question;
  final VoidCallback onBack;
  final VoidCallback onPrevious;
  final VoidCallback onRestart;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('카페 주문 연습'),
        leading: IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: '이전 화면',
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
                  ProgressHeader(step: step),
                  const SizedBox(height: 22),
                  GuidanceCard(message: guidance),
                  const SizedBox(height: 24),
                  Text(
                    question,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  KioskPanel(child: child),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onPrevious,
                          icon: const Icon(Icons.chevron_left_rounded),
                          label: const Text('이전'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(58),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onRestart,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('처음부터 다시 하기'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(58),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProgressHeader extends StatelessWidget {
  const ProgressHeader({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('천천히 한 단계씩', style: Theme.of(context).textTheme.titleLarge),
            Text('$step / 4 단계', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: step / 4,
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

class LearningChoiceCard extends StatelessWidget {
  const LearningChoiceCard({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.secondary = false,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = secondary
        ? colorScheme.surfaceContainerHighest
        : colorScheme.primaryContainer;
    final foregroundColor = secondary
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
            border: Border.all(color: colorScheme.outlineVariant, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, size: 38, color: foregroundColor),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: foregroundColor),
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
