import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/data_migration/preference_keys.dart';
import 'reward_catalog.dart';
import 'reward_models.dart';

abstract interface class RewardStore {
  Set<String> get keys;

  Object? read(String key);

  Future<void> writeInt(String key, int value);

  Future<void> writeString(String key, String value);

  Future<void> writeStringList(String key, List<String> value);

  Future<void> remove(String key);
}

class SharedPreferencesRewardStore implements RewardStore {
  SharedPreferencesRewardStore(this.preferences);

  final SharedPreferences preferences;

  @override
  Set<String> get keys => preferences.getKeys();

  @override
  Object? read(String key) => preferences.get(key);

  @override
  Future<void> writeInt(String key, int value) async {
    if (!await preferences.setInt(key, value)) {
      throw StateError('Failed to write a reward integer.');
    }
  }

  @override
  Future<void> writeString(String key, String value) async {
    if (!await preferences.setString(key, value)) {
      throw StateError('Failed to write a reward string.');
    }
  }

  @override
  Future<void> writeStringList(String key, List<String> value) async {
    if (!await preferences.setStringList(key, value)) {
      throw StateError('Failed to write a reward list.');
    }
  }

  @override
  Future<void> remove(String key) async {
    if (!keys.contains(key)) return;
    if (!await preferences.remove(key)) {
      throw StateError('Failed to remove a reward value.');
    }
  }
}

class RewardRepository {
  RewardRepository(SharedPreferences preferences, {RewardCatalog? catalog})
    : this.withStore(
        SharedPreferencesRewardStore(preferences),
        catalog: catalog,
      );

  RewardRepository.withStore(this._store, {RewardCatalog? catalog})
    : catalog = catalog ?? RewardCatalog.v3Initial();

  static const currentDataVersion = 1;
  static const currentMigrationVersion = 2;

  final RewardStore _store;
  final RewardCatalog catalog;

  Future<RewardState> load() async {
    await _recoverPendingState();
    return _readStoredState().normalized(catalog.byId);
  }

  Future<void> save(RewardState state) async {
    if (state.dataVersion > currentDataVersion ||
        state.catalogVersion > catalog.version) {
      throw UnsupportedError('Cannot overwrite a future reward state.');
    }
    final candidate = state
        .normalized(catalog.byId)
        .copyWith(
          dataVersion: currentDataVersion,
          catalogVersion: catalog.version,
        );
    await _saveCandidate(candidate, writePending: true);
  }

  Future<RewardState> selectTitle(String? rewardId) async {
    final state = await load();
    _validateSelection(state, rewardId, RewardType.title);
    final updated = state.copyWith(selectedTitleId: rewardId);
    await _saveSelection(updated, state);
    return updated.copyWith(
      dataVersion: currentDataVersion,
      catalogVersion: catalog.version,
    );
  }

  Future<RewardState> selectAccessories(Set<String> rewardIds) async {
    final state = await load();
    final occupiedSlots = <RewardAccessorySlot>{};
    for (final rewardId in rewardIds) {
      _validateSelection(state, rewardId, RewardType.accessory);
      final slot = rewardAccessorySlot(rewardId);
      if (slot == null || !occupiedSlots.add(slot)) {
        throw StateError('Only one accessory can be selected per slot.');
      }
    }
    final updated = state.copyWith(selectedAccessoryIds: rewardIds);
    await _saveSelection(updated, state);
    return updated.copyWith(
      dataVersion: currentDataVersion,
      catalogVersion: catalog.version,
    );
  }

  Future<RewardState> selectTheme(String? rewardId) async {
    final state = await load();
    _validateSelection(state, rewardId, RewardType.theme);
    final updated = state.copyWith(selectedThemeId: rewardId);
    await _saveSelection(updated, state);
    return updated.copyWith(
      dataVersion: currentDataVersion,
      catalogVersion: catalog.version,
    );
  }

  Future<RewardState> markCelebrated(Iterable<String> rewardIds) async {
    final state = await load();
    final requested = rewardIds.toSet();
    if (!state.unlockedRewardIds.containsAll(requested)) {
      throw StateError('Only unlocked rewards can be marked as celebrated.');
    }
    final updated = state.copyWith(
      celebratedRewardIds: {...state.celebratedRewardIds, ...requested},
    );
    await save(updated);
    return updated.copyWith(
      dataVersion: currentDataVersion,
      catalogVersion: catalog.version,
    );
  }

  Future<void> _saveSelection(RewardState updated, RewardState previous) async {
    try {
      await save(updated);
    } catch (_) {
      try {
        await save(previous);
      } catch (_) {
        // The original write error remains the useful failure for the caller.
      }
      rethrow;
    }
  }

  Future<void> clear() async {
    for (final key in V3RewardKeys.stateKeys) {
      await _store.remove(key);
    }
  }

  void _validateSelection(
    RewardState state,
    String? rewardId,
    RewardType expectedType,
  ) {
    if (rewardId == null) return;
    if (!state.unlockedRewardIds.contains(rewardId)) {
      throw StateError(
        'The reward must be unlocked before it can be selected.',
      );
    }
    final definition = catalog.byId(rewardId);
    if (definition == null ||
        !definition.isActive ||
        definition.rewardType != expectedType) {
      throw ArgumentError.value(
        rewardId,
        'rewardId',
        'does not match ${expectedType.storageValue}',
      );
    }
    if (!definition.rewardType.isSelectable) {
      throw ArgumentError.value(rewardId, 'rewardId', 'is not selectable');
    }
  }

