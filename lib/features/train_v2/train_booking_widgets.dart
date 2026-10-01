import 'package:flutter/material.dart';

const trainIvory = Color(0xFFFAF9F4);
const trainGreen = Color(0xFF23413C);
const trainSage = Color(0xFFE5EDE5);
const trainBlue = Color(0xFFE7F0F4);
const trainLine = Color(0xFFD9DED8);

class TrainBookingScaffold extends StatelessWidget {
  const TrainBookingScaffold({
    super.key,
    required this.child,
    required this.onBack,
    this.step,
    this.total,
    this.summary,
    this.bottom,
  });
  final Widget child;
  final VoidCallback onBack;
  final int? step;
  final int? total;
  final String? summary;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) onBack();
    },
    child: Scaffold(
      backgroundColor: trainIvory,
      appBar: AppBar(
        leading: IconButton(
          tooltip: '이전 화면으로 돌아가기',
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('기차표 예매'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(
            step == null ? 1 : (summary?.isNotEmpty == true ? 62 : 36),
          ),
          child: Column(
            children: [
              if (step != null && total != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: step! / total!,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('$step / $total 단계'),
                    ],
                  ),
                ),
              if (summary?.isNotEmpty == true)
                Container(
                  width: double.infinity,
                  color: trainSage,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 7,
                  ),
                  child: Text(
                    summary!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
              const Divider(height: 1),
            ],
          ),
        ),
      ),
      body: SafeArea(child: child),
      bottomNavigationBar: bottom == null
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                child: bottom,
              ),
            ),
    ),
  );
}

class TrainQuestion extends StatelessWidget {
  const TrainQuestion(this.title, {super.key, this.description});
  final String title;
  final String? description;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        title,
        softWrap: true,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      if (description != null) ...[
        const SizedBox(height: 7),
        Text(
          description!,
          softWrap: true,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    ],
  );
}

class TrainChoiceTile extends StatelessWidget {
  const TrainChoiceTile({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.selected = false,
    this.enabled = true,
  });
  final String label;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;
  final bool enabled;
  @override
  Widget build(BuildContext context) => Material(
    color: selected
        ? trainSage
        : enabled
        ? Colors.white
        : const Color(0xFFF0F0ED),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: selected ? trainGreen : trainLine,
        width: selected ? 2 : 1,
      ),
    ),
    child: InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 72),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Icon(icon, color: enabled ? trainGreen : Colors.grey, size: 30),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      softWrap: true,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(subtitle!, softWrap: true),
                    ],
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle, color: trainGreen)
              else if (!enabled)
                const Icon(Icons.block, color: Colors.grey),
            ],
          ),
        ),
      ),
    ),
  );
}

class TrainSegmentOption<T> {
  const TrainSegmentOption({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

class TrainSegmentControl<T> extends StatelessWidget {
  const TrainSegmentControl({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<TrainSegmentOption<T>> options;
  final T? selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final textScale = MediaQuery.textScalerOf(context).scale(1);
      final useColumns = constraints.maxWidth < 330 || textScale > 1.25;
      final children = options
          .map(
            (option) => _TrainSegmentButton<T>(
              option: option,
              selected: option.value == selected,
              onPressed: () => onSelected(option.value),
            ),
          )
          .toList();
      if (useColumns && options.length <= 2) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              children[index],
              if (index != children.length - 1) const SizedBox(height: 8),
            ],
          ],
        );
      }
      if (useColumns) {
        final itemWidth = (constraints.maxWidth - 8) / 2;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      }
      return Row(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            Expanded(child: children[index]),
            if (index != children.length - 1) const SizedBox(width: 8),
          ],
        ],
      );
    },
  );
}

class _TrainSegmentButton<T> extends StatelessWidget {
  const _TrainSegmentButton({
    required this.option,
    required this.selected,
    required this.onPressed,
  });

  final TrainSegmentOption<T> option;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: OutlinedButton.icon(
      onPressed: onPressed,
      icon: option.icon == null ? const SizedBox.shrink() : Icon(option.icon),
      label: Text(option.label, textAlign: TextAlign.center, softWrap: true),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(58),
        foregroundColor: trainGreen,
        backgroundColor: selected ? trainSage : Colors.white,
        side: BorderSide(
          color: selected ? trainGreen : trainLine,
          width: selected ? 2 : 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}

class TrainInfoPanel extends StatelessWidget {
  const TrainInfoPanel({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding ?? const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: trainLine),
      borderRadius: BorderRadius.circular(10),
    ),
    child: child,
  );
}

class TrainInlineNotice extends StatelessWidget {
  const TrainInlineNotice(this.text, {super.key, this.warning = false});
  final String text;
  final bool warning;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: warning ? const Color(0xFFF8E9DB) : trainSage,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          warning ? Icons.info_outline : Icons.lightbulb_outline,
          color: trainGreen,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            softWrap: true,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    ),
  );
}

Widget trainPrimaryButton(
  BuildContext context,
  String label,
  VoidCallback? onPressed,
) => FilledButton(
  onPressed: onPressed,
  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(60)),
  child: Text(label, textAlign: TextAlign.center, softWrap: true),
);

String trainMoney(int value) {
  final raw = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    if (i > 0 && (raw.length - i) % 3 == 0) buffer.write(',');
    buffer.write(raw[i]);
  }
  return '$buffer원';
}
