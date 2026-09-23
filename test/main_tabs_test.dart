import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:han_geoleum_digital/app/app.dart';
import 'package:han_geoleum_digital/app/app_router.dart';
import 'package:han_geoleum_digital/app/app_routes.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';

void main() {
  Future<LearningProgressProvider> pumpApp(
    WidgetTester tester, {
    Map<String, Object> values = const {},
  }) async {
    SharedPreferences.setMockInitialValues(values);
    final progress = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    appRouter.go(AppRoutes.home);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();
    return progress;
  }

  testWidgets('4개 하단 탭이 정상적으로 이동한다', (tester) async {
    await pumpApp(tester);

    expect(find.text('홈'), findsOneWidget);
    expect(find.text('연습'), findsOneWidget);
    expect(find.text('미션'), findsOneWidget);
    expect(find.text('내 정보'), findsOneWidget);

    await tester.tap(find.text('연습'));
    await tester.pumpAndSettle();
    expect(appRouter.state.uri.path, AppRoutes.practice);
    expect(find.text('원하는 생활 연습을 골라보세요.'), findsOneWidget);

    await tester.tap(find.text('미션'));
    await tester.pumpAndSettle();
    expect(appRouter.state.uri.path, AppRoutes.missions);
    expect(find.text('혼자 해보는 연습에 도전해보세요.'), findsOneWidget);

    await tester.tap(find.text('내 정보'));
    await tester.pumpAndSettle();
    expect(appRouter.state.uri.path, AppRoutes.progress);
    expect(find.text('화면 설정'), findsOneWidget);
    expect(find.text('연습 기록 관리'), findsOneWidget);

    await tester.tap(find.text('홈'));
    await tester.pumpAndSettle();
    expect(appRouter.state.uri.path, AppRoutes.home);
  });

  testWidgets('연습과 미션 카드 7개가 기존 시작 및 미션 화면으로 이동한다', (tester) async {
    final progress = await pumpApp(tester);

    final practiceRoutes = <String, String>{
      '카페 키오스크 연습': AppRoutes.cafeStart,
      '햄버거 주문 연습': AppRoutes.hamburgerStart,
      '병원 접수 연습': AppRoutes.hospitalStart,
      '사진 보내기 연습': AppRoutes.photoStart,
      '기차표 예매 연습': AppRoutes.trainStart,
      'ATM 출금 연습': AppRoutes.atmStart,
      '무인민원발급기 연습': AppRoutes.civilDocumentStart,
    };
    for (final entry in practiceRoutes.entries) {
      appRouter.go(AppRoutes.practice);
      await tester.pumpAndSettle();
      final card = find.text(entry.key);
      await tester.ensureVisible(card);
      await tester.tap(card);
      await tester.pumpAndSettle();
      expect(appRouter.state.uri.path, entry.value, reason: entry.key);
      expect(find.byType(NavigationBar), findsNothing, reason: entry.key);
    }

    final missionRoutes = <String, String>{
      '카페 혼자 해보기': AppRoutes.cafeMission,
      '병원 접수 혼자 해보기': AppRoutes.hospitalMission,
      '사진 보내기 혼자 해보기': AppRoutes.photoMission,
      '기차표 예매 혼자 해보기': AppRoutes.trainMission,
      '햄버거 주문 혼자 해보기': AppRoutes.hamburgerMission,
      'ATM 출금 혼자 해보기': AppRoutes.atmMission,
      '서류 발급 혼자 해보기': AppRoutes.civilDocumentMission,
    };
    for (final entry in missionRoutes.entries) {
      appRouter.go(AppRoutes.missions);
      await tester.pumpAndSettle();
      final card = find.text(entry.key);
      await tester.ensureVisible(card);
      await tester.tap(card);
      await tester.pumpAndSettle();
      expect(appRouter.state.uri.path, entry.value, reason: entry.key);
      expect(find.byType(NavigationBar), findsNothing, reason: entry.key);
    }
    expect(progress.isCivilDocumentSoloMode, isTrue);
  });

  testWidgets('획득한 첫걸음 배지를 미션 탭에 표시한다', (tester) async {
    await pumpApp(tester, values: {'cafe_solo_first_badge_earned': true});
    appRouter.go(AppRoutes.missions);
    await tester.pumpAndSettle();

    expect(find.text('첫걸음 배지를 받았어요'), findsOneWidget);
    expect(find.text('완료하면 20점을 받아요'), findsNWidgets(7));
  });

  testWidgets('320dp 아주 큰 글씨에서 탭과 본문이 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpApp(
      tester,
      values: {
        'accessibility_text_size': 'extraLarge',
        'screen_contrast': 'vivid',
      },
    );

    for (final route in [
      AppRoutes.home,
      AppRoutes.practice,
      AppRoutes.missions,
      AppRoutes.progress,
    ]) {
      appRouter.go(route);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: route);
      expect(find.text('홈'), findsWidgets, reason: route);
      expect(find.text('연습'), findsWidgets, reason: route);
      expect(find.text('미션'), findsWidgets, reason: route);
      expect(find.text('내 정보'), findsWidgets, reason: route);
    }
  });
}
