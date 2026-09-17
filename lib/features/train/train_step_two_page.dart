import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../learning/learning_progress_provider.dart';
import '../learning/widgets/learning_widgets.dart';
import 'train_order_mission.dart';

class TrainStepTwoPage extends StatelessWidget {
  const TrainStepTwoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isSolo = context.watch<LearningProgressProvider>().isTrainSoloMode;

    return LearningStepLayout(
      title: '기차표 예매 연습',
      step: 2,
      totalSteps: 5,
      guidance: isSolo ? '도착역을 선택해보세요.' : '이제 도착하는 곳을 골라볼까요?',
      question: '어디로 가시나요?',
      onBack: () => context.go(AppRoutes.trainStepOne),
      onPrevious: () => context.go(AppRoutes.trainStepOne),
      onRestart: () {
        context.read<LearningProgressProvider>().resetTrainLearning();
        context.go(AppRoutes.trainStepOne);
      },
      onHint: isSolo ? () => showTrainMissionHint(context) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DestinationChoice(
            label: '서울역',
            highlighted: !isSolo,
            onPressed: () => _select(context, '서울역'),
          ),
          const SizedBox(height: 16),
          _DestinationChoice(
            label: '천안아산역',
            highlighted: !isSolo,
            onPressed: () => _select(context, '천안아산역'),
          ),
          const SizedBox(height: 16),
          _DestinationChoice(
            label: '부산역',
            highlighted: !isSolo,
            onPressed: () => _select(context, '부산역'),
          ),
        ],
      ),
    );
  }

  void _select(BuildContext context, String station) {
    final progress = context.read<LearningProgressProvider>();
    if (progress.isTrainSoloMode &&
        !TrainOrderMission.today.isCorrect(TrainMissionStep.arrival, station)) {
      _showMissionReminder(context);
      return;
    }
    if (progress.trainDepartureStation == station) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('출발역과 다른 도착역을 골라볼까요?'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    progress.selectTrainArrivalStation(station);
    context.go(AppRoutes.trainStepThree);
  }

  void _showMissionReminder(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            '괜찮아요. 오늘의 예매 내용을 다시 확인해볼까요?\n'
            '힌트 보기를 누르면 예매 내용을 확인할 수 있어요.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _DestinationChoice extends StatelessWidget {
  const _DestinationChoice({
    required this.label,
    required this.onPressed,
    this.highlighted = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return LearningChoiceCard(
      label: label,
      icon: Icons.flag_outlined,
      highlighted: highlighted,
      secondary: true,
      onPressed: onPressed,
    );
  }
}
