import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../learning/learning_progress_provider.dart';
import '../learning/widgets/learning_widgets.dart';
import 'hospital_mission.dart';

class HospitalStepFourPage extends StatelessWidget {
  const HospitalStepFourPage({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<LearningProgressProvider>();

    return LearningStepLayout(
      title: '병원 접수 연습',
      step: 4,
      guidance: progress.isHospitalSoloMode
          ? '접수 내용을 확인해보세요.'
          : '마지막으로 접수 내용을 확인해볼까요?',
      question: '접수 내용을 확인해볼까요?',
      onBack: () => context.go(AppRoutes.hospitalStepThree),
      onPrevious: () => context.go(AppRoutes.hospitalStepThree),
      onRestart: () {
        context.read<LearningProgressProvider>().resetHospitalLearning();
        context.go(AppRoutes.hospitalStepOne);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HospitalReceiptCard(progress: progress),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => _complete(context, progress),
            icon: const Icon(Icons.check_circle_outline_rounded, size: 30),
            label: const Text('접수 완료하기'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(78),
              textStyle: Theme.of(context).textTheme.labelLarge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _complete(BuildContext context, LearningProgressProvider progress) {
    final mission = HospitalMission.today;
    final complete =
        mission.isCorrect(
          HospitalMissionStep.purpose,
          progress.hospitalVisitPurpose ?? '',
        ) &&
        mission.isCorrect(
          HospitalMissionStep.registration,
          progress.hospitalRegistrationMethod ?? '',
        ) &&
        progress.hospitalDepartment == mission.department;

    if (progress.isHospitalSoloMode && !complete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('괜찮아요. 이전 단계에서 접수 내용을 다시 선택해볼 수 있어요.')),
      );
      return;
    }
    context.go(AppRoutes.hospitalComplete);
  }
}

class _HospitalReceiptCard extends StatelessWidget {
  const _HospitalReceiptCard({required this.progress});

  final LearningProgressProvider progress;

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
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 12),
              Text('접수 연습 내역', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const Divider(height: 28),
          _ReceiptRow(
            label: '방문 목적',
            value: progress.hospitalVisitPurpose ?? '선택하지 않았어요',
          ),
          _ReceiptRow(
            label: '접수 방법',
            value: progress.hospitalRegistrationMethod ?? '선택하지 않았어요',
          ),
          _ReceiptRow(
            label: '진료과 또는 도움',
            value: progress.hospitalDepartment ?? '선택하지 않았어요',
          ),
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
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}
