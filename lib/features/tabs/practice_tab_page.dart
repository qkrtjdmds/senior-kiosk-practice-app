import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_routes.dart';
import '../../shared/widgets/page_scaffold.dart';
import 'tab_learning_card.dart';

class PracticeTabPage extends StatelessWidget {
  const PracticeTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: '연습',
      showBackButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '원하는 생활 연습을 골라보세요.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          _card(
            context,
            title: '카페 키오스크 연습',
            description: '음료를 주문하는 순서를 연습해요.',
            icon: Icons.local_cafe_outlined,
            route: AppRoutes.cafeStart,
          ),
          _card(
            context,
            title: '햄버거 주문 연습',
            description: '메뉴와 세트를 고르는 방법을 연습해요.',
            icon: Icons.lunch_dining_outlined,
            route: AppRoutes.hamburgerStart,
          ),
          _card(
            context,
            title: '병원 접수 연습',
            description: '병원에서 접수하는 순서를 연습해요.',
            icon: Icons.local_hospital_outlined,
            route: AppRoutes.hospitalStart,
          ),
          _card(
            context,
            title: '사진 보내기 연습',
            description: '사진을 골라 보내는 방법을 연습해요.',
            icon: Icons.photo_outlined,
            route: AppRoutes.photoStart,
          ),
          _card(
            context,
            title: '기차표 예매 연습',
            description: '기차표를 예매하는 순서를 연습해요.',
            icon: Icons.train_outlined,
            route: AppRoutes.trainStart,
          ),
          _card(
            context,
            title: 'ATM 출금 연습',
            description: 'ATM에서 돈을 찾는 순서를 연습해요.',
            icon: Icons.account_balance_outlined,
            route: AppRoutes.atmStart,
          ),
          TabLearningCard(
            title: '무인민원발급기 연습',
            description: '필요한 서류를 고르는 방법을 연습해요.',
            icon: Icons.description_outlined,
            onPressed: () => context.go(AppRoutes.civilDocumentStart),
          ),
        ],
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required String route,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TabLearningCard(
        title: title,
        description: description,
        icon: icon,
        onPressed: () => context.go(route),
      ),
    );
  }
}
