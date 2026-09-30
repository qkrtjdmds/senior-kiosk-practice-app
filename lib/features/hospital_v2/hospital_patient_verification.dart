import 'package:flutter/material.dart';

import 'hospital_kiosk_widgets.dart';

class HospitalPatientVerification extends StatelessWidget {
  const HospitalPatientVerification({
    super.key,
    required this.inputLength,
    required this.onDigit,
    required this.onRemoveDigit,
    required this.onClear,
    required this.onVerify,
    required this.onHelp,
  });

  final int inputLength;
  final ValueChanged<String> onDigit;
  final VoidCallback onRemoveDigit;
  final VoidCallback onClear;
  final VoidCallback? onVerify;
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    final hideDeleteLabels = MediaQuery.textScalerOf(context).scale(16) >= 21;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HospitalQuestion(title: '화면에 적힌 연습용 생년월일 8자리를 입력해 보세요.'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: hospitalBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('연습 정보', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('1958년 4월 12일'),
              SizedBox(height: 4),
              Text('본인의 실제 정보는 입력하지 마세요.', softWrap: true),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Semantics(
          label: '8자리 중 $inputLength자리 입력됨',
          readOnly: true,
          child: ExcludeSemantics(child: _InputSlots(length: inputLength)),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisExtent: 72,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            for (final digit in ['1', '2', '3', '4', '5', '6', '7', '8', '9'])
              _NumberKey(digit: digit, onPressed: () => onDigit(digit)),
            _DeleteKey(
              icon: Icons.backspace_outlined,
              label: '한 글자',
              semanticLabel: '입력한 숫자 한 글자 지우기',
              hideLabel: hideDeleteLabels,
              onPressed: onRemoveDigit,
            ),
            _NumberKey(digit: '0', onPressed: () => onDigit('0')),
            _DeleteKey(
              icon: Icons.delete_outline,
              label: '전체',
              semanticLabel: '입력한 숫자 전체 지우기',
              hideLabel: hideDeleteLabels,
              onPressed: onClear,
            ),
          ],
        ),
        const SizedBox(height: 14),
        FilledButton(
          onPressed: onVerify,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(62)),
          child: const Text('환자 확인하기'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onHelp,
          icon: const Icon(Icons.support_agent_outlined),
          label: const Text('직원에게 도움 요청'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
          ),
        ),
      ],
    );
  }
}

class _InputSlots extends StatelessWidget {
  const _InputSlots({required this.length});
  final int length;

  @override
  Widget build(BuildContext context) => Row(
    children: List.generate(8, (index) {
      final filled = index < length;
      return Expanded(
        child: Container(
          height: 32,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? hospitalSage : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: filled ? hospitalGreen : const Color(0xFFC8CEC6),
            ),
          ),
          child: Text(filled ? '●' : '○'),
        ),
      );
    }),
  );
}

class _NumberKey extends StatelessWidget {
  const _NumberKey({required this.digit, required this.onPressed});
  final String digit;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: hospitalGreen,
      padding: EdgeInsets.zero,
    ),
    child: Text(digit, style: Theme.of(context).textTheme.titleLarge),
  );
}

class _DeleteKey extends StatelessWidget {
  const _DeleteKey({
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
          backgroundColor: hospitalSage,
          foregroundColor: hospitalGreen,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final style = Theme.of(context).textTheme.bodyMedium;
            final painter = TextPainter(
              text: TextSpan(text: label, style: style),
              maxLines: 1,
              textDirection: Directionality.of(context),
              textScaler: MediaQuery.textScalerOf(context),
            )..layout();
            final showLabel =
                !hideLabel &&
                painter.width <= constraints.maxWidth &&
                painter.height + 24 <= constraints.maxHeight;
            if (!showLabel) return Icon(icon, size: 26);
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22),
                const SizedBox(height: 2),
                Text(label, maxLines: 1, softWrap: false, style: style),
              ],
            );
          },
        ),
      ),
    ),
  );
}
