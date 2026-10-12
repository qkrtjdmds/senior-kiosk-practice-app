import 'dart:convert';

import 'data_migration_models.dart';
import 'migration_store.dart';
import 'preference_keys.dart';

abstract interface class DataMigrationRevision {
  int get version;

  String get id;

  Future<MigrationRevisionResult> apply(MigrationStore store);

  bool verify(MigrationStore store);
}

class V3FoundationRevision implements DataMigrationRevision {
  const V3FoundationRevision();

  static const versionValue = 1;
  static const idValue = 'v3_foundation_1';

  @override
  int get version => versionValue;

  @override
  String get id => idValue;

  @override
  Future<MigrationRevisionResult> apply(MigrationStore store) async {
    final recovered = <String>[];

    for (final key in V2PreferenceKeys.nonNegativeIntegerKeys) {
      if (!store.keys.contains(key)) continue;
      final value = store.read(key);
      if (value is! int || value < 0) {
        await store.writeInt(key, 0);
        recovered.add(key);
      }
    }

    for (final key in V2PreferenceKeys.booleanKeys) {
      if (!store.keys.contains(key)) continue;
      if (store.read(key) is! bool) {
        await store.remove(key);
        recovered.add(key);
      }
    }

    await _normalizeEnumString(
      store,
      V2PreferenceKeys.accessibilityTextSize,
      const {'normal', 'large', 'extraLarge'},
      recovered,
    );
    await _normalizeEnumString(store, V2PreferenceKeys.screenContrast, const {
      'comfortable',
      'vivid',
    }, recovered);
    for (final key in V2PreferenceKeys.modeKeys) {
      await _normalizeEnumString(store, key, const {
        'guided',
        'solo',
      }, recovered);
    }

    await _normalizeStringValue(
      store,
      V2PreferenceKeys.hamburgerCurrentMission,
      recovered,
    );
    await _normalizeStringValue(
      store,
      V2PreferenceKeys.hamburgerLastMission,
      recovered,
    );
    await _normalizeStringList(
      store,
      V2PreferenceKeys.dailyMissionRewardTokens,
      recovered,
    );
    await _normalizeRecentRecords(store, recovered);
    await _normalizeDailyMission(store, recovered);

    return MigrationRevisionResult(recoveredKeys: recovered);
  }

  @override
  bool verify(MigrationStore store) {
    for (final key in V2PreferenceKeys.nonNegativeIntegerKeys) {
      if (!store.keys.contains(key)) continue;
      final value = store.read(key);
      if (value is! int || value < 0) return false;
    }
    for (final key in V2PreferenceKeys.booleanKeys) {
      if (store.keys.contains(key) && store.read(key) is! bool) return false;
    }
    if (!_hasAllowedString(
      store,
      V2PreferenceKeys.accessibilityTextSize,
      const {'normal', 'large', 'extraLarge'},
    )) {
      return false;
    }
    if (!_hasAllowedString(store, V2PreferenceKeys.screenContrast, const {
      'comfortable',
      'vivid',
    })) {
      return false;
    }
    for (final key in V2PreferenceKeys.modeKeys) {
      if (!_hasAllowedString(store, key, const {'guided', 'solo'})) {
        return false;
      }
    }
    if (!_isStringWhenPresent(
      store,
      V2PreferenceKeys.hamburgerCurrentMission,
    )) {
      return false;
    }
    if (!_isStringWhenPresent(store, V2PreferenceKeys.hamburgerLastMission)) {
      return false;
    }
    if (!_isStringListWhenPresent(
      store,
      V2PreferenceKeys.dailyMissionRewardTokens,
    )) {
      return false;
    }
    return _recentRecordsAreValid(store) && _dailyMissionIsValid(store);
  }

  Future<void> _normalizeEnumString(
    MigrationStore store,
    String key,
    Set<String> allowed,
    List<String> recovered,
  ) async {
    if (!store.keys.contains(key)) return;
    final value = store.read(key);
    if (value is! String || !allowed.contains(value)) {
      await store.remove(key);
      recovered.add(key);
    }
  }

  Future<void> _normalizeStringValue(
    MigrationStore store,
    String key,
    List<String> recovered,
  ) async {
    if (!store.keys.contains(key)) return;
    if (store.read(key) is! String) {
      await store.remove(key);
      recovered.add(key);
    }
  }

