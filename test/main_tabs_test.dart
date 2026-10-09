import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:han_geoleum_digital/app/app.dart';
import 'package:han_geoleum_digital/app/app_router.dart';
import 'package:han_geoleum_digital/app/app_routes.dart';
import 'package:han_geoleum_digital/features/daily_mission/daily_mission_provider.dart';
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
    for (final label in ['홈', '연습하기', '미션', '내 정보']) {
      expect(find.text(label), findsOneWidget);
    }
    await tester.tap(find.text('연습하기'));
    await tester.pumpAndSettle();
    expect(appRouter.state.uri.path, AppRoutes.practice);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );
    await tester.tap(find.text('미션'));
    await tester.pumpAndSettle();
    expect(appRouter.state.uri.path, AppRoutes.missions);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      2,
    );
    expect(find.bySemanticsLabel('오늘도 한 걸음 해볼까요?'), findsOneWidget);
    expect(find.text('미션 보상 +10점'), findsNWidgets(3));
    await tester.tap(find.text('내 정보'));
    await tester.pumpAndSettle();
    expect(appRouter.state.uri.path, AppRoutes.progress);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      3,
    );
    await tester.tap(find.text('홈'));
    await tester.pumpAndSettle();
    expect(appRouter.state.uri.path, AppRoutes.home);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      0,
    );
  });

  testWidgets('연습하기에서 연 시작 화면은 시스템 뒤로가기로 목록에 복귀한다', (tester) async {
    await pumpApp(tester);
    for (final title in [
      '카페 주문',
      '햄버거 주문',
      '병원 무인접수',
      '기차표 예매',
      'ATM 출금',
      '무인민원발급기',
      '사진 보내기',
    ]) {
      appRouter.go(AppRoutes.practice);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(title));
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(appRouter.state.uri.path, AppRoutes.practice, reason: title);
    }
  });

  testWidgets('연습 목록 7개와 오늘의 미션이 기존 화면으로 이동한다', (tester) async {
    await pumpApp(tester);
    final practiceRoutes = <String, String>{
      '카페 주문': AppRoutes.cafeStart,
      '햄버거 주문': AppRoutes.hamburgerStart,
      '병원 무인접수': AppRoutes.hospitalStart,
      '기차표 예매': AppRoutes.trainStart,
      'ATM 출금': AppRoutes.atmStart,
      '무인민원발급기': AppRoutes.civilDocumentStart,
      '사진 보내기': AppRoutes.photoStart,
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
      await tester.tap(find.byTooltip('이전 화면으로 돌아가기'));
      await tester.pumpAndSettle();
      expect(appRouter.state.uri.path, AppRoutes.practice, reason: entry.key);
    }
    appRouter.go(AppRoutes.missions);
    await tester.pumpAndSettle();
    final action = find.text('연습 시작하기');
    expect(action, findsNWidgets(3));
    await tester.ensureVisible(action.first);
    await tester.tap(action.first);
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

  testWidgets('연습하기는 모드 차이와 보상을 한 번만 안내한다', (tester) async {
    await pumpApp(tester);
    appRouter.go(AppRoutes.practice);
    await tester.pumpAndSettle();

    expect(find.text('도움을 받으며 따라 하거나, 혼자 도전해 보세요.'), findsOneWidget);
    expect(find.text('따라 해보기'), findsOneWidget);
    expect(find.text('혼자 해보기'), findsOneWidget);
    expect(find.text('완료하면 연습 포인트 10점'), findsOneWidget);
    expect(find.text('완료하면 연습 포인트 20점'), findsOneWidget);
    expect(
      find.bySemanticsLabel('따라 해보기. 화면의 안내를 따라 한 단계씩 연습해요. 완료하면 연습 포인트 10점'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        '혼자 해보기. 목표를 보고 스스로 순서를 선택해요. 힌트도 볼 수 있어요. 완료하면 연습 포인트 20점',
      ),
      findsOneWidget,
    );
    final cafeRow = tester.getSemantics(
      find.bySemanticsLabel('카페 주문 음료를 골라 주문하는 순서를 연습해요.'),
    );
    expect(cafeRow.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
  });

  testWidgets('일반 연습 콘텐츠 선택은 활성 미션을 해제하고 모드를 선택한다', (tester) async {
    await pumpApp(tester);
    appRouter.go(AppRoutes.practice);
    await tester.pumpAndSettle();
    final context = tester.element(find.text('연습을 선택하세요'));
    final daily = context.read<DailyMissionProvider>();
    daily.startMission(daily.missions.first.definition.id);
    expect(daily.activeMissionId, isNotNull);

    await tester.tap(find.text('카페 주문'));
    await tester.pumpAndSettle();
    expect(daily.activeMissionId, isNull);
    await tester.tap(find.text('따라 해보기'));
    await tester.pumpAndSettle();
    expect(appRouter.state.uri.path, AppRoutes.cafeV2Menu);

    appRouter.go(AppRoutes.practice);
    await tester.pumpAndSettle();
    await tester.tap(find.text('카페 주문'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('혼자 해보기'));
    await tester.tap(find.text('혼자 해보기'));
    await tester.pumpAndSettle();
    expect(appRouter.state.uri.path, AppRoutes.cafeMission);
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
    appRouter.go(AppRoutes.practice);
    await tester.pumpAndSettle();
    final lastPractice = find.text('사진 보내기');
    await tester.scrollUntilVisible(
      lastPractice,
      280,
      scrollable: find.byType(Scrollable).first,
    );
    final navigationTop = tester.getTopLeft(find.byType(NavigationBar)).dy;
    expect(
      tester.getBottomLeft(lastPractice).dy,
      lessThanOrEqualTo(navigationTop),
    );
    expect(tester.takeException(), isNull);

    appRouter.go(AppRoutes.missions);
    await tester.pumpAndSettle();
    final actions = find.text('연습 시작하기');
    expect(actions, findsNWidgets(3));
    await tester.ensureVisible(actions.last);
    await tester.pumpAndSettle();
    final missionNavigationTop = tester
        .getTopLeft(find.byType(NavigationBar))
        .dy;
    final buttonBottom = tester.getBottomLeft(actions.last).dy;
    expect(buttonBottom, lessThanOrEqualTo(missionNavigationTop));
    expect(tester.takeException(), isNull);
  });
}
