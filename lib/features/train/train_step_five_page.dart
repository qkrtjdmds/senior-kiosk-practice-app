import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../learning/learning_progress_provider.dart';
import '../learning/widgets/learning_widgets.dart';
import 'train_order_mission.dart';

class TrainStepFivePage extends StatelessWidget {
  const TrainStepFivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<LearningProgressProvider>();

    return LearningStepLayout(
      title: '기차표 예매 연습',
      step: 5,
      totalSteps: 5,
      guidance: '마지막으로 예매 내용을 확인해볼까요?',
      question: '예매 내용을 확인해볼까요?',
      onBack: () => context.go(AppRoutes.trainStepFour),
      onPrevious: () => context.go(AppRoutes.trainStepFour),
      onRestart: () {
        context.read<LearningProgressProvider>().resetTrainLearning();
        context.go(AppRoutes.trainStepOne);
      },
      child: _TicketCard(progress: progress),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.progress});

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
                Icons.confirmation_number_outlined,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text('연습용 승차권', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const Divider(height: 28),
          _TicketRow(label: '출발역', value: progress.trainDepartureStation),
          _TicketRow(label: '도착역', value: progress.trainArrivalStation),
          _TicketRow(label: '출발 시간', value: progress.trainDepartureTime),
          _TicketRow(label: '좌석', value: progress.trainSeat),
          const SizedBox(height: 6),
          Text(
            '실제 예매가 아닌 연습용 화면이에요.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () {
              final mission = TrainOrderMission.today;
              final complete =
                  mission.isCorrect(
                    TrainMissionStep.departure,
                    progress.trainDepartureStation ?? '',
                  ) &&
                  mission.isCorrect(
                    TrainMissionStep.arrival,
                    progress.trainArrivalStation ?? '',
                  ) &&
                  mission.isCorrect(
                    TrainMissionStep.time,
                    progress.trainDepartureTime ?? '',
                  ) &&
                  mission.isCorrect(
                    TrainMissionStep.seat,
                    progress.trainSeat ?? '',
                  );

              if (progress.isTrainSoloMode && !complete) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('괜찮아요. 이전 단계에서 예매 내용을 다시 선택해볼 수 있어요.'),
                  ),
                );
                return;
              }
              context.go(AppRoutes.trainComplete);
            },
            icon: const Icon(Icons.check_circle_outline_rounded, size: 30),
            label: const Text('예매 완료하기'),
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
}

class _TicketRow extends StatelessWidget {
  const _TicketRow({required this.label, required this.value});

  final String label;
  final String? value;

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
              value ?? '선택하지 않았어요',
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}
