import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../learning/learning_progress_provider.dart';
import 'daily_mission.dart';

typedef MissionClock = DateTime Function();

class DailyMissionProvider extends ChangeNotifier {
  DailyMissionProvider(
    this._preferences,
    this._progress, {
    MissionClock? clock,
    Random? random,
  }) : _clock = clock ?? DateTime.now,
       _random = random {
    _progress.registerPracticeResetHandler(resetMissionRecords);
    _progress.registerPracticeStartHandler(cancelActiveMission);
    _loadOrCreateForToday();
  }

  static const dateKey = 'daily_mission_date';
  static const selectedIdsKey = 'daily_mission_selected_ids';
  static const completedIdsKey = 'daily_mission_completed_ids';
  static const rewardedIdsKey = 'daily_mission_rewarded_ids';
  static const completedAtKey = 'daily_mission_completed_at';
  static const previousIdsKey = 'daily_mission_previous_ids';
  static const frequencyKey = 'daily_mission_frequency';
  static const activeMissionIdKey = 'daily_mission_active_id';
  static const preferenceKeys = <String>[
    dateKey,
    selectedIdsKey,
    completedIdsKey,
    rewardedIdsKey,
    completedAtKey,
    previousIdsKey,
    frequencyKey,
    activeMissionIdKey,
  ];

  final SharedPreferences _preferences;
  final LearningProgressProvider _progress;
  final MissionClock _clock;
  final Random? _random;
  late String _todayKey;
  List<MissionDefinition> _definitions = const [];
  Set<String> _completedIds = {};
  Set<String> _rewardedIds = {};
  Map<String, DateTime> _completedAt = {};
  String? _activeMissionId;
  String? _inlineMessage;
  final Set<String> _completingMissionIds = {};

  String get todayKey {
    _refreshDateIfNeeded();
    return _todayKey;
  }

  List<DailyMission> get missions {
    _refreshDateIfNeeded();
    return _definitions
        .map(
          (definition) => DailyMission(
            definition: definition,
            dateKey: _todayKey,
            isCompleted: _completedIds.contains(definition.id),
            isRewarded: _rewardedIds.contains(definition.id),
            completedAt: _completedAt[definition.id],
          ),
        )
        .toList(growable: false);
  }

  int get completedCount => missions.where((item) => item.isCompleted).length;
  double get progress => completedCount / 3;
  bool get allCompleted => completedCount == 3;
  String? get activeMissionId => _activeMissionId;
  String? get inlineMessage => _inlineMessage;

  String get koreanDateLabel {
    final parts = todayKey.split('-');
    return '${int.parse(parts[1])}월 ${int.parse(parts[2])}일';
  }

  void startMission(String missionId) {
    _refreshDateIfNeeded();
    if (!_definitions.any((item) => item.id == missionId)) return;
    _activeMissionId = missionId;
    _inlineMessage = null;
    _preferences.setString(activeMissionIdKey, missionId);
    notifyListeners();
  }

  void cancelActiveMission() {
    if (_activeMissionId == null) return;
    _activeMissionId = null;
    _inlineMessage = null;
    _preferences.remove(activeMissionIdKey);
    notifyListeners();
  }

  Future<bool> completeActiveMission(MissionContentType contentType) async {
    _refreshDateIfNeeded();
    final activeId = _activeMissionId;
    if (activeId == null) return false;
    final definition = DailyMissionCatalog.byId(activeId);
    if (definition == null ||
        definition.contentType != contentType ||
        !_definitions.any((item) => item.id == activeId)) {
      return false;
    }
    if (_completedIds.contains(activeId)) {
      _inlineMessage = '이미 완료한 미션이에요. 추가 포인트는 한 번만 받을 수 있어요.';
      notifyListeners();
      return false;
    }
    if (!_completingMissionIds.add(activeId)) return false;
    final token = '$_todayKey:$activeId';
    try {
      final awarded = await _progress.awardDailyMissionBonus(token);
      _completedIds.add(activeId);
      if (awarded || _progress.hasDailyMissionReward(token)) {
        _rewardedIds.add(activeId);
      }
      _completedAt[activeId] = _clock();
      _activeMissionId = null;
      _inlineMessage = awarded
          ? '오늘의 미션을 완료해 추가 포인트 10점을 받았어요.'
          : '오늘의 미션 완료가 저장되어 있어요.';
      await _persist();
      notifyListeners();
      return awarded;
    } finally {
      _completingMissionIds.remove(activeId);
    }
  }

  Future<void> resetMissionRecords() async {
    for (final key in preferenceKeys) {
      await _preferences.remove(key);
    }
    _definitions = const [];
    _completedIds.clear();
    _rewardedIds.clear();
    _completedAt.clear();
    _activeMissionId = null;
    _inlineMessage = null;
    _completingMissionIds.clear();
    _loadOrCreateForToday();
    notifyListeners();
  }

