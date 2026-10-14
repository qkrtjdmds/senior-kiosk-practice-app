import 'package:flutter_test/flutter_test.dart';
import 'package:han_geoleum_digital/core/data_migration/preference_keys.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';
import 'package:han_geoleum_digital/features/rewards/reward_repository.dart';
import 'package:han_geoleum_digital/features/rewards/reward_models.dart';
import 'package:han_geoleum_digital/features/rewards/reward_unlock_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const thresholds = <int, int>{
    -10: 0,
    0: 0,
    99: 0,
    100: 1,
    160: 1,
    300: 2,
    1600: 7,
    5000: 12,
    9000: 12,
  };

  for (final entry in thresholds.entries) {
    test('${entry.key}점 reconciliation은 ${entry.value}개 보상을 해제한다', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final instant = DateTime.utc(2026, 10, 13, 9);
      final service = RewardUnlockService(
        RewardRepository(preferences),
        clock: () => instant,
      );

      final result = await service.reconcile(
        entry.key,
        markRetroactiveGrantCompleted: true,
      );

      expect(result.succeeded, isTrue);
      expect(result.state.unlockedRewardIds, hasLength(entry.value));
      expect(result.state.retroactiveGrantCompleted, isTrue);
      expect(result.state.unlockedAtByRewardId.values, everyElement(instant));
    });
  }

  test('1600점은 같은 시각으로 7개 보상을 해제하고 포인트를 바꾸지 않는다', () async {
    SharedPreferences.setMockInitialValues({V2PreferenceKeys.points: 1600});
    final preferences = await SharedPreferences.getInstance();
    final instant = DateTime.utc(2026, 10, 13, 10);

    final result = await RewardUnlockService(
      RewardRepository(preferences),
      clock: () => instant,
    ).reconcile(1600, markRetroactiveGrantCompleted: true);

    expect(result.newRewardIds, [
      'title_first_step',
      'accessory_scarf',
      'theme_sage',
      'title_steady_learner',
      'accessory_hat',
      'theme_sky',
      'accessory_glasses',
    ]);
    expect(preferences.getInt(V2PreferenceKeys.points), 1600);
    expect(result.state.unlockedAtByRewardId.values.toSet(), {instant});
  });

  test('기존 ID·시각·축하 상태와 미래 ID를 보존하며 누락 보상만 합친다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final oldInstant = DateTime.utc(2025, 1, 1);
    final newInstant = DateTime.utc(2026, 10, 13);
    final repository = RewardRepository(preferences);
    await repository.save(
      RewardState(
        unlockedRewardIds: {'title_first_step', 'future_reward'},
        unlockedAtByRewardId: {
          'title_first_step': oldInstant,
          'future_reward': oldInstant,
        },
        celebratedRewardIds: {'title_first_step'},
      ),
    );

    final result = await RewardUnlockService(
      repository,
      clock: () => newInstant,
    ).reconcile(1600, markRetroactiveGrantCompleted: true);

    expect(result.state.unlockedRewardIds, contains('future_reward'));
    expect(result.state.unlockedRewardIds, hasLength(8));
    expect(result.state.unlockedAtByRewardId['title_first_step'], oldInstant);
    expect(result.state.unlockedAtByRewardId['future_reward'], oldInstant);
    expect(result.state.celebratedRewardIds, {'title_first_step'});
    expect(result.newRewardIds, isNot(contains('title_first_step')));
  });

  test('반복·동시 요청은 보상 ID와 획득 시각을 중복 변경하지 않는다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    var tick = 0;
    final service = RewardUnlockService(
      RewardRepository(preferences),
      clock: () => DateTime.utc(2026, 10, 13, 10, tick++),
    );
    await service.reconcile(1590);

    final results = await Future.wait([
      service.reconcile(1600),
      service.reconcile(1600),
      service.reconcile(1600),
    ]);
    final stored = await RewardRepository(preferences).load();

    expect(
      results.where((result) => result.newRewardIds.isNotEmpty),
      hasLength(1),
    );
    expect(stored.unlockedRewardIds, hasLength(7));
    expect(stored.unlockedAtByRewardId, hasLength(7));
    expect(
      stored.unlockedAtByRewardId['theme_sky'],
      DateTime.utc(2026, 10, 13, 10, 1),
    );
    expect(
      stored.unlockedAtByRewardId['accessory_glasses'],
      DateTime.utc(2026, 10, 13, 10, 1),
    );
  });

  test('pending은 카탈로그 순서이며 축하 완료·미래 ID를 제외한다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = RewardRepository(preferences);
    await repository.save(
      RewardState(
        unlockedRewardIds: {
          'accessory_scarf',
          'title_first_step',
          'theme_sage',
          'future_reward',
        },
        celebratedRewardIds: {'title_first_step'},
      ),
    );

    final pending = await RewardUnlockService(repository).pendingRewards();

    expect(pending.map((reward) => reward.rewardId), [
      'accessory_scarf',
      'theme_sage',
    ]);
    expect((await repository.load()).celebratedRewardIds, {'title_first_step'});
  });

  test('미래 데이터 버전은 비파괴 읽기 후 쓰기를 중단한다', () async {
    SharedPreferences.setMockInitialValues({
      V3RewardKeys.dataVersion: 99,
      V3RewardKeys.catalogVersion: 99,
      V3RewardKeys.unlockedIds: <String>['future_reward'],
    });
    final preferences = await SharedPreferences.getInstance();

    final result = await RewardUnlockService(
      RewardRepository(preferences),
    ).reconcile(5000);

    expect(result.status, RewardUnlockStatus.futureVersion);
    expect(preferences.getStringList(V3RewardKeys.unlockedIds), [
      'future_reward',
    ]);
    expect(preferences.getInt(V3RewardKeys.dataVersion), 99);
  });

  test('저장 실패 뒤 다음 reconciliation이 pending 저장을 복구한다', () async {
    final store = FailingRewardStore(failOnceAt: V3RewardKeys.unlockedIds);
    final repository = RewardRepository.withStore(store);
    final first = await RewardUnlockService(repository).reconcile(100);

    expect(first.status, RewardUnlockStatus.saveFailed);
    expect(store.keys, contains(V3RewardKeys.pendingStateJson));

    final recovered = await RewardUnlockService(
      RewardRepository.withStore(store),
    ).reconcile(100);
    expect(recovered.succeeded, isTrue);
    expect(recovered.state.unlockedRewardIds, {'title_first_step'});
    expect(store.keys, isNot(contains(V3RewardKeys.pendingStateJson)));
  });

  test('포인트 지급 성공 후 보상 저장 실패는 포인트 지급을 취소하지 않는다', () async {
    SharedPreferences.setMockInitialValues({V2PreferenceKeys.points: 90});
    final preferences = await SharedPreferences.getInstance();
    final failingStore = FailingRewardStore(
      initialValues: {
        for (final key in preferences.getKeys()) key: preferences.get(key)!,
      },
      failOnceAt: V3RewardKeys.unlockedIds,
      onWrite: (key, value) async {
        if (key == V2PreferenceKeys.points && value is int) {
          await preferences.setInt(key, value);
        }
      },
    );
    final progress = LearningProgressProvider(
      preferences,
      rewardUnlockService: RewardUnlockService(
        RewardRepository.withStore(failingStore),
      ),
    );
    progress.selectMode(CafeLearningMode.guided);

    await progress.completeCafeLearning();

    expect(progress.totalPoints, 100);
    expect(progress.guidedCompletionCount, 1);
    final recovered = await RewardUnlockService(
      RewardRepository.withStore(failingStore),
    ).reconcile(100);
    expect(recovered.state.unlockedRewardIds, {'title_first_step'});
  });

  test('포인트 증가가 없는 중복 완료는 보상 획득 시각을 바꾸지 않는다', () async {
    SharedPreferences.setMockInitialValues({V2PreferenceKeys.points: 90});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);
    progress.selectMode(CafeLearningMode.guided);
    await progress.completeCafeLearning();
    final before = await RewardRepository(preferences).load();

    await progress.completeCafeLearning();
    final after = await RewardRepository(preferences).load();

    expect(progress.totalPoints, 100);
    expect(after, before);
  });

  for (final crossing in const <(int, Set<String>)>[
    (90, {'title_first_step'}),
    (290, {'accessory_scarf'}),
    (490, {'theme_sage'}),
    (1590, {'theme_sky', 'accessory_glasses'}),
  ]) {
    test('${crossing.$1}점에서 10점 지급 시 새 기준 보상만 자동 해제한다', () async {
      SharedPreferences.setMockInitialValues({
        V2PreferenceKeys.points: crossing.$1,
      });
      final preferences = await SharedPreferences.getInstance();
      final repository = RewardRepository(preferences);
      final service = RewardUnlockService(repository);
      await service.reconcile(crossing.$1);
      final before = await repository.load();
      final progress = LearningProgressProvider(
        preferences,
        rewardUnlockService: service,
      );
      progress.selectMode(CafeLearningMode.guided);

      await progress.completeCafeLearning();

      final after = await repository.load();
      expect(progress.totalPoints, crossing.$1 + 10);
      expect(
        after.unlockedRewardIds.difference(before.unlockedRewardIds),
        crossing.$2,
      );
    });
  }

  test('오늘의 미션 추가 10점도 같은 자동 해제 경로를 사용한다', () async {
    SharedPreferences.setMockInitialValues({V2PreferenceKeys.points: 90});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);

    expect(await progress.awardDailyMissionBonus('2026-10-13:test'), isTrue);

    expect(progress.totalPoints, 100);
    expect((await RewardRepository(preferences).load()).unlockedRewardIds, {
      'title_first_step',
    });
  });

  test('초기화 후 0점에서는 재지급하지 않고 다시 100점에 도달하면 획득한다', () async {
    SharedPreferences.setMockInitialValues({V2PreferenceKeys.points: 100});
    final preferences = await SharedPreferences.getInstance();
    final service = RewardUnlockService(RewardRepository(preferences));
    await service.reconcile(100, markRetroactiveGrantCompleted: true);
    final progress = LearningProgressProvider(preferences);

    await progress.resetPracticeRecords();
    final zeroResult = await service.reconcile(0);

    expect(zeroResult.state.unlockedRewardIds, isEmpty);
    expect(
      preferences.getKeys().where(V3RewardKeys.stateKeys.contains),
      isEmpty,
    );

    for (var i = 0; i < 10; i++) {
      progress.selectMode(CafeLearningMode.guided);
      await progress.completeCafeLearning();
    }
    expect(progress.totalPoints, 100);
    expect((await RewardRepository(preferences).load()).unlockedRewardIds, {
      'title_first_step',
    });
  });
}

class FailingRewardStore implements RewardStore {
  FailingRewardStore({
    Map<String, Object>? initialValues,
    this.failOnceAt,
    this.onWrite,
  }) : values = Map<String, Object>.of(initialValues ?? const {});

  final Map<String, Object> values;
  String? failOnceAt;
  final Future<void> Function(String key, Object value)? onWrite;

  @override
  Set<String> get keys => values.keys.toSet();

  @override
  Object? read(String key) => values[key];

  void _maybeFail(String key) {
    if (failOnceAt == key) {
      failOnceAt = null;
      throw StateError('simulated write failure');
    }
  }

  Future<void> _write(String key, Object value) async {
    _maybeFail(key);
    values[key] = value;
    await onWrite?.call(key, value);
  }

  @override
  Future<void> remove(String key) async {
    _maybeFail(key);
    values.remove(key);
  }

  @override
  Future<void> writeInt(String key, int value) => _write(key, value);

  @override
  Future<void> writeString(String key, String value) => _write(key, value);

  @override
  Future<void> writeStringList(String key, List<String> value) =>
      _write(key, List<String>.of(value));
}
