import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_routes.dart';
import '../../shared/widgets/large_action_button.dart';
import '../../shared/widgets/page_scaffold.dart';

class CivilDocumentMissionPage extends StatelessWidget {
  const CivilDocumentMissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PageScaffold(
      title: '혼자 해보기',
      backRoute: AppRoutes.civilDocumentStart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '오늘의 서류 발급 미션',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
            decoration: BoxDecoration(
              color: colors.secondaryContainer,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colors.secondary.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 76,
                  color: colors.secondary,
                ),
                const SizedBox(height: 18),
                const _MissionRow(label: '필요한 서류', value: '주민등록등본'),
                const SizedBox(height: 12),
                const _MissionRow(label: '표시 내용', value: '기본 내용'),
                const SizedBox(height: 12),
                const _MissionRow(label: '발급 부수', value: '한 부'),
                const SizedBox(height: 14),
                Text(
                  '힌트가 필요하면 언제든지 확인할 수 있어요.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          LargeActionButton(
            label: '혼자 발급해보기',
            icon: Icons.play_arrow_rounded,
            onPressed: () => context.go(AppRoutes.civilDocumentPractice),
          ),
          const SizedBox(height: 16),
          LargeActionButton(
            label: '홈으로 돌아가기',
            icon: Icons.home_outlined,
            secondary: true,
            onPressed: () => context.go(AppRoutes.home),
          ),
        ],
      ),
    );
  }
}

class _MissionRow extends StatelessWidget {
  const _MissionRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    );
  }
}