  void _refreshDateIfNeeded() {
    if (_koreanDateKey(_clock()) != _todayKey) {
      _loadOrCreateForToday();
      notifyListeners();
    }
  }

  void _loadOrCreateForToday() {
    _todayKey = _koreanDateKey(_clock());
    final storedDate = _preferences.getString(dateKey);
    final storedIds = _preferences.getStringList(selectedIdsKey);
    final valid =
        storedDate == _todayKey &&
        storedIds != null &&
        storedIds.length == 3 &&
        storedIds.toSet().length == 3 &&
        storedIds.every((id) => DailyMissionCatalog.byId(id) != null);
    if (valid) {
      _definitions = storedIds
          .map((id) => DailyMissionCatalog.byId(id)!)
          .toList();
    } else {
      _definitions = _selectMissions(_todayKey);
      _preferences.setString(dateKey, _todayKey);
      _preferences.setStringList(
        selectedIdsKey,
        _definitions.map((item) => item.id).toList(),
      );
    }
    final validIds = _definitions.map((item) => item.id).toSet();
    _completedIds = storedDate == _todayKey
        ? (_preferences.getStringList(completedIdsKey) ?? [])
              .where(validIds.contains)
              .toSet()
        : {};
    _rewardedIds = storedDate == _todayKey
        ? (_preferences.getStringList(rewardedIdsKey) ?? [])
              .where(validIds.contains)
              .toSet()
        : {};
    _completedAt = storedDate == _todayKey ? _readCompletedAt() : {};
    final active = _preferences.getString(activeMissionIdKey);
    _activeMissionId =
        storedDate == _todayKey &&
            active != null &&
            validIds.contains(active) &&
            !_completedIds.contains(active)
        ? active
        : null;
    _inlineMessage = null;
    _persist();
  }

  List<MissionDefinition> _selectMissions(String day) {
    final previous = _preferences.getStringList(previousIdsKey) ?? [];
    final frequencies = _readFrequencies();
    final random = _random ?? Random(_stableSeed(day));
    final candidates = [...DailyMissionCatalog.definitions];
    candidates.shuffle(random);
    candidates.sort((a, b) {
      final aScore =
          (frequencies[a.id] ?? 0) * 10 + (previous.contains(a.id) ? 4 : 0);
      final bScore =
          (frequencies[b.id] ?? 0) * 10 + (previous.contains(b.id) ? 4 : 0);
      return aScore.compareTo(bScore);
    });
    final selected = candidates.take(3).toList();
    if (previous.length == 3 &&
        selected.map((item) => item.id).toSet().containsAll(previous)) {
      selected[2] = candidates.firstWhere(
        (item) => !previous.contains(item.id),
      );
    }
    for (final item in selected) {
      frequencies[item.id] = (frequencies[item.id] ?? 0) + 1;
    }
    _preferences.setStringList(
      previousIdsKey,
      selected.map((item) => item.id).toList(),
    );
    _preferences.setString(frequencyKey, jsonEncode(frequencies));
    return selected;
  }

  Map<String, int> _readFrequencies() {
    try {
      final raw = _preferences.getString(frequencyKey);
      if (raw == null) return {};
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value as int));
    } catch (_) {
      return {};
    }
  }

  Map<String, DateTime> _readCompletedAt() {
    try {
      final raw = _preferences.getString(completedAtKey);
      if (raw == null) return {};
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(key, DateTime.parse(value as String)),
      )..removeWhere((key, _) => !_completedIds.contains(key));
    } catch (_) {
      return {};
    }
  }

  Future<void> _persist() async {
    await _preferences.setString(dateKey, _todayKey);
    await _preferences.setStringList(
      selectedIdsKey,
      _definitions.map((item) => item.id).toList(),
    );
    await _preferences.setStringList(completedIdsKey, _completedIds.toList());
    await _preferences.setStringList(rewardedIdsKey, _rewardedIds.toList());
    await _preferences.setString(
      completedAtKey,
      jsonEncode(
        _completedAt.map(
          (key, value) => MapEntry(key, value.toIso8601String()),
        ),
      ),
    );
    if (_activeMissionId == null) {
      await _preferences.remove(activeMissionIdKey);
    } else {
      await _preferences.setString(activeMissionIdKey, _activeMissionId!);
    }
  }

  static String _koreanDateKey(DateTime value) {
    final korea = value.toUtc().add(const Duration(hours: 9));
    String two(int number) => number.toString().padLeft(2, '0');
    return '${korea.year}-${two(korea.month)}-${two(korea.day)}';
  }

  static int _stableSeed(String value) {
    var hash = 17;
    for (final unit in value.codeUnits) {
      hash = 37 * hash + unit;
    }
    return hash;
  }

  @override
  void dispose() {
    _progress.unregisterPracticeResetHandler(resetMissionRecords);
    _progress.unregisterPracticeStartHandler(cancelActiveMission);
    super.dispose();
  }
}
