import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_theme.dart';
import '../../shared/widgets/han_geoleum_character.dart';
import '../learning/learning_progress_provider.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  bool _choosingTextSize = false;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<LearningProgressProvider>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: HanGeoleumCharacter(
                      mood: HanGeoleumMood.welcome,
                      size: 104,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '한걸음 디지털',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '천천히, 한 걸음씩 연습해요',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '실수해도 괜찮아요. 실제로 사용하기 전에 편하게 연습해 보세요.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (_choosingTextSize) ...[
                    const SizedBox(height: 24),
                    Text(
                      '글자 크기를 골라보세요',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    for (final size in AccessibilityTextSize.values) ...[
                      _TextSizeChoice(
                        size: size,
                        selected: settings.accessibilityTextSize == size,
                        onTap: () => settings.setAccessibilityTextSize(size),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: settings.completeOnboarding,
                    child: const Text('연습 시작하기', textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () =>
                        setState(() => _choosingTextSize = !_choosingTextSize),
                    icon: const Icon(Icons.format_size_rounded),
                    label: Text(
                      _choosingTextSize ? '글자 크기 선택 닫기' : '글자 크기 먼저 맞추기',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '이 앱은 실제 주문·예약·금융·행정 서비스와 연결되지 않는 연습용 앱이에요.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
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

class _TextSizeChoice extends StatelessWidget {
  const _TextSizeChoice({
    required this.size,
    required this.selected,
    required this.onTap,
  });
  final AccessibilityTextSize size;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = switch (size) {
      AccessibilityTextSize.normal => '보통',
      AccessibilityTextSize.large => '크게',
      AccessibilityTextSize.extraLarge => '아주 크게',
    };
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected
            ? Theme.of(context).colorScheme.secondaryContainer
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
                width: selected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Row(
              children: [
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '이 글씨 크기로 편하게 읽어보세요.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
