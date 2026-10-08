import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:han_geoleum_digital/app/app.dart';
import 'package:han_geoleum_digital/app/app_router.dart';
import 'package:han_geoleum_digital/app/app_routes.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';
import 'package:han_geoleum_digital/features/progress/recent_practice_record.dart';

void main() {
  Future<LearningProgressProvider> pumpProgress(
    WidgetTester tester, {
    Map<String, Object> values = const {},
    Size size = const Size(360, 760),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues(values);
    final progress = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    appRouter.go(AppRoutes.progress);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();
    return progress;
  }

  testWidgets('성장 요약과 콘텐츠별 완료 현황은 기존 Provider 값을 사용한다', (tester) async {
    await pumpProgress(tester, values: _sampleValues());

    expect(find.text('1234점'), findsOneWidget);
    expect(find.text('14회'), findsWidgets);
    expect(find.text('3개'), findsOneWidget);
    expect(find.byKey(const Key('content-progress-section')), findsOneWidget);
    for (final title in [
      '카페 주문',
      '햄버거 주문',
      '병원 무인접수',
      '기차표 예매',
      'ATM 출금',
      '무인민원발급기',
      '사진 보내기',
    ]) {
      expect(find.text(title), findsWidgets);
    }
    expect(find.textContaining('예약 확인 1회'), findsOneWidget);
    expect(
      find.bySemanticsLabel('성장 요약. 연습 포인트 1234점. 전체 연습 14회 완료. 배지 3개 획득.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('획득·미획득 배지와 최근 활동을 중복 없이 읽는다', (tester) async {
    await pumpProgress(tester, values: _sampleValues());

    expect(find.text('획득'), findsNWidgets(3));
    expect(find.text('아직 획득 전'), findsNWidgets(5));
    final earned = tester.getSemantics(
      find.bySemanticsLabel(RegExp('혼자 주문 첫걸음.*획득')),
    );
    expect(earned.label, contains('획득'));
    expect(earned.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
    expect(find.text('최신 연습'), findsOneWidget);
    expect(find.text('이전 연습'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('최신 연습')).dy,
      lessThan(tester.getTopLeft(find.text('이전 연습')).dy),
    );
    expect(find.text('혼자 해보기 · 연습 포인트 +20점'), findsOneWidget);
    expect(find.text('따라 해보기 · 연습 포인트 +10점'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('최신 연습.*혼자 해보기.*20점')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('기록이 없을 때 로컬 저장 안내와 시작 동작을 표시한다', (tester) async {
    await pumpProgress(tester);

    expect(find.text('이 기기에 저장된 연습 기록이에요.'), findsOneWidget);
    expect(
      find.text('로그인 없이 사용할 수 있어요. 앱을 삭제하거나 기기를 바꾸면 기록이 사라질 수 있어요.'),
      findsOneWidget,
    );
    expect(find.text('아직 완료한 연습이 없어요.'), findsOneWidget);
    expect(find.text('첫 연습을 완료하면 배지를 받을 수 있어요.'), findsOneWidget);
    expect(find.text('연습하러 가기'), findsOneWidget);
    expect(find.text('로그인'), findsNothing);

    final settings = find.text('화면 설정');
    await tester.ensureVisible(settings);
    await tester.tap(settings);
    await tester.pumpAndSettle();
    expect(appRouter.state.uri.path, AppRoutes.accessibilitySettings);
    expect(tester.takeException(), isNull);
  });

  testWidgets('320dp 아주 큰 글씨에서 설정과 기록 초기화가 안전하다', (tester) async {
    final progress = await pumpProgress(
      tester,
      size: const Size(320, 700),
      values: {
        ..._sampleValues(),
        'accessibility_text_size': 'extraLarge',
        'screen_contrast': 'vivid',
        'onboarding_completed_v1': true,
      },
    );

    expect(find.text('글씨 크기 아주 크게 · 선명한 화면'), findsOneWidget);
    final reset = find.byKey(const Key('progress-reset-button'));
    await tester.ensureVisible(reset);
    await tester.pumpAndSettle();
    final navigationTop = tester.getTopLeft(find.byType(NavigationBar)).dy;
    expect(tester.getBottomLeft(reset).dy, lessThanOrEqualTo(navigationTop));
    await tester.tap(reset);
    await tester.pumpAndSettle();
    expect(find.text('연습 기록을 초기화할까요?'), findsOneWidget);
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(progress.totalPoints, 1234);

    await tester.tap(reset);
    await tester.pumpAndSettle();
    await tester.tap(find.text('초기화하기'));
    await tester.pumpAndSettle();
    expect(progress.totalPoints, 0);
    expect(progress.recentPracticeRecords, isEmpty);
    expect(progress.accessibilityTextSize, AccessibilityTextSize.extraLarge);
    expect(progress.screenContrast, ScreenContrast.vivid);
    expect(progress.onboardingCompleted, isTrue);
    expect(find.text('0점'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Map<String, Object> _sampleValues() {
  final records = [
    RecentPracticeRecord(
      learningName: '최신 연습',
      modeName: '혼자 해보기',
      points: 20,
      completedAt: DateTime(2026, 10, 8, 10),
    ),
    RecentPracticeRecord(
      learningName: '이전 연습',
      modeName: '따라 해보기',
      points: 10,
      completedAt: DateTime(2026, 10, 7, 9),
    ),
  ];
  return {
    'digital_confidence_points': 1234,
    'cafe_guided_completion_count': 2,
    'cafe_solo_completion_count': 1,
    'cafe_solo_first_badge_earned': true,
    'cafe_familiar_badge_earned': true,
    'hospital_guided_completion_count': 1,
    'hospital_solo_completion_count': 1,
    'hospital_reservation_guided_completion_count': 1,
    'hospital_payment_guided_completion_count': 1,
    'hospital_document_guided_completion_count': 1,
    'hospital_solo_first_badge_earned': true,
    'photo_guided_completion_count': 1,
    'train_guided_completion_count': 1,
    'hamburger_guided_completion_count': 1,
    'atm_guided_completion_count': 1,
    'civil_document_guided_completion_count': 2,
    'recent_practice_records': records
        .map((record) => jsonEncode(record.toJson()))
        .toList(),
  };
}
