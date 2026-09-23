import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../learning/learning_progress_provider.dart';
import 'tab_learning_card.dart';

class MissionTabPage extends StatelessWidget {
  const MissionTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<LearningProgressProvider>();
    return PageScaffold(
      title: '오늘의 미션',
      showBackButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '혼자 해보는 연습에 도전해보세요.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          _missionCard(
            title: '카페 혼자 해보기',
            icon: Icons.local_cafe_outlined,
            earned: progress.soloFirstBadgeEarned,
            onPressed: () {
              progress.selectMode(CafeLearningMode.solo);
              context.go(AppRoutes.cafeMission);
            },
          ),
          _missionCard(
            title: '병원 접수 혼자 해보기',
            icon: Icons.local_hospital_outlined,
            earned: progress.hospitalSoloFirstBadgeEarned,
            onPressed: () {
              progress.selectHospitalMode(HospitalLearningMode.solo);
              context.go(AppRoutes.hospitalMission);
            },
          ),
          _missionCard(
            title: '사진 보내기 혼자 해보기',
            icon: Icons.photo_outlined,
            earned: progress.photoSoloFirstBadgeEarned,
            onPressed: () {
              progress.selectPhotoMode(PhotoLearningMode.solo);
              context.go(AppRoutes.photoMission);
            },
          ),
          _missionCard(
            title: '기차표 예매 혼자 해보기',
            icon: Icons.train_outlined,
            earned: progress.trainSoloFirstBadgeEarned,
            onPressed: () {
              progress.selectTrainMode(TrainLearningMode.solo);
              context.go(AppRoutes.trainMission);
            },
          ),
          _missionCard(
            title: '햄버거 주문 혼자 해보기',
            icon: Icons.lunch_dining_outlined,
            earned: progress.hamburgerSoloFirstBadgeEarned,
            onPressed: () async {
              await progress.startHamburgerSoloMission();
              if (context.mounted) context.go(AppRoutes.hamburgerMission);
            },
          ),
          _missionCard(
            title: 'ATM 출금 혼자 해보기',
            icon: Icons.account_balance_outlined,
            earned: progress.atmSoloFirstBadgeEarned,
            onPressed: () async {
              await progress.startAtmLearning(AtmLearningMode.solo);
              if (context.mounted) context.go(AppRoutes.atmMission);
            },
          ),
          _missionCard(
            title: '서류 발급 혼자 해보기',
            icon: Icons.description_outlined,
            earned: progress.civilDocumentSoloFirstBadgeEarned,
            onPressed: () async {
              await progress.startCivilDocumentLearning(
                CivilDocumentLearningMode.solo,
              );
              if (context.mounted) {
                context.go(AppRoutes.civilDocumentMission);
              }
            },
            last: true,
          ),
        ],
      ),
    );
  }

  Widget _missionCard({
    required String title,
    required IconData icon,
    required bool earned,
    required VoidCallback onPressed,
    bool last = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 14),
      child: TabLearningCard(
        title: title,
        description: '완료하면 20점을 받아요',
        status: earned ? '첫걸음 배지를 받았어요' : null,
        icon: icon,
        onPressed: onPressed,
      ),
    );
  }
}
