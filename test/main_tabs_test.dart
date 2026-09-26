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
    for (final label in ['홈', '연습', '미션', '내 정보']) {
      expect(find.text(label), findsOneWidget);
    }
    await tester.tap(find.text('연습'));
    await tester.pumpAndSettle();
    expect(appRouter.state.uri.path, AppRoutes.practice);
    await tester.tap(find.text('미션'));
    await tester.pumpAndSettle();
    expect(appRouter.state.uri.path, AppRoutes.missions);
    expect(find.text('오늘 준비된 세 가지 연습에 도전해 보세요.'), findsOneWidget);
    expect(find.text('완료하면 추가 포인트 10점'), findsNWidgets(3));
    await tester.tap(find.text('내 정보'));
    await tester.pumpAndSettle();
    expect(appRouter.state.uri.path, AppRoutes.progress);
    await tester.tap(find.text('홈'));
    await tester.pumpAndSettle();
    expect(appRouter.state.uri.path, AppRoutes.home);
  });

  testWidgets('연습 카드 7개와 오늘의 미션 카드가 기존 화면으로 이동한다', (tester) async {
    await pumpApp(tester);
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
      expect(find.byType(NavigationBar), findsNothing);
    }
    appRouter.go(AppRoutes.missions);
    await tester.pumpAndSettle();
    final reward = find.text('완료하면 추가 포인트 10점');
    expect(reward, findsNWidgets(3));
    await tester.ensureVisible(reward.first);
    await tester.tap(reward.first);
    await tester.pumpAndSettle();
    expect(<String>[
      AppRoutes.cafeMission,
      AppRoutes.hamburgerMission,
      AppRoutes.hospitalMission,
      AppRoutes.trainMission,
      AppRoutes.atmMission,
      AppRoutes.civilDocumentMission,
      AppRoutes.photoMission,
    ], contains(appRouter.state.uri.path));
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('320dp 아주 큰 글씨에서 탭과 오늘의 미션이 넘치지 않는다', (tester) async {
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
      expect(find.text('홈'), findsWidgets);
      expect(find.text('미션'), findsWidgets);
    }
    appRouter.go(AppRoutes.missions);
    await tester.pumpAndSettle();
    expect(find.text('완료하면 추가 포인트 10점'), findsNWidgets(3));
  });
}