  Future<void> _normalizeStringList(
    MigrationStore store,
    String key,
    List<String> recovered,
  ) async {
    if (!store.keys.contains(key)) return;
    if (_asStringList(store.read(key)) == null) {
      await store.remove(key);
      recovered.add(key);
    }
  }

  Future<void> _normalizeRecentRecords(
    MigrationStore store,
    List<String> recovered,
  ) async {
    final key = V2PreferenceKeys.recentPracticeRecords;
    if (!store.keys.contains(key)) return;
    final records = _asStringList(store.read(key));
    if (records == null) {
      await store.remove(key);
      recovered.add(key);
      return;
    }
    final valid = records.where(_isValidRecentRecord).toList(growable: false);
    if (valid.length != records.length) {
      await store.writeStringList(key, valid);
      recovered.add(key);
    }
  }

  Future<void> _normalizeDailyMission(
    MigrationStore store,
    List<String> recovered,
  ) async {
    final date = store.read(V2PreferenceKeys.dailyMissionDate);
    final selected = _asStringList(
      store.read(V2PreferenceKeys.dailyMissionSelectedIds),
    );
    final hasCurrentState =
        store.keys.contains(V2PreferenceKeys.dailyMissionDate) ||
        store.keys.contains(V2PreferenceKeys.dailyMissionSelectedIds);
    final validCurrentState =
        date is String &&
        _isValidDateKey(date) &&
        selected != null &&
        selected.length == 3 &&
        selected.toSet().length == 3 &&
        selected.every(V2PreferenceKeys.knownDailyMissionIds.contains);

    if (hasCurrentState && !validCurrentState) {
      for (final key in const {
        V2PreferenceKeys.dailyMissionDate,
        V2PreferenceKeys.dailyMissionSelectedIds,
        V2PreferenceKeys.dailyMissionCompletedIds,
        V2PreferenceKeys.dailyMissionRewardedIds,
        V2PreferenceKeys.dailyMissionCompletedAt,
        V2PreferenceKeys.dailyMissionActiveId,
      }) {
        if (store.keys.contains(key)) {
          await store.remove(key);
          recovered.add(key);
        }
      }
    } else if (validCurrentState) {
      final selectedSet = selected.toSet();
      final completed = await _filterMissionIds(
        store,
        V2PreferenceKeys.dailyMissionCompletedIds,
        selectedSet,
        recovered,
      );
      await _filterMissionIds(
        store,
        V2PreferenceKeys.dailyMissionRewardedIds,
        completed,
        recovered,
      );
      await _normalizeCompletedAt(store, completed, recovered);
      final activeKey = V2PreferenceKeys.dailyMissionActiveId;
      if (store.keys.contains(activeKey)) {
        final active = store.read(activeKey);
        if (active is! String ||
            !selectedSet.contains(active) ||
            completed.contains(active)) {
          await store.remove(activeKey);
          recovered.add(activeKey);
        }
      }
    }

    await _filterMissionIds(
      store,
      V2PreferenceKeys.dailyMissionPreviousIds,
      V2PreferenceKeys.knownDailyMissionIds,
      recovered,
      maximumLength: 3,
    );
    await _normalizeFrequency(store, recovered);
  }

  Future<Set<String>> _filterMissionIds(
    MigrationStore store,
    String key,
    Set<String> allowed,
    List<String> recovered, {
    int? maximumLength,
  }) async {
    if (!store.keys.contains(key)) return <String>{};
    final stored = _asStringList(store.read(key));
    if (stored == null) {
      await store.remove(key);
      recovered.add(key);
      return <String>{};
    }
    final filtered = <String>[];
    for (final id in stored) {
      if (allowed.contains(id) && !filtered.contains(id)) {
        filtered.add(id);
      }
      if (maximumLength != null && filtered.length == maximumLength) break;
    }
    if (!_sameList(stored, filtered)) {
      await store.writeStringList(key, filtered);
      recovered.add(key);
    }
    return filtered.toSet();
  }

