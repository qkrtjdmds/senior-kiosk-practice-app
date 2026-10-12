import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:han_geoleum_digital/core/data_migration/data_migration_coordinator.dart';
import 'package:han_geoleum_digital/core/data_migration/data_migration_models.dart';
import 'package:han_geoleum_digital/core/data_migration/preference_keys.dart';
import 'package:han_geoleum_digital/features/daily_mission/daily_mission_provider.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';

void main() {
  const missionIds = <String>[
    'cafe_solo_complete',
    'atm_solo_complete',
    'photo_solo_complete',
  ];

  String record(String name, int points, String completedAt) {
    return jsonEncode({
      'learningName': name,
      'modeName': '혼자 해보기',
      'points': points,
      'completedAt': completedAt,
    });
  }

  Map<String, Object> v2Fixture() {
    final values = <String, Object>{};
    var count = 1;
    for (final key in V2PreferenceKeys.nonNegativeIntegerKeys) {
      values[key] = count++;
    }
    values.addAll({
      V2PreferenceKeys.points: 160,
      V2PreferenceKeys.cafeSoloFirstBadge: true,
      V2PreferenceKeys.hospitalSoloFirstBadge: true,
      V2PreferenceKeys.photoSoloFirstBadge: true,
      V2PreferenceKeys.recentPracticeRecords: <String>[
        record('사진 보내기', 20, '2026-10-11T10:00:00.000'),
        record('ATM 출금', 10, '2026-10-10T09:00:00.000'),
      ],
      V2PreferenceKeys.dailyMissionRewardTokens: <String>[
        '2026-10-12:cafe_solo_complete',
      ],
      V2PreferenceKeys.dailyMissionDate: '2026-10-12',
      V2PreferenceKeys.dailyMissionSelectedIds: missionIds,
      V2PreferenceKeys.dailyMissionCompletedIds: <String>['cafe_solo_complete'],
      V2PreferenceKeys.dailyMissionRewardedIds: <String>['cafe_solo_complete'],
      V2PreferenceKeys.dailyMissionCompletedAt: jsonEncode({
        'cafe_solo_complete': '2026-10-12T09:00:00.000',
      }),
      V2PreferenceKeys.dailyMissionPreviousIds: missionIds,
      V2PreferenceKeys.dailyMissionFrequency: jsonEncode({
        'cafe_solo_complete': 2,
        'atm_solo_complete': 1,
        'photo_solo_complete': 1,
      }),
      V2PreferenceKeys.dailyMissionActiveId: 'atm_solo_complete',
      V2PreferenceKeys.accessibilityTextSize: 'extraLarge',
      V2PreferenceKeys.screenContrast: 'vivid',
      V2PreferenceKeys.onboardingCompleted: true,
      V2PreferenceKeys.cafeMode: 'solo',
      V2PreferenceKeys.atmMode: 'guided',
      V2PreferenceKeys.cafeSoloSessionAwarded: true,
    });
    return values;
  }

  Map<String, Object?> snapshotV2(SharedPreferences preferences) {
    final keys = <String>{
      ...V2PreferenceKeys.practiceRecordKeys,
      ...V2PreferenceKeys.dailyMissionKeys,
      V2PreferenceKeys.accessibilityTextSize,
      V2PreferenceKeys.screenContrast,
      V2PreferenceKeys.onboardingCompleted,
    };
    return {
      for (final key in keys)
        if (preferences.containsKey(key)) key: preferences.get(key),
    };
  }

  test('신규 설치는 V2 키 없이 schema version과 revision만 기록한다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    final first = await DataMigrationCoordinator(preferences).migrate();

    expect(
      first.status,
      DataMigrationStatus.migrated,
      reason: '${first.errorType}: ${first.errorMessage}',
    );
    expect(
      preferences.getInt(V3DataKeys.schemaVersion),
      DataMigrationCoordinator.currentSchemaVersion,
    );
    expect(
      preferences.getStringList(V3DataKeys.completedRevisions),
      DataMigrationCoordinator.supportedRevisionIds,
    );
    expect(
      preferences.getKeys().where(V2PreferenceKeys.practiceRecordKeys.contains),
      isEmpty,
    );
    expect(
      preferences.getKeys().where((key) => key.startsWith('v3_reward_')),
      isEmpty,
    );

    final second = await DataMigrationCoordinator(preferences).migrate();
    expect(second.status, DataMigrationStatus.alreadyCurrent);
    expect(second.appliedRevisions, isEmpty);
  });

  test('V2 사용자의 160점과 모든 기록·설정·미션을 그대로 보존한다', () async {
    SharedPreferences.setMockInitialValues(v2Fixture());
    final preferences = await SharedPreferences.getInstance();
    final before = snapshotV2(preferences);

    final result = await DataMigrationCoordinator(preferences).migrate();

    expect(result.succeeded, isTrue);
    expect(snapshotV2(preferences), equals(before));
    expect(preferences.getInt(V2PreferenceKeys.points), 160);
    for (final key in V2PreferenceKeys.nonNegativeIntegerKeys) {
      expect(preferences.getInt(key), before[key]);
    }
    expect(
      preferences.getStringList(V2PreferenceKeys.recentPracticeRecords),
      before[V2PreferenceKeys.recentPracticeRecords],
    );
    expect(
      preferences.getKeys().where((key) => key.startsWith('v3_reward_')),
      isEmpty,
    );
  });

  for (final checkpoint in MigrationCheckpoint.values) {
    test('중단 지점 ${checkpoint.name} 이후 재실행하면 안전하게 완료한다', () async {
      SharedPreferences.setMockInitialValues(v2Fixture());
      final preferences = await SharedPreferences.getInstance();
      final before = snapshotV2(preferences);
      var interrupted = false;
      final first = await DataMigrationCoordinator(
        preferences,
        checkpointHook: (current, _) async {
          if (!interrupted && current == checkpoint) {
            interrupted = true;
            throw StateError('simulated interruption');
          }
        },
      ).migrate();

      expect(first.status, DataMigrationStatus.failed);
      expect(
        preferences.getInt(V3DataKeys.pendingRevision),
        DataMigrationCoordinator.currentSchemaVersion,
      );

      final recovered = await DataMigrationCoordinator(preferences).migrate();
      expect(recovered.succeeded, isTrue);
      expect(preferences.containsKey(V3DataKeys.pendingRevision), isFalse);
      expect(
        preferences.getInt(V3DataKeys.schemaVersion),
        DataMigrationCoordinator.currentSchemaVersion,
      );
      expect(snapshotV2(preferences), equals(before));
    });
  }

  test('손상된 숫자·최근 기록·미션 상태만 복구하고 설정은 보존한다', () async {
    final validRecord = record('카페 키오스크', 20, '2026-10-12T08:00:00.000');
    SharedPreferences.setMockInitialValues({
      V2PreferenceKeys.points: -10,
      V2PreferenceKeys.cafeGuidedCompletionCount: '잘못된 값',
      V2PreferenceKeys.hospitalSoloCompletionCount: -2,
      V2PreferenceKeys.recentPracticeRecords: <String>[validRecord, '{broken'],
      V2PreferenceKeys.dailyMissionDate: '2026-10-12',
      V2PreferenceKeys.dailyMissionSelectedIds: <String>['unknown_mission'],
      V2PreferenceKeys.dailyMissionCompletedAt: '{broken',
      V2PreferenceKeys.dailyMissionFrequency: '{broken',
      V2PreferenceKeys.accessibilityTextSize: 'extraLarge',
      V2PreferenceKeys.screenContrast: 'vivid',
      V2PreferenceKeys.onboardingCompleted: true,
    });
    final preferences = await SharedPreferences.getInstance();

    final result = await DataMigrationCoordinator(preferences).migrate();

    expect(result.status, DataMigrationStatus.recovered);
    expect(preferences.getInt(V2PreferenceKeys.points), 0);
    expect(preferences.getInt(V2PreferenceKeys.cafeGuidedCompletionCount), 0);
    expect(preferences.getInt(V2PreferenceKeys.hospitalSoloCompletionCount), 0);
    expect(
      preferences.getStringList(V2PreferenceKeys.recentPracticeRecords),
      <String>[validRecord],
    );
    expect(
      preferences.containsKey(V2PreferenceKeys.dailyMissionSelectedIds),
      isFalse,
    );
    expect(
      preferences.containsKey(V2PreferenceKeys.dailyMissionFrequency),
      isFalse,
    );
    expect(
      preferences.getString(V2PreferenceKeys.accessibilityTextSize),
      'extraLarge',
    );
    expect(preferences.getString(V2PreferenceKeys.screenContrast), 'vivid');
    expect(preferences.getBool(V2PreferenceKeys.onboardingCompleted), isTrue);

    final progress = LearningProgressProvider(preferences);
    final daily = DailyMissionProvider(
      preferences,
      progress,
      clock: () => DateTime.utc(2026, 10, 12),
    );
    expect(daily.missions, hasLength(3));
    daily.dispose();
  });

  test('손상된 migration metadata는 복구하고 revision을 한 번 완료한다', () async {
    SharedPreferences.setMockInitialValues({
      V3DataKeys.schemaVersion: -1,
      V3DataKeys.pendingRevision: 'broken',
      V3DataKeys.completedRevisions: 'broken',
      V2PreferenceKeys.points: 160,
    });
    final preferences = await SharedPreferences.getInstance();

    final result = await DataMigrationCoordinator(preferences).migrate();

    expect(result.status, DataMigrationStatus.recovered);
    expect(preferences.getInt(V2PreferenceKeys.points), 160);
    expect(
      preferences.getInt(V3DataKeys.schemaVersion),
      DataMigrationCoordinator.currentSchemaVersion,
    );
    expect(
      preferences.getStringList(V3DataKeys.completedRevisions),
      DataMigrationCoordinator.supportedRevisionIds,
    );
    expect(preferences.containsKey(V3DataKeys.pendingRevision), isFalse);
  });

  test('완료 revision 목록의 알 수 없는 ID와 중복 ID를 정리한다', () async {
    SharedPreferences.setMockInitialValues({
      V3DataKeys.schemaVersion: 1,
      V3DataKeys.completedRevisions: <String>[
        'v3_foundation_1',
        'unknown_revision',
        'v3_foundation_1',
      ],
      V2PreferenceKeys.points: 160,
    });
    final preferences = await SharedPreferences.getInstance();

    final result = await DataMigrationCoordinator(preferences).migrate();

    expect(result.status, DataMigrationStatus.recovered);
    expect(preferences.getInt(V2PreferenceKeys.points), 160);
    expect(
      preferences.getStringList(V3DataKeys.completedRevisions),
      DataMigrationCoordinator.supportedRevisionIds,
    );
    expect(result.appliedRevisions, isEmpty);
  });

  test('지원 버전보다 높은 schema는 수정하거나 다운그레이드하지 않는다', () async {
    SharedPreferences.setMockInitialValues({
      V3DataKeys.schemaVersion: 99,
      V2PreferenceKeys.points: 160,
    });
    final preferences = await SharedPreferences.getInstance();
    final before = Map<String, Object?>.fromEntries(
      preferences.getKeys().map((key) => MapEntry(key, preferences.get(key))),
    );

    final result = await DataMigrationCoordinator(preferences).migrate();

    expect(result.status, DataMigrationStatus.futureVersion);
    expect(
      Map<String, Object?>.fromEntries(
        preferences.getKeys().map((key) => MapEntry(key, preferences.get(key))),
      ),
      equals(before),
    );
  });

  test('연습 기록 초기화 후에도 migration metadata와 설정은 유지한다', () async {
    SharedPreferences.setMockInitialValues(v2Fixture());
    final preferences = await SharedPreferences.getInstance();
    await DataMigrationCoordinator(preferences).migrate();
    final progress = LearningProgressProvider(preferences);
    final daily = DailyMissionProvider(
      preferences,
      progress,
      clock: () => DateTime.utc(2026, 10, 12),
    );

    await progress.resetPracticeRecords();

    expect(progress.totalPoints, 0);
    expect(
      preferences.getInt(V3DataKeys.schemaVersion),
      DataMigrationCoordinator.currentSchemaVersion,
    );
    expect(
      preferences.getStringList(V3DataKeys.completedRevisions),
      DataMigrationCoordinator.supportedRevisionIds,
    );
    expect(
      preferences.getString(V2PreferenceKeys.accessibilityTextSize),
      'extraLarge',
    );
    expect(preferences.getString(V2PreferenceKeys.screenContrast), 'vivid');
    expect(preferences.getBool(V2PreferenceKeys.onboardingCompleted), isTrue);
    expect(daily.missions, hasLength(3));
    expect(daily.completedCount, 0);
    daily.dispose();
  });
}
