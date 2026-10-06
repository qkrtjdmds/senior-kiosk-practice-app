import 'package:flutter/material.dart';

import '../../shared/widgets/practice_ui.dart';
export '../../shared/widgets/practice_ui.dart';

const atmIvory = Color(0xFFFAF9F4);
const atmNavy = Color(0xFF24364B);
const atmSage = Color(0xFFE4ECE5);
const atmNotice = Color(0xFFF5E8D8);
const atmBorder = Color(0xFFD5DAD4);

class AtmKioskScaffold extends StatelessWidget {
  const AtmKioskScaffold({
    super.key,
    required this.child,
    required this.onBack,
    this.step,
    this.totalSteps = 10,
    this.bottom,
    this.summary,
    this.modeLabel,
  });

  final Widget child;
  final VoidCallback onBack;
  final int? step;
  final int totalSteps;
  final Widget? bottom;
  final String? summary;
  final String? modeLabel;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) onBack();
    },
    child: Scaffold(
      backgroundColor: atmIvory,
      appBar: PracticeAppBar(
        title: 'ATM 출금 연습',
        onBack: onBack,
        step: step,
        totalSteps: step == null ? null : totalSteps,
        modeLabel: modeLabel,
        backgroundColor: atmIvory,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (summary?.isNotEmpty ?? false)
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 34),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 7,
                ),
                color: atmSage,
                child: Text(
                  summary!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Expanded(child: child),
          ],
        ),
      ),
      bottomNavigationBar: bottom == null
          ? null
          : PracticeBottomActions(child: bottom!),
    ),
  );
}

class AtmQuestion extends StatelessWidget {
  const AtmQuestion({super.key, required this.title, this.description});
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
        const SizedBox(height: 8),
        Text(
          description!,
          softWrap: true,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    ],
  );
}

class AtmInlineNotice extends StatelessWidget {
  const AtmInlineNotice(this.text, {super.key, this.warning = false});
  final String text;
  final bool warning;

  @override
  Widget build(BuildContext context) => PracticeInlineNotice(
    message: text,
    tone: warning ? PracticeNoticeTone.caution : PracticeNoticeTone.information,
  );
}

class AtmChoiceRow extends StatelessWidget {
  const AtmChoiceRow({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.selected = false,
    this.emphasized = false,
    this.enabled = true,
  });

  final String label;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;
  final bool emphasized;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    enabled: enabled,
    child: Material(
      color: selected || emphasized ? atmSage : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selected || emphasized ? atmNavy : atmBorder,
          width: selected || emphasized ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 30, color: enabled ? atmNavy : Colors.grey),
                const SizedBox(width: 14),
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
                if (selected) const Icon(Icons.check_circle, color: atmNavy),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class AtmAmountGrid extends StatelessWidget {
  const AtmAmountGrid({
    super.key,
    required this.onSelect,
    required this.target,
    required this.guided,
  });
  final ValueChanged<int> onSelect;
  final int target;
  final bool guided;

  @override
  Widget build(BuildContext context) {
    const amounts = [10000, 30000, 50000, 100000, 200000];
    return LayoutBuilder(
      builder: (context, constraints) {
        final oneColumn =
            constraints.maxWidth < 300 ||
            MediaQuery.textScalerOf(context).scale(18) > 25;
        final width = oneColumn
            ? constraints.maxWidth
            : (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final amount in amounts)
              SizedBox(
                width: width,
                child: OutlinedButton(
                  onPressed: () => onSelect(amount),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(62),
                    backgroundColor: guided && amount == target
                        ? atmSage
                        : Colors.white,
                    side: BorderSide(
                      color: guided && amount == target ? atmNavy : atmBorder,
                    ),
                  ),
                  child: Text(_format(amount), textAlign: TextAlign.center),
                ),
              ),
          ],
        );
      },
    );
  }

  static String _format(int value) =>
      value >= 10000 ? '${value ~/ 10000}만 원' : '$value원';
}

class AtmPinPad extends StatelessWidget {
  const AtmPinPad({
    super.key,
    required this.length,
    required this.onDigit,
    required this.onRemove,
    required this.onClear,
  });
  final int length;
  final ValueChanged<String> onDigit;
  final VoidCallback onRemove;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hideLabels = MediaQuery.textScalerOf(context).scale(16) >= 21;
    return Column(
      children: [
        Semantics(
          label: '4자리 중 $length자리 입력됨',
          readOnly: true,
          child: ExcludeSemantics(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (index) => Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    index < length ? '●' : '○',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisExtent: 66,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            for (final digit in ['1', '2', '3', '4', '5', '6', '7', '8', '9'])
              OutlinedButton(
                onPressed: () => onDigit(digit),
                child: Text(digit),
              ),
            _DeleteButton(
              icon: Icons.backspace_outlined,
              label: '한 글자',
              semanticLabel: '입력한 숫자 한 글자 지우기',
              hideLabel: hideLabels,
              onPressed: onRemove,
            ),
            OutlinedButton(
              onPressed: () => onDigit('0'),
              child: const Text('0'),
            ),
            _DeleteButton(
              icon: Icons.delete_outline,
              label: '전체',
              semanticLabel: '입력한 숫자 전체 지우기',
              hideLabel: hideLabels,
              onPressed: onClear,
            ),
          ],
        ),
      ],
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({
    required this.icon,
    required this.label,
    required this.semanticLabel,
    required this.hideLabel,
    required this.onPressed,
  });
  final IconData icon;
  final String label;
  final String semanticLabel;
  final bool hideLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticLabel,
    child: ExcludeSemantics(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: atmSage,
          padding: const EdgeInsets.all(4),
          minimumSize: const Size(56, 56),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final style = Theme.of(context).textTheme.bodySmall;
            final painter = TextPainter(
              text: TextSpan(text: label, style: style),
              maxLines: 1,
              textDirection: Directionality.of(context),
              textScaler: MediaQuery.textScalerOf(context),
            )..layout();
            final show =
                !hideLabel &&
                painter.width <= constraints.maxWidth &&
                painter.height + 26 <= constraints.maxHeight;
            if (!show) return Icon(icon, size: 25);
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 21),
                const SizedBox(height: 1),
                Text(label, maxLines: 1, softWrap: false, style: style),
              ],
            );
          },
        ),
      ),
    ),
  );
}

Widget atmPrimaryButton(String label, VoidCallback? onPressed) => FilledButton(
  onPressed: onPressed,
  style: FilledButton.styleFrom(
    backgroundColor: atmNavy,
    minimumSize: const Size.fromHeight(60),
  ),
  child: Text(label, textAlign: TextAlign.center, softWrap: true),
);
