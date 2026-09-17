import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../learning/learning_progress_provider.dart';
import '../learning/widgets/learning_widgets.dart';
import 'train_order_mission.dart';

class TrainStepFourPage extends StatelessWidget {
  const TrainStepFourPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isSolo = context.watch<LearningProgressProvider>().isTrainSoloMode;

    return LearningStepLayout(
      title: '기차표 예매 연습',
      step: 4,
      totalSteps: 5,
      guidance: isSolo ? '좌석을 선택해보세요.' : '편한 자리를 골라볼까요?',
      question: '어느 자리에 앉고 싶으세요?',
      onBack: () => context.go(AppRoutes.trainStepThree),
      onPrevious: () => context.go(AppRoutes.trainStepThree),
      onRestart: () {
        context.read<LearningProgressProvider>().resetTrainLearning();
        context.go(AppRoutes.trainStepOne);
      },
      onHint: isSolo ? () => showTrainMissionHint(context) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LearningChoiceCard(
            label: '창가 자리',
            icon: Icons.window_outlined,
            secondary: true,
            highlighted: !isSolo,
            onPressed: () => _select(context, '창가 자리'),
          ),
          const SizedBox(height: 16),
          LearningChoiceCard(
            label: '통로 자리',
            icon: Icons.airline_seat_recline_normal_outlined,
            secondary: true,
            highlighted: !isSolo,
            onPressed: () => _select(context, '통로 자리'),
          ),
        ],
      ),
    );
  }

  void _select(BuildContext context, String seat) {
    final progress = context.read<LearningProgressProvider>();
    if (progress.isTrainSoloMode &&
        !TrainOrderMission.today.isCorrect(TrainMissionStep.seat, seat)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '괜찮아요. 오늘의 예매 내용을 다시 확인해볼까요?\n힌트 보기를 누르면 예매 내용을 확인할 수 있어요.',
          ),
        ),
      );
      return;
    }
    progress.selectTrainSeat(seat);
    context.go(AppRoutes.trainStepFive);
  }
}
