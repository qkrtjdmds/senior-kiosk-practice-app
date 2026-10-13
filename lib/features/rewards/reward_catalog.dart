import 'reward_models.dart';

class RewardCatalog {
  factory RewardCatalog(
    Iterable<RewardDefinition> definitions, {
    int version = 1,
  }) {
    if (version < 1) {
      throw ArgumentError.value(version, 'version', 'must be positive');
    }
    final validated = _validatedDefinitions(definitions);
    return RewardCatalog._(
      validated,
      Map.unmodifiable({
        for (final reward in validated) reward.rewardId: reward,
      }),
      version,
    );
  }

  const RewardCatalog._(this._definitions, this._byId, this.version);

  factory RewardCatalog.v3Initial() => RewardCatalog(_v3InitialRewards);

  final int version;
  final List<RewardDefinition> _definitions;
  final Map<String, RewardDefinition> _byId;

  List<RewardDefinition> get definitions => _definitions;

  RewardDefinition? byId(String rewardId) => _byId[rewardId];

  List<RewardDefinition> byType(
    RewardType type, {
    bool includeInactive = false,
  }) {
    return List.unmodifiable(
      _definitions.where(
        (reward) =>
            reward.rewardType == type && (includeInactive || reward.isActive),
      ),
    );
  }

  List<RewardDefinition> availableAt(
    int points, {
    bool includeInactive = false,
  }) {
    return List.unmodifiable(
      _definitions.where(
        (reward) =>
            reward.requiredPoints <= points &&
            (includeInactive || reward.isActive),
      ),
    );
  }

  int? nextRequiredPointsAfter(int points, {bool includeInactive = false}) {
    for (final reward in _definitions) {
      if (reward.requiredPoints > points &&
          (includeInactive || reward.isActive)) {
        return reward.requiredPoints;
      }
    }
    return null;
  }

  List<RewardDefinition> rewardsAtNextThreshold(
    int points, {
    bool includeInactive = false,
  }) {
    final next = nextRequiredPointsAfter(
      points,
      includeInactive: includeInactive,
    );
    if (next == null) return const [];
    return List.unmodifiable(
      _definitions.where(
        (reward) =>
            reward.requiredPoints == next &&
            (includeInactive || reward.isActive),
      ),
    );
  }

  static List<RewardDefinition> _validatedDefinitions(
    Iterable<RewardDefinition> source,
  ) {
    final definitions = source.toList(growable: false);
    final ids = <String>{};
    final sortOrders = <int>{};
    for (final reward in definitions) {
      if (!ids.add(reward.rewardId)) {
        throw ArgumentError('Duplicate reward ID: ${reward.rewardId}');
      }
      if (!sortOrders.add(reward.sortOrder)) {
        throw ArgumentError('Duplicate reward sortOrder: ${reward.sortOrder}');
      }
      if (reward.rewardType == RewardType.unknown) {
        throw ArgumentError(
          'Catalog reward ${reward.rewardId} has an unsupported type.',
        );
      }
    }
    definitions.sort((left, right) {
      final points = left.requiredPoints.compareTo(right.requiredPoints);
      return points != 0 ? points : left.sortOrder.compareTo(right.sortOrder);
    });
    return List.unmodifiable(definitions);
  }
}

final List<RewardDefinition> _v3InitialRewards = [
  RewardDefinition(
    rewardId: 'title_first_step',
    rewardType: RewardType.title,
    title: '첫걸음 시작',
    description: '첫 연습 목표를 차근차근 이어가고 있어요.',
    requiredPoints: 100,
    assetKey: 'title.first_step',
    sortOrder: 100,
  ),
  RewardDefinition(
    rewardId: 'accessory_scarf',
    rewardType: RewardType.accessory,
    title: '한걸음이 목도리',
    description: '한걸음이에게 포근한 목도리를 둘러 주세요.',
    requiredPoints: 300,
    assetKey: 'character.accessory.scarf',
    sortOrder: 300,
  ),
  RewardDefinition(
    rewardId: 'theme_sage',
    rewardType: RewardType.theme,
    title: '편안한 세이지',
    description: '홈을 차분한 세이지색으로 꾸며요.',
    requiredPoints: 500,
    assetKey: 'home.theme.sage',
    sortOrder: 500,
  ),
  RewardDefinition(
    rewardId: 'title_steady_learner',
    rewardType: RewardType.title,
    title: '꾸준한 연습생',
    description: '꾸준히 연습한 걸음을 기념하는 칭호예요.',
    requiredPoints: 800,
    assetKey: 'title.steady_learner',
    sortOrder: 800,
  ),
  RewardDefinition(
    rewardId: 'accessory_hat',
    rewardType: RewardType.accessory,
    title: '한걸음이 모자',
    description: '한걸음이에게 산뜻한 모자를 씌워 주세요.',
    requiredPoints: 1200,
    assetKey: 'character.accessory.hat',
    sortOrder: 1200,
  ),
  RewardDefinition(
    rewardId: 'theme_sky',
    rewardType: RewardType.theme,
    title: '맑은 하늘',
    description: '홈을 편안한 하늘색으로 꾸며요.',
    requiredPoints: 1600,
    assetKey: 'home.theme.sky',
    sortOrder: 1600,
  ),
  RewardDefinition(
    rewardId: 'accessory_glasses',
    rewardType: RewardType.accessory,
    title: '한걸음이 안경',
    description: '한걸음이에게 단정한 안경을 씌워 주세요.',
    requiredPoints: 1600,
    assetKey: 'character.accessory.glasses',
    sortOrder: 1601,
  ),
  RewardDefinition(
    rewardId: 'title_digital_confidence',
    rewardType: RewardType.title,
    title: '디지털 자신감',
    description: '쌓아 온 디지털 연습을 기념하는 칭호예요.',
    requiredPoints: 2000,
    assetKey: 'title.digital_confidence',
    sortOrder: 2000,
  ),
  RewardDefinition(
    rewardId: 'theme_peach',
    rewardType: RewardType.theme,
    title: '따뜻한 복숭아',
    description: '홈을 따뜻한 복숭아색으로 꾸며요.',
    requiredPoints: 3000,
    assetKey: 'home.theme.peach',
    sortOrder: 3000,
  ),
  RewardDefinition(
    rewardId: 'accessory_bag',
    rewardType: RewardType.accessory,
    title: '한걸음이 가방',
    description: '한걸음이에게 작은 가방을 메어 주세요.',
    requiredPoints: 3000,
    assetKey: 'character.accessory.bag',
    sortOrder: 3001,
  ),
  RewardDefinition(
    rewardId: 'title_hangeoreum_master',
    rewardType: RewardType.title,
    title: '한걸음 달인',
    description: '오랫동안 이어 온 연습을 기념하는 칭호예요.',
    requiredPoints: 5000,
    assetKey: 'title.hangeoreum_master',
    sortOrder: 5000,
  ),
  RewardDefinition(
    rewardId: 'expression_celebration',
    rewardType: RewardType.expression,
    title: '특별 축하 표정',
    description: '큰 성장을 축하할 때 만나는 한걸음이 표정이에요.',
    requiredPoints: 5000,
    assetKey: 'character.expression.celebration',
    sortOrder: 5001,
  ),
];
