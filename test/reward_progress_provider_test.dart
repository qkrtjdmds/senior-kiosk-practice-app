import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:han_geoleum_digital/core/data_migration/preference_keys.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';
import 'package:han_geoleum_digital/features/rewards/reward_catalog.dart';
import 'package:han_geoleum_digital/features/rewards/reward_models.dart';
import 'package:han_geoleum_digital/features/rewards/reward_progress_provider.dart';
import 'package:han_geoleum_digital/features/rewards/reward_repository.dart';
import 'package:han_geoleum_digital/features/rewards/reward_unlock_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<RewardProgressProvider> createProvider(
    int points, {
    RewardCatalog? catalog,
    RewardState? state,
  }) async {
    SharedPreferences.setMockInitialValues({V2PreferenceKeys.points: points});
    final preferences = await SharedPreferences.getInstance();
    final repository = RewardRepository(preferences, catalog: catalog);
    if (state != null) {
      await repository.save(state);
    } else {
      await RewardUnlockService(repository).reconcile(points);
    }
    final provider = RewardProgressProvider(
      repository: repository,
      progress: LearningProgressProvider(preferences),
    );
    await provider.refresh();
    addTearDown(provider.dispose);
    return provider;
  }

  for (final entry in const <(int, int, int)>[
    (0, 100, 0),
    (99, 1, 0),
    (100, 200, 1),
    (160, 140, 1),
    (1599, 1, 5),
    (1600, 400, 7),
  ]) {
    test('${entry.$1}점에서 다음 보상과 획득 수를 계산한다', () async {
      final provider = await createProvider(entry.$1);

      expect(provider.pointsUntilNextReward, entry.$2);
      expect(provider.unlockedCount, entry.$3);
      expect(provider.progressToNextReward, inInclusiveRange(0, 1));
    });
  }

  test('같은 1600점 기준의 두 보상을 하나의 다음 목표로 제공한다', () async {
    final provider = await createProvider(1200);

    expect(provider.nextRequiredPoints, 1600);
    expect(provider.nextRewards.map((reward) => reward.rewardId), [
      'theme_sky',
      'accessory_glasses',
    ]);
    expect(provider.nextRewardName, '맑은 하늘 외 1개');
  });

  test('5000점은 모든 활성 보상을 획득한 상태다', () async {
    final provider = await createProvider(5000);

    expect(provider.unlockedCount, 12);
    expect(provider.totalRewardCount, 12);
    expect(provider.nextRequiredPoints, isNull);
    expect(provider.progressToNextReward, 1);
    expect(provider.nextRewardName, '모든 성장 보상을 획득했어요');
  });

  test('미래 ID와 비활성 보상은 화면 목록에서 제외한다', () async {
    final catalog = RewardCatalog([
      RewardDefinition(
        rewardId: 'active_title',
        rewardType: RewardType.title,
        title: '활성 칭호',
        description: '활성 보상',
        requiredPoints: 100,
        assetKey: 'title.active',
        sortOrder: 1,
      ),
      RewardDefinition(
        rewardId: 'inactive_theme',
        rewardType: RewardType.theme,
        title: '숨긴 테마',
        description: '비활성 보상',
        requiredPoints: 50,
        assetKey: 'theme.inactive',
        sortOrder: 2,
        isActive: false,
      ),
    ]);
    final provider = await createProvider(
      100,
      catalog: catalog,
      state: RewardState(
        unlockedRewardIds: {'active_title', 'inactive_theme', 'future_reward'},
      ),
    );

    expect(provider.activeRewards.map((reward) => reward.rewardId), [
      'active_title',
    ]);
    expect(provider.unlockedCount, 1);
  });

  test('저장된 적용 상태는 읽기 전용 상태 문구로 제공한다', () async {
    final provider = await createProvider(
      160,
      state: RewardState(
        unlockedRewardIds: {'title_first_step'},
        selectedTitleId: 'title_first_step',
      ),
    );
    final reward = provider.activeRewards.first;

    expect(provider.currentGrowthStage, '첫걸음 시작');
    expect(provider.isApplied(reward), isTrue);
    expect(provider.statusFor(reward), '적용 중');
  });

  test('재생성해도 pending 축하 상태를 소비하지 않는다', () async {
    SharedPreferences.setMockInitialValues({V2PreferenceKeys.points: 160});
    final preferences = await SharedPreferences.getInstance();
    final repository = RewardRepository(preferences);
    await RewardUnlockService(repository).reconcile(160);
    final progress = LearningProgressProvider(preferences);

    final first = RewardProgressProvider(
      repository: repository,
      progress: progress,
    );
    await first.refresh();
    expect(first.state.celebratedRewardIds, isEmpty);
    first.dispose();

    final second = RewardProgressProvider(
      repository: RewardRepository(preferences),
      progress: progress,
    );
    await second.refresh();
    expect(second.state.unlockedRewardIds, {'title_first_step'});
    expect(second.state.celebratedRewardIds, isEmpty);
    second.dispose();
  });

  test('획득한 칭호와 테마를 선택하고 기본 상태로 되돌린다', () async {
    final provider = await createProvider(1600);
    final before = provider.state;

    expect(await provider.selectTitle('title_first_step'), isTrue);
    expect(await provider.selectTheme('theme_sky'), isTrue);
    expect(await provider.selectTitle(null), isTrue);
    expect(await provider.selectTheme(null), isTrue);

    expect(provider.state.selectedTitleId, isNull);
    expect(provider.state.selectedThemeId, isNull);
    expect(provider.state.unlockedRewardIds, before.unlockedRewardIds);
    expect(provider.state.celebratedRewardIds, before.celebratedRewardIds);
    expect(provider.currentPoints, 1600);
  });

  test('서로 다른 네 슬롯의 장식을 동시에 착용하고 모두 벗는다', () async {
    final provider = await createProvider(5000);
    for (final id in const [
      'accessory_scarf',
      'accessory_hat',
      'accessory_glasses',
      'accessory_bag',
    ]) {
      expect(await provider.toggleAccessory(id), isTrue);
    }

    expect(provider.selectedAccessoryIds, {
      'accessory_scarf',
      'accessory_hat',
      'accessory_glasses',
      'accessory_bag',
    });
    expect(await provider.clearAccessories(), isTrue);
    expect(provider.selectedAccessoryIds, isEmpty);
  });

  test('잠긴 보상과 미래 ID 선택을 차단하고 기존 상태를 유지한다', () async {
    final provider = await createProvider(100);
    final before = provider.state;

    expect(await provider.selectTheme('theme_sky'), isFalse);
    expect(await provider.toggleAccessory('future_accessory'), isFalse);

    expect(provider.state, before);
    expect(provider.selectionMessage, contains('이전 상태'));
  });

  test('빠른 연속 선택 요청을 순서대로 저장한다', () async {
    final provider = await createProvider(5000);

    final results = await Future.wait([
      provider.selectTitle('title_first_step'),
      provider.selectTitle('title_digital_confidence'),
      provider.selectTheme('theme_sage'),
      provider.selectTheme('theme_peach'),
    ]);

    expect(results, everyElement(isTrue));
    expect(provider.state.selectedTitleId, 'title_digital_confidence');
    expect(provider.state.selectedThemeId, 'theme_peach');
  });
}
