import 'package:flutter/material.dart';

import '../../app/app_routes.dart';

enum MissionContentType {
  cafe,
  hamburger,
  hospital,
  train,
  atm,
  civilDocument,
  photo,
}

class MissionDefinition {
  const MissionDefinition({
    required this.id,
    required this.contentType,
    required this.title,
    required this.description,
    required this.conditionId,
    required this.route,
    required this.icon,
  });
  final String id;
  final MissionContentType contentType;
  final String title;
  final String description;
  final String conditionId;
  final String route;
  final IconData icon;
}

class DailyMission {
  const DailyMission({
    required this.definition,
    required this.dateKey,
    required this.isCompleted,
    required this.isRewarded,
    this.completedAt,
  });
  final MissionDefinition definition;
  final String dateKey;
  final bool isCompleted;
  final bool isRewarded;
  final DateTime? completedAt;
  int get rewardPoints => 10;
}

abstract final class DailyMissionCatalog {
  static const definitions = <MissionDefinition>[
    MissionDefinition(
      id: 'cafe_solo_complete',
      contentType: MissionContentType.cafe,
      title: '카페 주문 완성하기',
      description: '가상 키오스크에서 혼자 주문을 끝까지 연습해요.',
      conditionId: 'solo_complete',
      route: AppRoutes.cafeMission,
      icon: Icons.local_cafe_outlined,
    ),
    MissionDefinition(
      id: 'hamburger_solo_complete',
      contentType: MissionContentType.hamburger,
      title: '햄버거 주문 완성하기',
      description: '오늘의 햄버거 주문 미션을 혼자 완성해요.',
      conditionId: 'solo_complete',
      route: AppRoutes.hamburgerMission,
      icon: Icons.lunch_dining_outlined,
    ),
    MissionDefinition(
      id: 'hospital_solo_complete',
      contentType: MissionContentType.hospital,
      title: '병원 접수 완성하기',
      description: '오늘의 병원 접수 순서를 혼자 연습해요.',
      conditionId: 'solo_complete',
      route: AppRoutes.hospitalMission,
      icon: Icons.local_hospital_outlined,
    ),
    MissionDefinition(
      id: 'train_solo_complete',
      contentType: MissionContentType.train,
      title: '기차표 예매 완성하기',
      description: '오늘의 기차표 예매 미션을 혼자 완성해요.',
      conditionId: 'solo_complete',
      route: AppRoutes.trainMission,
      icon: Icons.train_outlined,
    ),
    MissionDefinition(
      id: 'atm_solo_complete',
      contentType: MissionContentType.atm,
      title: 'ATM 출금 완성하기',
      description: '5만 원을 찾는 연습 순서를 혼자 완성해요.',
      conditionId: 'solo_complete',
      route: AppRoutes.atmMission,
      icon: Icons.account_balance_outlined,
    ),
    MissionDefinition(
      id: 'civil_document_solo_complete',
      contentType: MissionContentType.civilDocument,
      title: '서류 발급 완성하기',
      description: '주민등록등본 한 부 발급 연습을 완성해요.',
      conditionId: 'solo_complete',
      route: AppRoutes.civilDocumentMission,
      icon: Icons.description_outlined,
    ),
    MissionDefinition(
      id: 'photo_solo_complete',
      contentType: MissionContentType.photo,
      title: '사진 보내기 완성하기',
      description: '오늘의 사진 보내기 미션을 혼자 완성해요.',
      conditionId: 'solo_complete',
      route: AppRoutes.photoMission,
      icon: Icons.photo_outlined,
    ),
  ];

  static MissionDefinition? byId(String id) {
    for (final definition in definitions) {
      if (definition.id == id) return definition;
    }
    return null;
  }
}
