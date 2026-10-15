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
}
