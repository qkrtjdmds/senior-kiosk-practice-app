import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CafeLearningMode { guided, solo }

class LearningProgressProvider extends ChangeNotifier {
  static const _completionCountKey = 'cafe_learning_completion_count';
  static const _guidedCompletionCountKey = 'cafe_guided_completion_count';
  static const _soloCompletionCountKey = 'cafe_solo_completion_count';
  static const _pointsKey = 'digital_confidence_points';
  static const _soloFirstBadgeKey = 'cafe_solo_first_badge_earned';
  static const _cafeFamiliarBadgeKey = 'cafe_familiar_badge_earned';
  final SharedPreferences _preferences;

  LearningProgressProvider(this._preferences) {
    _syncFamiliarBadge();
  }

  CafeLearningMode? _mode;
  String? _dineOption;
  String? _drink;
  String? _temperature;
  bool _currentCompletionAwarded = false;

  CafeLearningMode? get mode => _mode;
  String? get dineOption => _dineOption;
  String? get drink => _drink;
  String? get temperature => _temperature;
  bool get isSoloMode => _mode == CafeLearningMode.solo;
  int get guidedCompletionCount =>
      _preferences.getInt(_guidedCompletionCountKey) ??
      (_preferences.getInt(_completionCountKey) ?? 0);
  int get soloCompletionCount =>
      _preferences.getInt(_soloCompletionCountKey) ?? 0;
  int get cafeCompletionCount => guidedCompletionCount + soloCompletionCount;
  int get totalPoints =>
      _preferences.getInt(_pointsKey) ?? (guidedCompletionCount * 10);
  bool get soloFirstBadgeEarned =>
      _preferences.getBool(_soloFirstBadgeKey) ?? false;
  bool get cafeFamiliarBadgeEarned =>
      _preferences.getBool(_cafeFamiliarBadgeKey) ?? false;

  void selectMode(CafeLearningMode value) {
    _mode = value;
    _dineOption = null;
    _drink = null;
    _temperature = null;
    _currentCompletionAwarded = false;
    notifyListeners();
  }

  void selectDineOption(String value) {
    _dineOption = value;
    notifyListeners();
  }

  void selectDrink(String value) {
    _drink = value;
    notifyListeners();
  }

  void selectTemperature(String value) {
    _temperature = value;
    notifyListeners();
  }

  Future<bool> completeCafeLearning() async {
    if (_mode == null || _currentCompletionAwarded) {
      return false;
    }

    final shouldAwardBadge =
        _mode == CafeLearningMode.solo && !soloFirstBadgeEarned;
    _currentCompletionAwarded = true;
    await _recordCompletion(_mode!);
    if (shouldAwardBadge) {
      await _preferences.setBool(_soloFirstBadgeKey, true);
    }
    notifyListeners();
    return shouldAwardBadge;
  }

  Future<void> markCafeLearningCompleted() async {
    await _recordCompletion(CafeLearningMode.guided);
    notifyListeners();
  }

  Future<void> _recordCompletion(CafeLearningMode completedMode) async {
    final points =
        totalPoints + (completedMode == CafeLearningMode.solo ? 20 : 10);
    await _preferences.setInt(_pointsKey, points);

    if (completedMode == CafeLearningMode.solo) {
      final completedCount = soloCompletionCount + 1;
      await _preferences.setInt(_soloCompletionCountKey, completedCount);
      if (completedCount >= 3) {
        await _preferences.setBool(_cafeFamiliarBadgeKey, true);
      }
    } else {
      await _preferences.setInt(
        _guidedCompletionCountKey,
        guidedCompletionCount + 1,
      );
    }
  }

  void _syncFamiliarBadge() {
    if (soloCompletionCount >= 3 && !cafeFamiliarBadgeEarned) {
      _preferences.setBool(_cafeFamiliarBadgeKey, true);
    }
  }

  void resetCafeLearning() {
    _dineOption = null;
    _drink = null;
    _temperature = null;
    _currentCompletionAwarded = false;
    notifyListeners();
  }

  void clearCafeMode() {
    _mode = null;
    resetCafeLearning();
  }
}
