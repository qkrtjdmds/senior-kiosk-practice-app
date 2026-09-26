import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:han_geoleum_digital/features/daily_mission/daily_mission.dart';
import 'package:han_geoleum_digital/features/daily_mission/daily_mission_provider.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';
import 'package:han_geoleum_digital/features/tabs/mission_tab_page.dart';

void main() {
  Future<(LearningProgressProvider, DailyMissionProvider)> createProviders({
    required DateTime Function() clock,
    Map<String, Object> values = const {},
  }) async {
    SharedPreferences.setMockInitialValues(values);
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);
    final daily = DailyMissionProvider(
      preferences,
      progress,
      clock: clock,
      random: Random(7),
    );
    return (progress, daily);
  }

  test('첫 실행에 서로 다른 콘텐츠의 미션 3개를 만들고 같은 날 복원한다', () async {
    final now = DateTime.utc(2026, 9, 25, 3);
    final (progress, daily) = await createProviders(clock: () => now);
    expect(daily.missions, hasLength(3));
    expect(
      daily.missions.map((item) => item.definition.id).toSet(),
      hasLength(3),
    );
    expect(
      daily.missions.map((item) => item.definition.contentType).toSet(),
      hasLength(3),
    );
    final ids = daily.missions.map((item) => item.definition.id).toList();
    final restored = DailyMissionProvider(
      progress.preferences,
      progress,
      clock: () => now.add(const Duration(hours: 8)),
      random: Random(99),
    );
    expect(restored.missions.map((item) => item.definition.id), ids);
    daily.dispose();
    restored.dispose();
  });

  test('하루 세 미션의 추가 보상은 최대 30점이고 새 일반 연습은 세션을 해제한다', () async {
    final now = DateTime.utc(2026, 9, 25, 3);
    final (progress, daily) = await createProviders(clock: () => now);
    for (final mission in daily.missions) {
      daily.startMission(mission.definition.id);
      await daily.completeActiveMission(mission.definition.contentType);
    }
    expect(progress.totalPoints, 30);
    expect(daily.completedCount, 3);
    daily.startMission(daily.missions.first.definition.id);
    progress.selectHospitalMode(HospitalLearningMode.solo);
    expect(daily.activeMissionId, isNull);
    expect(
      await daily.completeActiveMission(MissionContentType.hospital),
      isFalse,
    );
    expect(progress.totalPoints, 30);
    daily.dispose();
  });

  test('한국 날짜가 바뀌면 전날과 완전히 같은 조합을 피한다', () async {
    var now = DateTime.utc(2026, 9, 25, 14, 59);
    final (_, daily) = await createProviders(clock: () => now);
    final first = daily.missions.map((item) => item.definition.id).toSet();
    now = DateTime.utc(2026, 9, 25, 15, 1);
    final next = daily.missions.map((item) => item.definition.id).toSet();
    expect(next, isNot(first));
    daily.dispose();
  });

  test('완료 상태와 10점 보상은 저장되고 같은 미션에 중복 지급되지 않는다', () async {
    final now = DateTime.utc(2026, 9, 25, 3);
    final (progress, daily) = await createProviders(clock: () => now);
    final mission = daily.missions.first;
    daily.startMission(mission.definition.id);
    expect(
      await daily.completeActiveMission(mission.definition.contentType),
      isTrue,
    );
    expect(progress.totalPoints, 10);
    daily.startMission(mission.definition.id);
    expect(
      await daily.completeActiveMission(mission.definition.contentType),
      isFalse,
    );
    expect(progress.totalPoints, 10);

    final restored = DailyMissionProvider(
      progress.preferences,
      progress,
      clock: () => now,
    );
    expect(restored.completedCount, 1);
    expect(
      restored.missions
          .firstWhere((item) => item.definition.id == mission.definition.id)
          .isRewarded,
      isTrue,
    );
    daily.dispose();
    restored.dispose();
  });

  test('빠른 연속 완료 요청에도 추가 보상을 한 번만 지급한다', () async {
    final now = DateTime.utc(2026, 9, 25, 3);
    final (progress, daily) = await createProviders(clock: () => now);
    final mission = daily.missions.first;
    daily.startMission(mission.definition.id);
    final results = await Future.wait([
      daily.completeActiveMission(mission.definition.contentType),
      daily.completeActiveMission(mission.definition.contentType),
    ]);
    expect(results.where((result) => result), hasLength(1));
    expect(progress.totalPoints, 10);
    expect(daily.completedCount, 1);
    daily.dispose();
  });

  test('UTC 날짜가 바뀌어도 한국 날짜가 같으면 미션을 유지한다', () async {
    var now = DateTime.utc(2026, 9, 25, 23, 50);
    final (_, daily) = await createProviders(clock: () => now);
    final ids = daily.missions.map((item) => item.definition.id).toList();
    now = DateTime.utc(2026, 9, 26, 0, 10);
    expect(daily.missions.map((item) => item.definition.id), ids);
    expect(daily.todayKey, '2026-09-26');
    daily.dispose();
  });

  test('일반 학습 보상과 미션 보상을 합치고 미완료 이탈은 보상하지 않는다', () async {
    final now = DateTime.utc(2026, 9, 25, 3);
    final (progress, daily) = await createProviders(clock: () => now);
    expect(await daily.completeActiveMission(MissionContentType.cafe), isFalse);
    expect(progress.totalPoints, 0);

    final cafe = daily.missions
        .where((item) => item.definition.contentType == MissionContentType.cafe)
        .firstOrNull;
    if (cafe != null) {
      progress.selectMode(CafeLearningMode.solo);
      await progress.completeCafeLearning();
      daily.startMission(cafe.definition.id);
      await daily.completeActiveMission(MissionContentType.cafe);
      expect(progress.totalPoints, 30);
    }
    daily.dispose();
  });

  test('손상된 오늘 데이터는 안전하게 다시 만들고 기록 초기화는 설정을 보존한다', () async {
    final now = DateTime.utc(2026, 9, 25, 3);
    final (progress, daily) = await createProviders(
      clock: () => now,
      values: {
        DailyMissionProvider.dateKey: '2026-09-25',
        DailyMissionProvider.selectedIdsKey: <String>['unknown'],
        'accessibility_text_size': 'extraLarge',
        'screen_contrast': 'vivid',
      },
    );
    expect(daily.missions, hasLength(3));
    await progress.resetPracticeRecords();
    expect(daily.completedCount, 0);
    expect(progress.totalPoints, 0);
    expect(progress.accessibilityTextSize, AccessibilityTextSize.extraLarge);
    expect(progress.screenContrast, ScreenContrast.vivid);
    daily.dispose();
  });

  testWidgets('320dp 아주 큰 글씨에서 미션 3개를 스크롤해 표시한다', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final (progress, daily) = await createProviders(
      clock: () => DateTime.utc(2026, 9, 25, 3),
      values: {'accessibility_text_size': 'extraLarge'},
    );
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: progress),
          ChangeNotifierProvider.value(value: daily),
        ],
        child: const MaterialApp(home: MissionTabPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('0 / 3 완료'), findsOneWidget);
    expect(find.text('완료하면 추가 포인트 10점'), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('완료된 미션 3개를 체크와 상태 문구로 표시한다', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final ids = DailyMissionCatalog.definitions
        .take(3)
        .map((item) => item.id)
        .toList();
    final (progress, daily) = await createProviders(
      clock: () => DateTime.utc(2026, 9, 25, 3),
      values: {
        DailyMissionProvider.dateKey: '2026-09-25',
        DailyMissionProvider.selectedIdsKey: ids,
        DailyMissionProvider.completedIdsKey: ids,
        DailyMissionProvider.rewardedIdsKey: ids,
      },
    );
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: progress),
          ChangeNotifierProvider.value(value: daily),
        ],
        child: const MaterialApp(home: MissionTabPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('3 / 3 완료'), findsOneWidget);
    expect(find.text('완료 · 추가 보상 지급 완료'), findsNWidgets(3));
    expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });
}
