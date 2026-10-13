import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:han_geoleum_digital/core/data_migration/data_migration_coordinator.dart';
import 'package:han_geoleum_digital/core/data_migration/preference_keys.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';
import 'package:han_geoleum_digital/features/rewards/reward_catalog.dart';
import 'package:han_geoleum_digital/features/rewards/reward_models.dart';
import 'package:han_geoleum_digital/features/rewards/reward_repository.dart';

void main() {
  final catalog = RewardCatalog.v3Initial();

  RewardState sampleState() {
    return RewardState(
      unlockedRewardIds: {'title_first_step', 'accessory_scarf', 'theme_sage'},
      unlockedAtByRewardId: {
        'title_first_step': DateTime.utc(2026, 10, 13, 1),
        'accessory_scarf': DateTime.utc(2026, 10, 13, 2),
        'theme_sage': DateTime.utc(2026, 10, 13, 3),
      },
      selectedTitleId: 'title_first_step',
      selectedAccessoryIds: {'accessory_scarf'},
      selectedThemeId: 'theme_sage',
      dataVersion: RewardRepository.currentDataVersion,
      catalogVersion: catalog.version,
    );
  }

  test('빈 저장소는 키를 만들지 않고 빈 상태를 반환한다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    final state = await RewardRepository(preferences).load();

    expect(state, RewardState.empty());
    expect(
      preferences.getKeys().where((key) => key.startsWith('v3_reward_')),
      isEmpty,
    );
  });

  test('전체 상태를 안전하게 저장하고 앱 재실행처럼 복원한다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = RewardRepository(preferences);

    await repository.save(sampleState());
    final restored = await RewardRepository(
      await SharedPreferences.getInstance(),
    ).load();

    expect(restored, sampleState());
    expect(preferences.containsKey(V3RewardKeys.pendingStateJson), isFalse);
    expect(
      preferences.getInt(V3RewardKeys.dataVersion),
      RewardRepository.currentDataVersion,
    );
  });

  test('획득한 칭호·장식·테마만 선택할 수 있다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = RewardRepository(preferences);
    await repository.save(
      sampleState().copyWith(
        selectedTitleId: null,
        selectedAccessoryIds: {},
        selectedThemeId: null,
      ),
    );

    expect(
      (await repository.selectTitle('title_first_step')).selectedTitleId,
      'title_first_step',
    );
    expect(
      (await repository.selectAccessories({
        'accessory_scarf',
      })).selectedAccessoryIds,
      {'accessory_scarf'},
    );
    expect(
      (await repository.selectTheme('theme_sage')).selectedThemeId,
      'theme_sage',
    );
    expect(
      () => repository.selectTitle('title_steady_learner'),
      throwsStateError,
    );
    expect(() => repository.selectTitle('theme_sage'), throwsArgumentError);
    expect(() => repository.selectTheme('missing'), throwsStateError);
  });

  test('획득한 보상만 축하 완료로 기록하며 중복을 만들지 않는다', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = RewardRepository(await SharedPreferences.getInstance());
    await repository.save(sampleState());

    final updated = await repository.markCelebrated([
      'title_first_step',
      'title_first_step',
    ]);

    expect(updated.celebratedRewardIds, {'title_first_step'});
    expect(
      () => repository.markCelebrated(['title_steady_learner']),
      throwsStateError,
    );
  });

  test('잘못된 JSON·날짜·선택을 복구하고 미래 ID는 보존한다', () async {
    SharedPreferences.setMockInitialValues({
      V3RewardKeys.dataVersion: -1,
      V3RewardKeys.catalogVersion: -2,
      V3RewardKeys.unlockedIds: <String>[
        'title_first_step',
        'title_first_step',
        'future_reward',
      ],
      V3RewardKeys.unlockedAtJson: jsonEncode({'title_first_step': 'bad-date'}),
      V3RewardKeys.celebratedIds: <String>['not_unlocked'],
      V3RewardKeys.selectedTitleId: 'future_reward',
      V3RewardKeys.selectedAccessoryIds: <String>['title_first_step'],
      V3RewardKeys.selectedThemeId: 'accessory_scarf',
    });
    final state = await RewardRepository(
      await SharedPreferences.getInstance(),
    ).load();

    expect(state.unlockedRewardIds, {'title_first_step', 'future_reward'});
    expect(state.unlockedAtByRewardId, isEmpty);
    expect(state.celebratedRewardIds, isEmpty);
    expect(state.selectedTitleId, isNull);
    expect(state.selectedAccessoryIds, isEmpty);
    expect(state.selectedThemeId, isNull);
    expect(state.dataVersion, 0);
    expect(state.catalogVersion, 0);
  });

  test('손상된 pending은 제거하고 정상 pending은 중단 저장을 복구한다', () async {
    SharedPreferences.setMockInitialValues({
      V3RewardKeys.pendingStateJson: '{broken',
      V2PreferenceKeys.points: 160,
    });
    var preferences = await SharedPreferences.getInstance();
    var repository = RewardRepository(preferences);
    expect(await repository.load(), RewardState.empty());
    expect(preferences.containsKey(V3RewardKeys.pendingStateJson), isFalse);
    expect(preferences.getInt(V2PreferenceKeys.points), 160);

    SharedPreferences.setMockInitialValues({
      V3RewardKeys.pendingStateJson: sampleState().toJsonString(),
      V2PreferenceKeys.points: 160,
    });
    preferences = await SharedPreferences.getInstance();
    repository = RewardRepository(preferences);

    expect(await repository.load(), sampleState());
    expect(preferences.containsKey(V3RewardKeys.pendingStateJson), isFalse);
    expect(preferences.getInt(V2PreferenceKeys.points), 160);
  });

  test('미래 데이터 버전은 덮어쓰거나 pending을 제거하지 않는다', () async {
    final future = sampleState().copyWith(dataVersion: 99).toJsonString();
    SharedPreferences.setMockInitialValues({
      V3RewardKeys.dataVersion: 99,
      V3RewardKeys.unlockedIds: <String>['future_reward'],
      V3RewardKeys.pendingStateJson: future,
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = RewardRepository(preferences);

    final state = await repository.load();

    expect(state.dataVersion, 99);
    expect(state.unlockedRewardIds, {'future_reward'});
    expect(preferences.getString(V3RewardKeys.pendingStateJson), future);
    expect(() => repository.save(state), throwsUnsupportedError);
  });

  test('미래 카탈로그 버전도 덮어쓰거나 pending을 제거하지 않는다', () async {
    final future = sampleState().copyWith(catalogVersion: 99).toJsonString();
    SharedPreferences.setMockInitialValues({
      V3RewardKeys.dataVersion: 1,
      V3RewardKeys.catalogVersion: 99,
      V3RewardKeys.unlockedIds: <String>['future_reward'],
      V3RewardKeys.pendingStateJson: future,
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = RewardRepository(preferences);

    final state = await repository.load();

    expect(state.catalogVersion, 99);
    expect(state.unlockedRewardIds, {'future_reward'});
    expect(preferences.getString(V3RewardKeys.pendingStateJson), future);
    expect(() => repository.save(state), throwsUnsupportedError);
  });

  test('저장 실패를 성공으로 보고하지 않고 pending으로 재실행 가능하다', () async {
    final store = MemoryRewardStore(failOnceAt: V3RewardKeys.celebratedIds);
    final repository = RewardRepository.withStore(store);

    await expectLater(repository.save(sampleState()), throwsStateError);
    expect(store.keys, contains(V3RewardKeys.pendingStateJson));

    final recovered = await RewardRepository.withStore(store).load();
    expect(recovered, sampleState());
    expect(store.keys, isNot(contains(V3RewardKeys.pendingStateJson)));
  });

  test('초기화는 보상 키만 제거하고 V2 데이터와 migration metadata를 보존한다', () async {
    SharedPreferences.setMockInitialValues({
      V2PreferenceKeys.points: 160,
      V2PreferenceKeys.cafeSoloFirstBadge: true,
      V3DataKeys.schemaVersion: 1,
      V3DataKeys.completedRevisions: <String>['v3_foundation_1'],
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = RewardRepository(preferences);
    await repository.save(sampleState());

    await repository.clear();

    expect(
      preferences.getKeys().where(V3RewardKeys.stateKeys.contains),
      isEmpty,
    );
    expect(preferences.getInt(V2PreferenceKeys.points), 160);
    expect(preferences.getBool(V2PreferenceKeys.cafeSoloFirstBadge), isTrue);
    expect(preferences.getInt(V3DataKeys.schemaVersion), 1);
    expect(preferences.getStringList(V3DataKeys.completedRevisions), [
      'v3_foundation_1',
    ]);
  });

  test('보상 키가 없을 때 기록 초기화는 보상 키를 새로 만들지 않는다', () async {
    SharedPreferences.setMockInitialValues({
      V2PreferenceKeys.points: 160,
      V3DataKeys.schemaVersion: 1,
      V3DataKeys.completedRevisions: <String>['v3_foundation_1'],
    });
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);

    await progress.resetPracticeRecords();

    expect(
      preferences.getKeys().where((key) => key.startsWith('v3_reward_')),
      isEmpty,
    );
    expect(preferences.getInt(V3DataKeys.schemaVersion), 1);
    expect(preferences.getStringList(V3DataKeys.completedRevisions), [
      'v3_foundation_1',
    ]);
  });

  test('연습 기록 초기화는 생성된 보상 상태와 선택만 함께 제거한다', () async {
    SharedPreferences.setMockInitialValues({
      V2PreferenceKeys.points: 160,
      V2PreferenceKeys.accessibilityTextSize: 'extraLarge',
      V2PreferenceKeys.screenContrast: 'vivid',
      V2PreferenceKeys.onboardingCompleted: true,
      V3DataKeys.schemaVersion: 1,
      V3DataKeys.completedRevisions: <String>['v3_foundation_1'],
    });
    final preferences = await SharedPreferences.getInstance();
    await RewardRepository(preferences).save(sampleState());
    final progress = LearningProgressProvider(preferences);

    await progress.resetPracticeRecords();

    expect(
      preferences.getKeys().where(V3RewardKeys.stateKeys.contains),
      isEmpty,
    );
    expect(preferences.getInt(V3DataKeys.schemaVersion), 1);
    expect(preferences.getStringList(V3DataKeys.completedRevisions), [
      'v3_foundation_1',
    ]);
    expect(
      preferences.getString(V2PreferenceKeys.accessibilityTextSize),
      'extraLarge',
    );
    expect(preferences.getString(V2PreferenceKeys.screenContrast), 'vivid');
    expect(preferences.getBool(V2PreferenceKeys.onboardingCompleted), isTrue);
  });

  test('앱 초기 migration은 160점 사용자에게 보상을 지급하거나 키를 만들지 않는다', () async {
    SharedPreferences.setMockInitialValues({
      V2PreferenceKeys.points: 160,
      V2PreferenceKeys.cafeSoloFirstBadge: true,
    });
    final preferences = await SharedPreferences.getInstance();

    await DataMigrationCoordinator(preferences).migrate();

    expect(preferences.getInt(V2PreferenceKeys.points), 160);
    expect(preferences.getBool(V2PreferenceKeys.cafeSoloFirstBadge), isTrue);
    expect(preferences.getInt(V3DataKeys.schemaVersion), 1);
    expect(preferences.getStringList(V3DataKeys.completedRevisions), [
      'v3_foundation_1',
    ]);
    expect(
      preferences.getKeys().where((key) => key.startsWith('v3_reward_')),
      isEmpty,
    );
  });
}

class MemoryRewardStore implements RewardStore {
  MemoryRewardStore({this.failOnceAt});

  final Map<String, Object> values = {};
  String? failOnceAt;

  @override
  Set<String> get keys => values.keys.toSet();

  @override
  Object? read(String key) => values[key];

  void maybeFail(String key) {
    if (failOnceAt == key) {
      failOnceAt = null;
      throw StateError('simulated write failure');
    }
  }

  @override
  Future<void> remove(String key) async {
    maybeFail(key);
    values.remove(key);
  }

  @override
  Future<void> writeInt(String key, int value) async {
    maybeFail(key);
    values[key] = value;
  }

  @override
  Future<void> writeString(String key, String value) async {
    maybeFail(key);
    values[key] = value;
  }

  @override
  Future<void> writeStringList(String key, List<String> value) async {
    maybeFail(key);
    values[key] = List<String>.of(value);
  }
}
