import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../shared/widgets/large_action_button.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../learning/learning_progress_provider.dart';

class HospitalMissionPage extends StatelessWidget {
  const HospitalMissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: '혼자 해보기',
      backRoute: AppRoutes.hospitalStart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '오늘의 병원 접수 미션',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.assignment_ind_outlined,
                  size: 76,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(height: 18),
                Text(
                  '진료 접수 · 다시 방문',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 14),
                Text(
                  '무릎이나 허리가 불편해요',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                Text(
                  '접수 내용을 기억하고 직접 선택해보세요.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          LargeActionButton(
            label: '혼자 접수해보기',
            icon: Icons.play_arrow_rounded,
            onPressed: () => context.go(AppRoutes.hospitalStepOne),
          ),
          const SizedBox(height: 16),
          LargeActionButton(
            label: '병원 접수 연습으로 돌아가기',
            icon: Icons.arrow_back_rounded,
            secondary: true,
            onPressed: () {
              context.read<LearningProgressProvider>().resetHospitalLearning();
              context.go(AppRoutes.hospitalStart);
            },
          ),
        ],
      ),
    );
  }
}
