import 'package:flutter_test/flutter_test.dart';

import 'package:han_geoleum_digital/features/rewards/reward_catalog.dart';
import 'package:han_geoleum_digital/features/rewards/reward_models.dart';

void main() {
  group('RewardType', () {
    test('안정 문자열과 선택 가능 여부를 제공한다', () {
      expect(RewardType.fromStorageValue('title'), RewardType.title);
      expect(RewardType.fromStorageValue('accessory'), RewardType.accessory);
      expect(RewardType.fromStorageValue('theme'), RewardType.theme);
      expect(RewardType.fromStorageValue('expression'), RewardType.expression);
      expect(RewardType.fromStorageValue('future_type'), RewardType.unknown);
      expect(RewardType.title.isSelectable, isTrue);
      expect(RewardType.expression.isSelectable, isFalse);
    });
  });

  group('RewardCatalog', () {
    final catalog = RewardCatalog.v3Initial();

    test('정확히 12개 안정 ID와 기준을 순서대로 제공한다', () {
      expect(catalog.definitions, hasLength(12));
      expect(catalog.definitions.map((reward) => reward.rewardId), [
        'title_first_step',
        'accessory_scarf',
        'theme_sage',
        'title_steady_learner',
        'accessory_hat',
        'theme_sky',
        'accessory_glasses',
        'title_digital_confidence',
        'theme_peach',
        'accessory_bag',
        'title_hangeoreum_master',
        'expression_celebration',
      ]);
      expect(catalog.definitions.map((reward) => reward.requiredPoints), [
        100,
        300,
        500,
        800,
        1200,
        1600,
        1600,
        2000,
        3000,
        3000,
        5000,
        5000,
      ]);
      expect(
        catalog.definitions.map((reward) => reward.rewardId).toSet(),
        hasLength(12),
      );
      expect(
        catalog.definitions.map((reward) => reward.sortOrder).toSet(),
        hasLength(12),
      );
    });

    test('ID·종류·포인트와 다음 기준으로 조회한다', () {
      expect(catalog.byId('accessory_hat')?.title, '한걸음이 모자');
      expect(catalog.byId('missing'), isNull);
      expect(catalog.byType(RewardType.title), hasLength(4));
      expect(catalog.byType(RewardType.accessory), hasLength(4));
      expect(catalog.availableAt(99), isEmpty);
      expect(catalog.availableAt(160), hasLength(1));
      expect(catalog.availableAt(1600), hasLength(7));
      expect(catalog.nextRequiredPointsAfter(1599), 1600);
      expect(
        catalog.rewardsAtNextThreshold(1599).map((reward) => reward.rewardId),
        ['theme_sky', 'accessory_glasses'],
      );
      expect(catalog.nextRequiredPointsAfter(5000), isNull);
      expect(catalog.rewardsAtNextThreshold(5000), isEmpty);
    });

    test('비활성 보상은 기본 조회에서 제외하고 명시하면 포함한다', () {
      final inactive = definition(
        id: 'future_inactive',
        type: RewardType.title,
        points: 10,
        sortOrder: 10,
        isActive: false,
      );
      final custom = RewardCatalog([inactive]);

      expect(custom.availableAt(100), isEmpty);
      expect(custom.byType(RewardType.title), isEmpty);
      expect(custom.availableAt(100, includeInactive: true), [inactive]);
      expect(custom.byType(RewardType.title, includeInactive: true), [
        inactive,
      ]);
    });

    test('외부에서 목록을 수정할 수 없고 중복 ID·정렬값을 거부한다', () {
      expect(
        () => catalog.definitions.add(catalog.definitions.first),
        throwsUnsupportedError,
      );
      expect(
        () => RewardCatalog([
          definition(id: 'same', sortOrder: 1),
          definition(id: 'same', sortOrder: 2),
        ]),
        throwsArgumentError,
      );
      expect(
        () => RewardCatalog([
          definition(id: 'one', sortOrder: 1),
          definition(id: 'two', sortOrder: 1),
        ]),
        throwsArgumentError,
      );
    });
  });

  group('RewardDefinition과 RewardState', () {
    final catalog = RewardCatalog.v3Initial();

    test('정의 모델은 직렬화 왕복과 동등성을 지원한다', () {
      final original = catalog.definitions.first;
      expect(RewardDefinition.fromJson(original.toJson()), original);
      expect(
        RewardDefinition.fromJson({
          ...original.toJson(),
          'rewardId': 'future_reward',
          'rewardType': 'future_type',
        }).rewardType,
        RewardType.unknown,
      );
    });

    test('빈 상태와 null 기본 선택을 제공한다', () {
      final empty = RewardState.empty();
      expect(empty.unlockedRewardIds, isEmpty);
      expect(empty.selectedTitleId, isNull);
      expect(empty.selectedAccessoryIds, isEmpty);
      expect(empty.selectedThemeId, isNull);
      expect(empty.retroactiveGrantCompleted, isFalse);
    });

    test('중복 ID를 정규화하고 미래 ID와 획득 시각을 보존한다', () {
      final state = RewardState.fromJson({
        'unlockedRewardIds': [
          'title_first_step',
          'title_first_step',
          'future_reward',
        ],
        'unlockedAtByRewardId': {
          'title_first_step': '2026-10-13T01:00:00.000Z',
          'future_reward': '2026-10-13T02:00:00.000Z',
          'broken_date': 'not-a-date',
        },
        'celebratedRewardIds': ['title_first_step', 'not_unlocked'],
        'selectedTitleId': 'title_first_step',
        'selectedAccessoryIds': ['title_first_step'],
        'selectedThemeId': 'future_reward',
        'retroactiveGrantCompleted': true,
        'dataVersion': -1,
        'catalogVersion': -2,
      }).normalized(catalog.byId);

      expect(state.unlockedRewardIds, {'title_first_step', 'future_reward'});
      expect(state.unlockedAtByRewardId, hasLength(2));
      expect(state.celebratedRewardIds, {'title_first_step'});
      expect(state.selectedTitleId, 'title_first_step');
      expect(state.selectedAccessoryIds, isEmpty);
      expect(state.selectedThemeId, isNull);
      expect(state.dataVersion, 0);
      expect(state.catalogVersion, 0);
    });

    test('상태 모델은 JSON 왕복과 값 동등성을 지원한다', () {
      final original = RewardState(
        unlockedRewardIds: {'title_first_step', 'future_reward'},
        unlockedAtByRewardId: {'title_first_step': DateTime.utc(2026, 10, 13)},
        celebratedRewardIds: {'title_first_step'},
        selectedTitleId: 'title_first_step',
        retroactiveGrantCompleted: true,
        dataVersion: 1,
        catalogVersion: 1,
      );
      final restored = RewardState.fromJsonString(original.toJsonString());
      expect(restored, original);
      expect(restored.hashCode, original.hashCode);
    });
  });
}

RewardDefinition definition({
  required String id,
  RewardType type = RewardType.title,
  int points = 0,
  required int sortOrder,
  bool isActive = true,
}) {
  return RewardDefinition(
    rewardId: id,
    rewardType: type,
    title: id,
    description: id,
    requiredPoints: points,
    assetKey: id,
    sortOrder: sortOrder,
    isActive: isActive,
  );
}
