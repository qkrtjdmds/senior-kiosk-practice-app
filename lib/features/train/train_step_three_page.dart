import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../learning/learning_progress_provider.dart';
import '../learning/widgets/learning_widgets.dart';
import 'train_order_mission.dart';

class TrainStepThreePage extends StatelessWidget {
  const TrainStepThreePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isSolo = context.watch<LearningProgressProvider>().isTrainSoloMode;

    return LearningStepLayout(
      title: '기차표 예매 연습',
      step: 3,
      totalSteps: 5,
      guidance: isSolo ? '출발 시간을 선택해보세요.' : '기차를 탈 시간을 골라볼까요?',
      question: '언제 출발할까요?',
      onBack: () => context.go(AppRoutes.trainStepTwo),
      onPrevious: () => context.go(AppRoutes.trainStepTwo),
      onRestart: () {
        context.read<LearningProgressProvider>().resetTrainLearning();
        context.go(AppRoutes.trainStepOne);
      },
      onHint: isSolo ? () => showTrainMissionHint(context) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LearningChoiceCard(
            label: '오늘 오전',
            icon: Icons.wb_sunny_outlined,
            secondary: true,
            highlighted: !isSolo,
            onPressed: () => _select(context, '오늘 오전'),
          ),
          const SizedBox(height: 16),
          LearningChoiceCard(
            label: '오늘 오후',
            icon: Icons.wb_twilight_outlined,
            secondary: true,
            highlighted: !isSolo,
            onPressed: () => _select(context, '오늘 오후'),
          ),
          const SizedBox(height: 16),
          LearningChoiceCard(
            label: '내일 오전',
            icon: Icons.calendar_today_outlined,
            secondary: true,
            highlighted: !isSolo,
            onPressed: () => _select(context, '내일 오전'),
          ),
        ],
      ),
    );
  }

  void _select(BuildContext context, String time) {
    final progress = context.read<LearningProgressProvider>();
    if (progress.isTrainSoloMode &&
        !TrainOrderMission.today.isCorrect(TrainMissionStep.time, time)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '괜찮아요. 오늘의 예매 내용을 다시 확인해볼까요?\n힌트 보기를 누르면 예매 내용을 확인할 수 있어요.',
          ),
        ),
      );
      return;
    }
    progress.selectTrainDepartureTime(time);
    context.go(AppRoutes.trainStepFour);
  }
}