  Future<void> _recoverPendingState() async {
    final pending = _store.read(V3RewardKeys.pendingStateJson);
    if (pending == null) return;
    if (pending is! String) {
      await _store.remove(V3RewardKeys.pendingStateJson);
      return;
    }

    RewardState candidate;
    try {
      candidate = RewardState.fromJsonString(pending);
    } on FormatException {
      await _store.remove(V3RewardKeys.pendingStateJson);
      return;
    } on TypeError {
      await _store.remove(V3RewardKeys.pendingStateJson);
      return;
    }

    if (candidate.dataVersion > currentDataVersion ||
        candidate.catalogVersion > catalog.version) {
      return;
    }
    final normalized = candidate
        .normalized(catalog.byId)
        .copyWith(
          dataVersion: currentDataVersion,
          catalogVersion: catalog.version,
        );
    await _saveCandidate(normalized, writePending: false);
  }

  Future<void> _saveCandidate(
    RewardState candidate, {
    required bool writePending,
  }) async {
    final serialized = candidate.toJsonString();
    if (writePending) {
      await _store.writeString(V3RewardKeys.pendingStateJson, serialized);
      final pending = _store.read(V3RewardKeys.pendingStateJson);
      if (pending != serialized) {
        throw StateError('Reward pending state verification failed.');
      }
    }

    final unlocked = candidate.unlockedRewardIds.toList()..sort();
    final celebrated = candidate.celebratedRewardIds.toList()..sort();
    final accessories = candidate.selectedAccessoryIds.toList()..sort();
    final timestamps = <String, String>{
      for (final entry in candidate.unlockedAtByRewardId.entries)
        entry.key: entry.value.toUtc().toIso8601String(),
    };

    await _store.writeStringList(V3RewardKeys.unlockedIds, unlocked);
    await _store.writeString(
      V3RewardKeys.unlockedAtJson,
      jsonEncode(timestamps),
    );
    await _store.writeStringList(V3RewardKeys.celebratedIds, celebrated);
    await _writeOptionalString(
      V3RewardKeys.selectedTitleId,
      candidate.selectedTitleId,
    );
    await _store.writeStringList(
      V3RewardKeys.selectedAccessoryIds,
      accessories,
    );
    await _writeOptionalString(
      V3RewardKeys.selectedThemeId,
      candidate.selectedThemeId,
    );
    if (candidate.retroactiveGrantCompleted) {
      await _store.writeInt(
        V3RewardKeys.retroactiveGrantVersion,
        candidate.catalogVersion,
      );
    } else {
      await _store.remove(V3RewardKeys.retroactiveGrantVersion);
    }
    await _store.writeInt(
      V3RewardKeys.catalogVersion,
      candidate.catalogVersion,
    );
    await _store.writeInt(V3RewardKeys.dataVersion, candidate.dataVersion);
    await _store.writeInt(
      V3RewardKeys.migrationVersion,
      currentMigrationVersion,
    );

    final verified = _readStoredState().normalized(catalog.byId);
    if (verified != candidate) {
      throw StateError('Reward state verification failed.');
    }
    await _store.remove(V3RewardKeys.pendingStateJson);
  }

  Future<void> _writeOptionalString(String key, String? value) async {
    if (value == null) {
      await _store.remove(key);
    } else {
      await _store.writeString(key, value);
    }
  }

  RewardState _readStoredState() {
    Set<String> readStringSet(String key) {
      final raw = _store.read(key);
      if (raw is! List) return <String>{};
      return raw
          .whereType<String>()
          .where((id) => id.trim().isNotEmpty)
          .toSet();
    }

    int readNonNegativeInt(String key) {
      final raw = _store.read(key);
      return raw is int && raw >= 0 ? raw : 0;
    }

    String? readOptionalString(String key) {
      final raw = _store.read(key);
      return raw is String && raw.trim().isNotEmpty ? raw : null;
    }

    final timestamps = <String, DateTime>{};
    final rawTimestamps = _store.read(V3RewardKeys.unlockedAtJson);
    if (rawTimestamps is String) {
      try {
        final decoded = jsonDecode(rawTimestamps);
        if (decoded is Map) {
          for (final entry in decoded.entries) {
            if (entry.key is! String || entry.value is! String) continue;
            final parsed = DateTime.tryParse(entry.value as String);
            if (parsed != null) {
              timestamps[entry.key as String] = parsed.toUtc();
            }
          }
        }
      } on FormatException {
        // A malformed timestamp map does not invalidate the unlocked IDs.
      }
    }

    final catalogVersion = readNonNegativeInt(V3RewardKeys.catalogVersion);
    final retroactiveVersion = readNonNegativeInt(
      V3RewardKeys.retroactiveGrantVersion,
    );
    return RewardState(
      unlockedRewardIds: readStringSet(V3RewardKeys.unlockedIds),
      unlockedAtByRewardId: timestamps,
      celebratedRewardIds: readStringSet(V3RewardKeys.celebratedIds),
      selectedTitleId: readOptionalString(V3RewardKeys.selectedTitleId),
      selectedAccessoryIds: readStringSet(V3RewardKeys.selectedAccessoryIds),
      selectedThemeId: readOptionalString(V3RewardKeys.selectedThemeId),
      retroactiveGrantCompleted:
          retroactiveVersion > 0 && retroactiveVersion <= catalogVersion,
      dataVersion: readNonNegativeInt(V3RewardKeys.dataVersion),
      catalogVersion: catalogVersion,
    );
  }
}