  Future<void> _normalizeCompletedAt(
    MigrationStore store,
    Set<String> completed,
    List<String> recovered,
  ) async {
    final key = V2PreferenceKeys.dailyMissionCompletedAt;
    if (!store.keys.contains(key)) return;
    final value = store.read(key);
    if (value is! String) {
      await store.remove(key);
      recovered.add(key);
      return;
    }
    try {
      final decoded = jsonDecode(value);
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      final normalized = <String, String>{};
      for (final entry in decoded.entries) {
        final timestamp = entry.value;
        if (completed.contains(entry.key) &&
            timestamp is String &&
            DateTime.tryParse(timestamp) != null) {
          normalized[entry.key] = timestamp;
        }
      }
      final encoded = jsonEncode(normalized);
      if (encoded != value) {
        await store.writeString(key, encoded);
        recovered.add(key);
      }
    } catch (_) {
      await store.remove(key);
      recovered.add(key);
    }
  }

  Future<void> _normalizeFrequency(
    MigrationStore store,
    List<String> recovered,
  ) async {
    final key = V2PreferenceKeys.dailyMissionFrequency;
    if (!store.keys.contains(key)) return;
    final value = store.read(key);
    if (value is! String) {
      await store.remove(key);
      recovered.add(key);
      return;
    }
    try {
      final decoded = jsonDecode(value);
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      final normalized = <String, int>{};
      for (final entry in decoded.entries) {
        final count = entry.value;
        if (V2PreferenceKeys.knownDailyMissionIds.contains(entry.key) &&
            count is int &&
            count >= 0) {
          normalized[entry.key] = count;
        }
      }
      final encoded = jsonEncode(normalized);
      if (encoded != value) {
        await store.writeString(key, encoded);
        recovered.add(key);
      }
    } catch (_) {
      await store.remove(key);
      recovered.add(key);
    }
  }

  bool _recentRecordsAreValid(MigrationStore store) {
    final key = V2PreferenceKeys.recentPracticeRecords;
    if (!store.keys.contains(key)) return true;
    final records = _asStringList(store.read(key));
    return records != null && records.every(_isValidRecentRecord);
  }

  bool _dailyMissionIsValid(MigrationStore store) {
    final dateKey = V2PreferenceKeys.dailyMissionDate;
    final selectedKey = V2PreferenceKeys.dailyMissionSelectedIds;
    if (!store.keys.contains(dateKey) && !store.keys.contains(selectedKey)) {
      return true;
    }
    final date = store.read(dateKey);
    final selected = _asStringList(store.read(selectedKey));
    if (date is! String ||
        !_isValidDateKey(date) ||
        selected == null ||
        selected.length != 3 ||
        selected.toSet().length != 3 ||
        !selected.every(V2PreferenceKeys.knownDailyMissionIds.contains)) {
      return false;
    }
    final completed = _asStringList(
      store.read(V2PreferenceKeys.dailyMissionCompletedIds),
    );
    final rewarded = _asStringList(
      store.read(V2PreferenceKeys.dailyMissionRewardedIds),
    );
    final selectedSet = selected.toSet();
    if (completed != null && !completed.every(selectedSet.contains)) {
      return false;
    }
    final completedSet = completed?.toSet() ?? const <String>{};
    if (rewarded != null && !rewarded.every(completedSet.contains)) {
      return false;
    }
    return true;
  }

  bool _isValidRecentRecord(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return false;
      final learningName = decoded['learningName'];
      final modeName = decoded['modeName'];
      final points = decoded['points'];
      final completedAt = decoded['completedAt'];
      final detail = decoded['detail'];
      return learningName is String &&
          modeName is String &&
          points is int &&
          points >= 0 &&
          completedAt is String &&
          DateTime.tryParse(completedAt) != null &&
          (detail == null || detail is String);
    } catch (_) {
      return false;
    }
  }

  bool _isValidDateKey(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) return false;
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final parsed = DateTime.utc(year, month, day);
    return parsed.year == year && parsed.month == month && parsed.day == day;
  }

  bool _hasAllowedString(
    MigrationStore store,
    String key,
    Set<String> allowed,
  ) {
    if (!store.keys.contains(key)) return true;
    final value = store.read(key);
    return value is String && allowed.contains(value);
  }

  bool _isStringWhenPresent(MigrationStore store, String key) =>
      !store.keys.contains(key) || store.read(key) is String;

  bool _isStringListWhenPresent(MigrationStore store, String key) =>
      !store.keys.contains(key) || _asStringList(store.read(key)) != null;

  List<String>? _asStringList(Object? value) {
    if (value is List<String>) return value;
    if (value is List && value.every((item) => item is String)) {
      return value.cast<String>();
    }
    return null;
  }

  bool _sameList(List<String> left, List<String> right) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }
}
