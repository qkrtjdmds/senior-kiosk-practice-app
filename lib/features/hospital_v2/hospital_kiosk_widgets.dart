import 'package:flutter/material.dart';

import '../../shared/widgets/practice_ui.dart';
export '../../shared/widgets/practice_ui.dart';

const hospitalIvory = Color(0xFFFAF9F4);
const hospitalGreen = Color(0xFF23413C);
const hospitalSage = Color(0xFFE5EDE5);
const hospitalBlue = Color(0xFFE8F1F4);
const hospitalOrange = Color(0xFFF8E9DB);

class HospitalKioskScaffold extends StatelessWidget {
  const HospitalKioskScaffold({
    super.key,
    required this.child,
    required this.onBack,
    this.step,
    this.totalSteps,
    this.modeLabel,
    this.bottom,
  });

  final Widget child;
  final VoidCallback onBack;
  final int? step;
  final int? totalSteps;
  final String? modeLabel;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) onBack();
    },
    child: Scaffold(
      backgroundColor: hospitalIvory,
      appBar: PracticeAppBar(
        title: '병원 무인 접수',
        onBack: onBack,
        step: step,
        totalSteps: totalSteps,
        modeLabel: modeLabel,
        backgroundColor: hospitalIvory,
      ),
      body: SafeArea(child: child),
      bottomNavigationBar: bottom == null
          ? null
          : PracticeBottomActions(child: bottom!),
    ),
  );
}

class HospitalChoice extends StatelessWidget {
  const HospitalChoice({
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
  Widget build(BuildContext context) => Material(
    color: selected || emphasized ? hospitalSage : Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: selected || emphasized ? hospitalGreen : const Color(0xFFD9DDD5),
        width: selected || emphasized ? 2 : 1,
      ),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 72),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 30, color: hospitalGreen),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
              if (selected)
                const Icon(Icons.check_circle, color: hospitalGreen),
            ],
          ),
        ),
      ),
    ),
  );
}

class HospitalInlineNotice extends StatelessWidget {
  const HospitalInlineNotice(this.text, {super.key, this.urgent = false});
  final String text;
  final bool urgent;

  @override
  Widget build(BuildContext context) => PracticeInlineNotice(
    message: text,
    tone: urgent ? PracticeNoticeTone.caution : PracticeNoticeTone.information,
  );
}

class HospitalQuestion extends StatelessWidget {
  const HospitalQuestion({super.key, required this.title, this.description});
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

Widget hospitalPrimaryButton(
  BuildContext context,
  String label,
  VoidCallback? onPressed,
) => FilledButton(
  onPressed: onPressed,
  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(62)),
  child: Text(label, textAlign: TextAlign.center, softWrap: true),
);
