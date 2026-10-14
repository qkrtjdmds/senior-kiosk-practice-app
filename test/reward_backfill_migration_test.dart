import 'package:flutter_test/flutter_test.dart';
import 'package:han_geoleum_digital/core/data_migration/data_migration_coordinator.dart';
import 'package:han_geoleum_digital/core/data_migration/data_migration_models.dart';
import 'package:han_geoleum_digital/core/data_migration/preference_keys.dart';
import 'package:han_geoleum_digital/features/rewards/reward_repository.dart';
import 'package:han_geoleum_digital/features/rewards/reward_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const expectedCounts = <int, int>{
    0: 0,
    99: 0,
    100: 1,
    160: 1,
    300: 2,
    1600: 7,
    5000: 12,
    6000: 12,
  };

  for (final entry in expectedCounts.entries) {
    test(
      'revision 2는 ${entry.key}점 사용자의 보상 ${entry.value}개를 소급 지급한다',
      () async {
        SharedPreferences.setMockInitialValues({
          V2PreferenceKeys.points: entry.key,
        });
        final preferences = await SharedPreferences.getInstance();

        final result = await DataMigrationCoordinator(preferences).migrate();
        final rewards = await RewardRepository(preferences).load();

        expect(result.succeeded, isTrue);
        expect(preferences.getInt(V2PreferenceKeys.points), entry.key);
        expect(rewards.unlockedRewardIds, hasLength(entry.value));
        expect(rewards.retroactiveGrantCompleted, isTrue);
        expect(preferences.getInt(V3DataKeys.schemaVersion), 2);
        expect(preferences.getStringList(V3DataKeys.completedRevisions), [
          'v3_foundation_1',
          'v3_reward_backfill_2',
        ]);
        expect(preferences.containsKey(V3DataKeys.pendingRevision), isFalse);
      },
    );
  }

  test('revision 2 반복 실행은 보상과 획득 시각을 바꾸지 않는다', () async {
    SharedPreferences.setMockInitialValues({V2PreferenceKeys.points: 1600});
    final preferences = await SharedPreferences.getInstance();
    final coordinator = DataMigrationCoordinator(preferences);
    await coordinator.migrate();
    final before = await RewardRepository(preferences).load();

    final second = await coordinator.migrate();
    final after = await RewardRepository(preferences).load();

    expect(second.status, DataMigrationStatus.alreadyCurrent);
    expect(after, before);
  });

  for (final checkpoint in MigrationCheckpoint.values) {
    test('revision 2 ${checkpoint.name} 중단 뒤 재실행하면 일관되게 복구한다', () async {
      SharedPreferences.setMockInitialValues({
        V2PreferenceKeys.points: 1600,
        V3DataKeys.schemaVersion: 1,
        V3DataKeys.completedRevisions: <String>['v3_foundation_1'],
      });
      final preferences = await SharedPreferences.getInstance();
      var interrupted = false;

      final failed = await DataMigrationCoordinator(
        preferences,
        checkpointHook: (current, revision) async {
          if (!interrupted && revision == 2 && current == checkpoint) {
            interrupted = true;
            throw StateError('simulated interruption');
          }
        },
      ).migrate();
      expect(failed.status, DataMigrationStatus.failed);

      final recovered = await DataMigrationCoordinator(preferences).migrate();
      final rewards = await RewardRepository(preferences).load();

      expect(recovered.succeeded, isTrue);
      expect(rewards.unlockedRewardIds, hasLength(7));
      expect(preferences.getInt(V2PreferenceKeys.points), 1600);
      expect(preferences.getInt(V3DataKeys.schemaVersion), 2);
      expect(preferences.getStringList(V3DataKeys.completedRevisions), [
        'v3_foundation_1',
        'v3_reward_backfill_2',
      ]);
      expect(preferences.containsKey(V3DataKeys.pendingRevision), isFalse);
    });
  }

  test('기존 획득 상태와 미래 ID를 합집합으로 보존한다', () async {
    final oldTime = DateTime.utc(2025, 1, 1);
    SharedPreferences.setMockInitialValues({
      V2PreferenceKeys.points: 1600,
      V3DataKeys.schemaVersion: 1,
      V3DataKeys.completedRevisions: <String>['v3_foundation_1'],
    });
    final preferences = await SharedPreferences.getInstance();
    await RewardRepository(preferences).save(
      RewardState(
        unlockedRewardIds: {'title_first_step', 'future_reward'},
        unlockedAtByRewardId: {
          'title_first_step': oldTime,
          'future_reward': oldTime,
        },
        celebratedRewardIds: {'title_first_step'},
      ),
    );

    await DataMigrationCoordinator(preferences).migrate();
    final rewards = await RewardRepository(preferences).load();

    expect(rewards.unlockedRewardIds, hasLength(8));
    expect(rewards.unlockedRewardIds, contains('future_reward'));
    expect(rewards.unlockedAtByRewardId['title_first_step'], oldTime);
    expect(rewards.unlockedAtByRewardId['future_reward'], oldTime);
    expect(rewards.celebratedRewardIds, {'title_first_step'});
  });

  test('미래 schema는 보상 migration과 기존 데이터를 수정하지 않는다', () async {
    SharedPreferences.setMockInitialValues({
      V2PreferenceKeys.points: 160,
      V3DataKeys.schemaVersion: 99,
      V3RewardKeys.unlockedIds: <String>['future_reward'],
    });
    final preferences = await SharedPreferences.getInstance();

    final result = await DataMigrationCoordinator(preferences).migrate();

    expect(result.status, DataMigrationStatus.futureVersion);
    expect(preferences.getInt(V2PreferenceKeys.points), 160);
    expect(preferences.getInt(V3DataKeys.schemaVersion), 99);
    expect(preferences.getStringList(V3RewardKeys.unlockedIds), [
      'future_reward',
    ]);
  });
}
