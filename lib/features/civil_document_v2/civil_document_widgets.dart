import 'package:flutter/material.dart';

import '../../shared/widgets/practice_ui.dart';
export '../../shared/widgets/practice_ui.dart';

const civilIvory = Color(0xFFFAF9F4);
const civilNavy = Color(0xFF24364B);
const civilSage = Color(0xFFE5EDE5);
const civilBeige = Color(0xFFF4EBDD);
const civilBorder = Color(0xFFD5DAD4);

class CivilKioskScaffold extends StatelessWidget {
  const CivilKioskScaffold({
    super.key,
    required this.child,
    required this.onBack,
    this.step,
    this.totalSteps = 11,
    this.modeLabel,
    this.bottom,
  });
  final Widget child;
  final VoidCallback onBack;
  final int? step;
  final int totalSteps;
  final String? modeLabel;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) onBack();
    },
    child: Scaffold(
      backgroundColor: civilIvory,
      appBar: PracticeAppBar(
        title: '무인민원발급기 연습',
        onBack: onBack,
        step: step,
        totalSteps: step == null ? null : totalSteps,
        modeLabel: modeLabel,
        backgroundColor: civilIvory,
      ),
      body: SafeArea(child: child),
      bottomNavigationBar: bottom == null
          ? null
          : PracticeBottomActions(child: bottom!),
    ),
  );
}

class CivilQuestion extends StatelessWidget {
  const CivilQuestion(this.title, {super.key, this.description});
  final String title;
  final String? description;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.headlineSmall),
      if (description != null) ...[
        const SizedBox(height: 8),
        Text(description!, style: Theme.of(context).textTheme.bodyLarge),
      ],
    ],
  );
}

class CivilNotice extends StatelessWidget {
  const CivilNotice(this.text, {super.key, this.warning = false});
  final String text;
  final bool warning;
  @override
  Widget build(BuildContext context) => PracticeInlineNotice(
    message: text,
    tone: warning ? PracticeNoticeTone.caution : PracticeNoticeTone.information,
  );
}

class CivilChoiceRow extends StatelessWidget {
  const CivilChoiceRow({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.selected = false,
    this.emphasized = false,
  });
  final String label;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;
  final bool emphasized;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected || emphasized ? civilSage : Colors.white,
          border: Border.all(
            color: selected || emphasized ? civilNavy : civilBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: civilNavy, size: 30),
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
                    const SizedBox(height: 4),
                    Text(subtitle!, softWrap: true),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: civilNavy),
          ],
        ),
      ),
    ),
  );
}

Widget civilPrimaryButton(String label, VoidCallback? onPressed) =>
    FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: civilNavy,
        foregroundColor: Colors.white,
        disabledBackgroundColor: civilBorder,
        minimumSize: const Size.fromHeight(58),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      child: Text(label, textAlign: TextAlign.center, softWrap: true),
    );

class CivilSummary extends StatelessWidget {
  const CivilSummary({super.key, required this.rows, this.title = '연습용 신청 내용'});
  final String title;
  final List<(String, String)> rows;
  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    padding: const EdgeInsets.all(18),
    child: Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const Divider(height: 26),
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(row.$1)),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    row.$2,
                    textAlign: TextAlign.right,
                    softWrap: true,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
