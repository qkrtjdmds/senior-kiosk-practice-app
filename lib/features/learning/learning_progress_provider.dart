import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../progress/recent_practice_record.dart';

enum CafeLearningMode { guided, solo }

enum TrainLearningMode { guided, solo }

enum HospitalLearningMode { guided, solo }

enum PhotoLearningMode { guided, solo }

class LearningProgressProvider extends ChangeNotifier {
  static const _completionCountKey = 'cafe_learning_completion_count';
  static const _guidedCompletionCountKey = 'cafe_guided_completion_count';
  static const _soloCompletionCountKey = 'cafe_solo_completion_count';
  static const _pointsKey = 'digital_confidence_points';
  static const _soloFirstBadgeKey = 'cafe_solo_first_badge_earned';
  static const _cafeFamiliarBadgeKey = 'cafe_familiar_badge_earned';
  static const _hospitalCompletionCountKey = 'hospital_guided_completion_count';
  static const _hospitalSoloCompletionCountKey =
      'hospital_solo_completion_count';
  static const _hospitalSoloFirstBadgeKey = 'hospital_solo_first_badge_earned';
  static const _photoCompletionCountKey = 'photo_guided_completion_count';
  static const _photoSoloCompletionCountKey = 'photo_solo_completion_count';
  static const _photoSoloFirstBadgeKey = 'photo_solo_first_badge_earned';
  static const _trainCompletionCountKey = 'train_guided_completion_count';
  static const _trainSoloCompletionCountKey = 'train_solo_completion_count';
  static const _trainSoloFirstBadgeKey = 'train_solo_first_badge_earned';
  static const _recentPracticeRecordsKey = 'recent_practice_records';
  final SharedPreferences _preferences;

  LearningProgressProvider(this._preferences) {
    _syncFamiliarBadge();
  }

