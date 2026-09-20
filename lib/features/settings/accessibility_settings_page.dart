import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../shared/widgets/large_action_button.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../learning/learning_progress_provider.dart';

class AccessibilitySettingsPage extends StatelessWidget {
  const AccessibilitySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<LearningProgressProvider>();

    return PageScaffold(
      title: '화면 설정',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('화면 설정', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(
            '읽기 편한 글씨 크기와 화면 모양을 골라보세요.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 30),
          _SettingsSection(
            title: '글씨 크기',
            icon: Icons.format_size_rounded,
            children: [
              _SettingChoiceCard(
                title: '보통',
                description: '기본 글씨 크기예요.',
                selected:
                    settings.accessibilityTextSize ==
                    AccessibilityTextSize.normal,
                onPressed: () => settings.setAccessibilityTextSize(
                  AccessibilityTextSize.normal,
                ),
              ),
              _SettingChoiceCard(
                title: '크게',
                description: '글씨를 더 크게 보여줘요.',
                selected:
                    settings.accessibilityTextSize ==
                    AccessibilityTextSize.large,
                onPressed: () => settings.setAccessibilityTextSize(
                  AccessibilityTextSize.large,
                ),
              ),
              _SettingChoiceCard(
                title: '아주 크게',
                description: '글씨를 가장 크게 보여줘요.',
                selected:
                    settings.accessibilityTextSize ==
                    AccessibilityTextSize.extraLarge,
                onPressed: () => settings.setAccessibilityTextSize(
                  AccessibilityTextSize.extraLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          _SettingsSection(
            title: '화면 대비',
            icon: Icons.contrast_rounded,
            children: [
              _SettingChoiceCard(
                title: '편안한 화면',
                description: '밝고 부드러운 기본 화면이에요.',
                selected: settings.screenContrast == ScreenContrast.comfortable,
                onPressed: () =>
                    settings.setScreenContrast(ScreenContrast.comfortable),
              ),
              _SettingChoiceCard(
                title: '선명한 화면',
                description: '글자와 버튼을 더 뚜렷하게 보여줘요.',
                selected: settings.screenContrast == ScreenContrast.vivid,
                onPressed: () =>
                    settings.setScreenContrast(ScreenContrast.vivid),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.save_outlined, size: 32),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    '설정한 내용은 앱을 다시 열어도 그대로 유지돼요.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Divider(height: 1),
          const SizedBox(height: 30),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.history_toggle_off_rounded,
                size: 34,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '연습 기록 관리',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '포인트와 연습 기록을 처음 상태로 되돌릴 수 있어요.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: () => _confirmPracticeReset(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: 0.75),
                width: 2,
              ),
              minimumSize: const Size.fromHeight(72),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            child: const Text(
              '연습 기록 초기화',
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ),
          const SizedBox(height: 30),
          LargeActionButton(
            label: '홈으로 돌아가기',
            icon: Icons.home_outlined,
            onPressed: () => context.go(AppRoutes.home),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmPracticeReset(BuildContext context) async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        title: const Text('연습 기록을 초기화할까요?', softWrap: true),
        content: const Text(
          '모은 포인트, 완료 횟수, 배지, 최근 연습 기록이 처음 상태로 돌아가요.',
          softWrap: true,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                ),
                child: const Text('취소', textAlign: TextAlign.center),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                  backgroundColor: Theme.of(
                    dialogContext,
                  ).colorScheme.errorContainer,
                  foregroundColor: Theme.of(
                    dialogContext,
                  ).colorScheme.onErrorContainer,
                ),
                child: const Text(
                  '초기화하기',
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (shouldReset != true || !context.mounted) return;

    await context.read<LearningProgressProvider>().resetPracticeRecords();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('연습 기록을 처음 상태로 되돌렸어요.')));
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 34, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
          ],
        ),
        const SizedBox(height: 14),
        for (var index = 0; index < children.length; index++) ...[
          children[index],
          if (index != children.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _SettingChoiceCard extends StatelessWidget {
  const _SettingChoiceCard({
    required this.title,
    required this.description,
    required this.selected,
    required this.onPressed,
  });

  final String title;
  final String description;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: '$title, $description',
      child: Material(
        color: selected ? colors.primaryContainer : colors.surface,
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
                color: selected ? colors.primary : colors.outlineVariant,
                width: selected ? 3 : 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  size: 38,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        description,
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
