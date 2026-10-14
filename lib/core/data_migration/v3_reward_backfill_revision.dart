import '../../features/rewards/reward_repository.dart';
import '../../features/rewards/reward_unlock_service.dart';
import 'data_migration_models.dart';
import 'migration_store.dart';
import 'preference_keys.dart';
import 'v3_foundation_revision.dart';

class V3RewardBackfillRevision implements DataMigrationRevision {
  V3RewardBackfillRevision({RewardClock? clock}) : _clock = clock;

  static const versionValue = 2;
  static const idValue = 'v3_reward_backfill_2';

  final RewardClock? _clock;

  @override
  int get version => versionValue;

  @override
  String get id => idValue;

  @override
  Future<MigrationRevisionResult> apply(MigrationStore store) async {
    final rawPoints = store.read(V2PreferenceKeys.points);
    final points = rawPoints is int && rawPoints >= 0 ? rawPoints : 0;
    final repository = RewardRepository.withStore(_MigrationRewardStore(store));
    final result = await RewardUnlockService(
      repository,
      clock: _clock,
    ).reconcile(points, markRetroactiveGrantCompleted: true);
    if (!result.succeeded) {
      throw StateError('Reward backfill failed: ${result.status.name}');
    }
    return const MigrationRevisionResult();
  }

  @override
  bool verify(MigrationStore store) {
    final rawPoints = store.read(V2PreferenceKeys.points);
    final points = rawPoints is int && rawPoints >= 0 ? rawPoints : 0;
    final unlocked = _stringSet(store.read(V3RewardKeys.unlockedIds));
    final expected = RewardRepository.withStore(
      _MigrationRewardStore(store),
    ).catalog.availableAt(points).map((reward) => reward.rewardId).toSet();
    final retroactiveVersion = store.read(V3RewardKeys.retroactiveGrantVersion);
    return unlocked.containsAll(expected) &&
        retroactiveVersion is int &&
        retroactiveVersion > 0;
  }

  Set<String> _stringSet(Object? raw) {
    if (raw is! List) return <String>{};
    return raw.whereType<String>().toSet();
  }
}

class _MigrationRewardStore implements RewardStore {
  _MigrationRewardStore(this._store);

  final MigrationStore _store;

  @override
  Set<String> get keys => _store.keys;

  @override
  Object? read(String key) => _store.read(key);

  @override
  Future<void> remove(String key) => _store.remove(key);

  @override
  Future<void> writeInt(String key, int value) => _store.writeInt(key, value);

  @override
  Future<void> writeString(String key, String value) =>
      _store.writeString(key, value);

  @override
  Future<void> writeStringList(String key, List<String> value) =>
      _store.writeStringList(key, value);
}