  CafeLearningMode? _mode;
  String? _dineOption;
  String? _drink;
  String? _temperature;
  bool _currentCompletionAwarded = false;
  String? _hospitalVisitPurpose;
  String? _hospitalRegistrationMethod;
  String? _hospitalDepartment;
  bool _hospitalCompletionAwarded = false;
  HospitalLearningMode? _hospitalMode;
  bool _hospitalSoloCompletionAwarded = false;
  String? _photoRecipient;
  String? _photoSelection;
  String? _photoMessage;
  bool _photoCompletionAwarded = false;
  PhotoLearningMode? _photoMode;
  bool _photoSoloCompletionAwarded = false;
  String? _trainDepartureStation;
  String? _trainArrivalStation;
  String? _trainDepartureTime;
  String? _trainSeat;
  bool _trainCompletionAwarded = false;
  TrainLearningMode? _trainMode;
  bool _trainSoloCompletionAwarded = false;

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
  String? get hospitalVisitPurpose => _hospitalVisitPurpose;
  String? get hospitalRegistrationMethod => _hospitalRegistrationMethod;
  String? get hospitalDepartment => _hospitalDepartment;
  int get hospitalCompletionCount =>
      _preferences.getInt(_hospitalCompletionCountKey) ?? 0;
  HospitalLearningMode? get hospitalMode => _hospitalMode;
  bool get isHospitalSoloMode => _hospitalMode == HospitalLearningMode.solo;
  int get hospitalSoloCompletionCount =>
      _preferences.getInt(_hospitalSoloCompletionCountKey) ?? 0;
  bool get hospitalSoloFirstBadgeEarned =>
      _preferences.getBool(_hospitalSoloFirstBadgeKey) ?? false;
  String? get photoRecipient => _photoRecipient;
  String? get photoSelection => _photoSelection;
  String? get photoMessage => _photoMessage;
  int get photoCompletionCount =>
      _preferences.getInt(_photoCompletionCountKey) ?? 0;
  PhotoLearningMode? get photoMode => _photoMode;
  bool get isPhotoSoloMode => _photoMode == PhotoLearningMode.solo;
  int get photoSoloCompletionCount =>
      _preferences.getInt(_photoSoloCompletionCountKey) ?? 0;
  bool get photoSoloFirstBadgeEarned =>
      _preferences.getBool(_photoSoloFirstBadgeKey) ?? false;
  String? get trainDepartureStation => _trainDepartureStation;
  String? get trainArrivalStation => _trainArrivalStation;
  String? get trainDepartureTime => _trainDepartureTime;
  String? get trainSeat => _trainSeat;
  int get trainCompletionCount =>
      _preferences.getInt(_trainCompletionCountKey) ?? 0;
  TrainLearningMode? get trainMode => _trainMode;
  bool get isTrainSoloMode => _trainMode == TrainLearningMode.solo;
  int get trainSoloCompletionCount =>
      _preferences.getInt(_trainSoloCompletionCountKey) ?? 0;
  bool get trainSoloFirstBadgeEarned =>
      _preferences.getBool(_trainSoloFirstBadgeKey) ?? false;
  List<RecentPracticeRecord> get recentPracticeRecords {
    final raw = _preferences.getStringList(_recentPracticeRecordsKey) ?? [];
    return raw
        .map((item) {
          try {
            return RecentPracticeRecord.fromJson(
              jsonDecode(item) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<RecentPracticeRecord>()
        .toList(growable: false);
  }

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
    await _saveRecentPractice(
      '카페 키오스크',
      _mode == CafeLearningMode.solo ? '혼자 해보기' : '따라 해보기',
      _mode == CafeLearningMode.solo ? 20 : 10,
    );
    if (shouldAwardBadge) {
      await _preferences.setBool(_soloFirstBadgeKey, true);
    }
    notifyListeners();
    return shouldAwardBadge;
  }

  Future<void> markCafeLearningCompleted() async {
    await _recordCompletion(CafeLearningMode.guided);
    await _saveRecentPractice('카페 키오스크', '따라 해보기', 10);
    notifyListeners();
  }

  Future<void> _saveRecentPractice(
    String learningName,
    String modeName,
    int points,
  ) async {
    final record = RecentPracticeRecord(
      learningName: learningName,
      modeName: modeName,
      points: points,
      completedAt: DateTime.now(),
    );
    final records = [record, ...recentPracticeRecords].take(20);
    await _preferences.setStringList(
      _recentPracticeRecordsKey,
      records.map((item) => jsonEncode(item.toJson())).toList(),
    );
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

  void selectHospitalVisitPurpose(String value) {
    _hospitalVisitPurpose = value;
    notifyListeners();
  }

  void selectHospitalMode(HospitalLearningMode value) {
    _hospitalMode = value;
    resetHospitalLearning();
  }

  void selectHospitalRegistrationMethod(String value) {
    _hospitalRegistrationMethod = value;
    notifyListeners();
  }

  void selectHospitalDepartment(String value) {
    _hospitalDepartment = value;
    notifyListeners();
  }

  Future<void> completeHospitalLearning() async {
    if (_hospitalCompletionAwarded) {
      return;
    }

    _hospitalCompletionAwarded = true;
    await _preferences.setInt(_pointsKey, totalPoints + 10);
    await _preferences.setInt(
      _hospitalCompletionCountKey,
      hospitalCompletionCount + 1,
    );
    await _saveRecentPractice('병원 접수', '따라 해보기', 10);
    notifyListeners();
  }

  void resetHospitalLearning() {
    _hospitalVisitPurpose = null;
    _hospitalRegistrationMethod = null;
    _hospitalDepartment = null;
    _hospitalCompletionAwarded = false;
    _hospitalSoloCompletionAwarded = false;
    notifyListeners();
  }

  Future<bool> completeHospitalSoloLearning() async {
    if (_hospitalSoloCompletionAwarded) {
      return false;
    }

    final shouldAwardBadge = !hospitalSoloFirstBadgeEarned;
    _hospitalSoloCompletionAwarded = true;
    await _preferences.setInt(_pointsKey, totalPoints + 20);
    await _preferences.setInt(
      _hospitalSoloCompletionCountKey,
      hospitalSoloCompletionCount + 1,
    );
    if (shouldAwardBadge) {
      await _preferences.setBool(_hospitalSoloFirstBadgeKey, true);
    }
    await _saveRecentPractice('병원 접수', '혼자 해보기', 20);
    notifyListeners();
    return shouldAwardBadge;
  }

  void selectPhotoRecipient(String value) {
    _photoRecipient = value;
    notifyListeners();
  }

  void selectPhotoMode(PhotoLearningMode value) {
    _photoMode = value;
    resetPhotoLearning();
  }

  void selectPhoto(String value) {
    _photoSelection = value;
    notifyListeners();
  }

  void selectPhotoMessage(String value) {
    _photoMessage = value;
    notifyListeners();
  }

  Future<void> completePhotoLearning() async {
    if (_photoCompletionAwarded) {
      return;
    }

    _photoCompletionAwarded = true;
    await _preferences.setInt(_pointsKey, totalPoints + 10);
    await _preferences.setInt(
      _photoCompletionCountKey,
      photoCompletionCount + 1,
    );
    await _saveRecentPractice('사진 보내기', '따라 해보기', 10);
    notifyListeners();
  }

  void resetPhotoLearning() {
    _photoRecipient = null;
    _photoSelection = null;
    _photoMessage = null;
    _photoCompletionAwarded = false;
    _photoSoloCompletionAwarded = false;
    notifyListeners();
  }

  Future<bool> completePhotoSoloLearning() async {
    if (_photoSoloCompletionAwarded) {
      return false;
    }

    final shouldAwardBadge = !photoSoloFirstBadgeEarned;
    _photoSoloCompletionAwarded = true;
    await _preferences.setInt(_pointsKey, totalPoints + 20);
    await _preferences.setInt(
      _photoSoloCompletionCountKey,
      photoSoloCompletionCount + 1,
    );
    if (shouldAwardBadge) {
      await _preferences.setBool(_photoSoloFirstBadgeKey, true);
    }
    await _saveRecentPractice('사진 보내기', '혼자 해보기', 20);
    notifyListeners();
    return shouldAwardBadge;
  }

  void selectTrainDepartureStation(String value) {
    _trainDepartureStation = value;
    notifyListeners();
  }

  void selectTrainMode(TrainLearningMode value) {
    _trainMode = value;
    resetTrainLearning();
  }

  void selectTrainArrivalStation(String value) {
    _trainArrivalStation = value;
    notifyListeners();
  }

  void selectTrainDepartureTime(String value) {
    _trainDepartureTime = value;
    notifyListeners();
  }

  void selectTrainSeat(String value) {
    _trainSeat = value;
    notifyListeners();
  }

  Future<void> completeTrainLearning() async {
    if (_trainCompletionAwarded) {
      return;
    }

    _trainCompletionAwarded = true;
    await _preferences.setInt(_pointsKey, totalPoints + 10);
    await _preferences.setInt(
      _trainCompletionCountKey,
      trainCompletionCount + 1,
    );
    await _saveRecentPractice('기차표 예매', '따라 해보기', 10);
    notifyListeners();
  }

  Future<bool> completeTrainSoloLearning() async {
    if (_trainSoloCompletionAwarded) {
      return false;
    }

    final shouldAwardBadge = !trainSoloFirstBadgeEarned;
    _trainSoloCompletionAwarded = true;
    await _preferences.setInt(_pointsKey, totalPoints + 20);
    await _preferences.setInt(
      _trainSoloCompletionCountKey,
      trainSoloCompletionCount + 1,
    );
    if (shouldAwardBadge) {
      await _preferences.setBool(_trainSoloFirstBadgeKey, true);
    }
    await _saveRecentPractice('기차표 예매', '혼자 해보기', 20);
    notifyListeners();
    return shouldAwardBadge;
  }

  void resetTrainLearning() {
    _trainDepartureStation = null;
    _trainArrivalStation = null;
    _trainDepartureTime = null;
    _trainSeat = null;
    _trainCompletionAwarded = false;
    _trainSoloCompletionAwarded = false;
    notifyListeners();
  }
}
