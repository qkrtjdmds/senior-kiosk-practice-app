import 'package:flutter/material.dart';

enum CivilDocumentV2Mode { guided, solo }

enum CivilDocumentV2Step {
  categories,
  documents,
  availability,
  identity,
  fingerprint,
  options,
  copies,
  review,
  payment,
  printing,
  collection,
}

enum CivilDocumentCategory {
  resident,
  family,
  land,
  tax,
  health,
  education,
  other,
}

enum CivilPaymentMethod { card, cash }

class CivilPracticeDocument {
  const CivilPracticeDocument({
    required this.name,
    required this.category,
    required this.use,
    required this.fee,
    this.requiresIdentity = true,
  });

  final String name;
  final CivilDocumentCategory category;
  final String use;
  final int fee;
  final bool requiresIdentity;
}

const civilPracticeDocuments = <CivilPracticeDocument>[
  CivilPracticeDocument(
    name: '주민등록표 등본',
    category: CivilDocumentCategory.resident,
    use: '세대와 주소 정보를 확인할 때',
    fee: 200,
  ),
  CivilPracticeDocument(
    name: '주민등록표 초본',
    category: CivilDocumentCategory.resident,
    use: '개인의 주소 변동 내용을 확인할 때',
    fee: 200,
  ),
  CivilPracticeDocument(
    name: '가족관계증명서',
    category: CivilDocumentCategory.family,
    use: '가족관계를 확인할 때',
    fee: 500,
  ),
  CivilPracticeDocument(
    name: '기본증명서',
    category: CivilDocumentCategory.family,
    use: '본인의 기본 등록 사항을 확인할 때',
    fee: 500,
  ),
  CivilPracticeDocument(
    name: '건축물대장',
    category: CivilDocumentCategory.land,
    use: '건축물 등록 정보를 확인할 때',
    fee: 500,
  ),
  CivilPracticeDocument(
    name: '지방세 세목별 과세증명',
    category: CivilDocumentCategory.tax,
    use: '지방세 과세 내역을 확인할 때',
    fee: 800,
  ),
];

class CivilDocumentScenario {
  const CivilDocumentScenario({
    required this.title,
    required this.documentName,
    required this.options,
    required this.copies,
    required this.payment,
  });
  final String title;
  final String documentName;
  final Map<String, String> options;
  final int copies;
  final CivilPaymentMethod payment;
}

const guidedCivilScenario = CivilDocumentScenario(
  title: '주민등록표 등본 1부 발급',
  documentName: '주민등록표 등본',
  options: {
    '주소 변동 사항': '포함 안 함',
    '세대 구성 사유': '포함 안 함',
    '주민등록번호 뒷자리': '표시 안 함',
    '세대원 정보': '전체',
    '발급 형태': '필요한 내용만',
  },
  copies: 1,
  payment: CivilPaymentMethod.card,
);

const soloCivilScenarios = <CivilDocumentScenario>[
  CivilDocumentScenario(
    title: '등본 1부 카드 발급',
    documentName: '주민등록표 등본',
    options: {'주민등록번호 뒷자리': '표시 안 함'},
    copies: 1,
    payment: CivilPaymentMethod.card,
  ),
  CivilDocumentScenario(
    title: '초본 2부 현금 발급',
    documentName: '주민등록표 초본',
    options: {'주소 변동 사항': '포함', '주민등록번호 뒷자리': '표시 안 함'},
    copies: 2,
    payment: CivilPaymentMethod.cash,
  ),
  CivilDocumentScenario(
    title: '가족관계증명서 1부 발급',
    documentName: '가족관계증명서',
    options: {'증명 유형': '일반', '주민등록번호 뒷자리': '표시 안 함'},
    copies: 1,
    payment: CivilPaymentMethod.card,
  ),
];

String formatCivilWon(int value) =>
    '${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}원';

IconData civilCategoryIcon(CivilDocumentCategory value) => switch (value) {
  CivilDocumentCategory.resident => Icons.badge_outlined,
  CivilDocumentCategory.family => Icons.family_restroom_outlined,
  CivilDocumentCategory.land => Icons.apartment_outlined,
  CivilDocumentCategory.tax => Icons.receipt_long_outlined,
  CivilDocumentCategory.health => Icons.health_and_safety_outlined,
  CivilDocumentCategory.education => Icons.school_outlined,
  CivilDocumentCategory.other => Icons.description_outlined,
};
