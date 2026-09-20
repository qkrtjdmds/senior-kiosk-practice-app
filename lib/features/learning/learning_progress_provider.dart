import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

import '../hamburger/hamburger_mission.dart';
import '../progress/recent_practice_record.dart';

enum CafeLearningMode { guided, solo }

enum TrainLearningMode { guided, solo }

enum HospitalLearningMode { guided, solo }

enum PhotoLearningMode { guided, solo }

enum HamburgerLearningMode { guided, solo }

enum AtmLearningMode { guided, solo }

enum CivilDocumentLearningMode { guided, solo }

enum AccessibilityTextSize { normal, large, extraLarge }

enum ScreenContrast { comfortable, vivid }

class LearningProgressProvider extends ChangeNotifier {
  static const _accessibilityTextSizeKey = 'accessibility_text_size';
  static const _screenContrastKey = 'screen_contrast';
  static const _completionCountKey = 'cafe_learning_completion_count';
  static const _guidedCompletionCountKey = 'cafe_guided_completion_count';
  static const _soloCompletionCountKey = 'cafe_solo_completion_count';
  static const _pointsKey = 'digital_confidence_points';
  static const _soloFirstBadgeKey = 'cafe_solo_first_badge_earned';
  static const _cafeFamiliarBadgeKey = 'cafe_familiar_badge_earned';
  static const _cafeModeKey = 'cafe_learning_mode';
  static const _cafeGuidedSessionAwardedKey = 'cafe_guided_session_awarded';
  static const _cafeSoloSessionAwardedKey = 'cafe_solo_session_awarded';
  static const _hospitalCompletionCountKey = 'hospital_guided_completion_count';
  static const _hospitalSoloCompletionCountKey =
      'hospital_solo_completion_count';
  static const _hospitalSoloFirstBadgeKey = 'hospital_solo_first_badge_earned';
  static const _hospitalModeKey = 'hospital_learning_mode';
  static const _hospitalGuidedSessionAwardedKey =
      'hospital_guided_session_awarded';
  static const _hospitalSoloSessionAwardedKey = 'hospital_solo_session_awarded';
  static const _photoCompletionCountKey = 'photo_guided_completion_count';
  static const _photoSoloCompletionCountKey = 'photo_solo_completion_count';
  static const _photoSoloFirstBadgeKey = 'photo_solo_first_badge_earned';
  static const _photoModeKey = 'photo_learning_mode';
  static const _photoGuidedSessionAwardedKey = 'photo_guided_session_awarded';
  static const _photoSoloSessionAwardedKey = 'photo_solo_session_awarded';
  static const _trainCompletionCountKey = 'train_guided_completion_count';
  static const _trainSoloCompletionCountKey = 'train_solo_completion_count';
  static const _trainSoloFirstBadgeKey = 'train_solo_first_badge_earned';
  static const _trainModeKey = 'train_learning_mode';
  static const _trainGuidedSessionAwardedKey = 'train_guided_session_awarded';
  static const _trainSoloSessionAwardedKey = 'train_solo_session_awarded';
  static const _recentPracticeRecordsKey = 'recent_practice_records';
  static const _hamburgerCompletionCountKey =
      'hamburger_guided_completion_count';
  static const _hamburgerSoloCompletionCountKey =
      'hamburger_solo_completion_count';
  static const _hamburgerSoloFirstBadgeKey =
      'hamburger_solo_first_badge_earned';
  static const _hamburgerModeKey = 'hamburger_learning_mode';
  static const _hamburgerCurrentMissionKey = 'hamburger_current_mission_id';
  static const _hamburgerLastMissionKey = 'hamburger_last_mission_id';
  static const _hamburgerSoloSessionAwardedKey =
      'hamburger_solo_session_awarded';
  static const _hamburgerGuidedSessionAwardedKey =
      'hamburger_guided_session_awarded';
  static const _atmCompletionCountKey = 'atm_guided_completion_count';
  static const _atmSessionAwardedKey = 'atm_guided_session_awarded';
  static const _atmSoloCompletionCountKey = 'atm_solo_completion_count';
  static const _atmSoloFirstBadgeKey = 'atm_solo_first_badge_earned';
  static const _atmSoloSessionAwardedKey = 'atm_solo_session_awarded';
  static const _atmModeKey = 'atm_learning_mode';
  static const _civilDocumentCompletionCountKey =
      'civil_document_guided_completion_count';
  static const _civilDocumentSessionAwardedKey =
      'civil_document_guided_session_awarded';
  static const _civilDocumentSoloCompletionCountKey =
      'civil_document_solo_completion_count';
  static const _civilDocumentSoloFirstBadgeKey =
      'civil_document_solo_first_badge_earned';
  static const _civilDocumentSoloSessionAwardedKey =
      'civil_document_solo_session_awarded';
  static const _civilDocumentModeKey = 'civil_document_learning_mode';
  static const _practiceRecordKeys = <String>[
    _completionCountKey,
    _guidedCompletionCountKey,
    _soloCompletionCountKey,
    _pointsKey,
    _soloFirstBadgeKey,
    _cafeFamiliarBadgeKey,
    _cafeModeKey,
    _cafeGuidedSessionAwardedKey,
    _cafeSoloSessionAwardedKey,
    _hospitalCompletionCountKey,
    _hospitalSoloCompletionCountKey,
    _hospitalSoloFirstBadgeKey,
    _hospitalModeKey,
    _hospitalGuidedSessionAwardedKey,
    _hospitalSoloSessionAwardedKey,
    _photoCompletionCountKey,
    _photoSoloCompletionCountKey,
    _photoSoloFirstBadgeKey,
    _photoModeKey,
    _photoGuidedSessionAwardedKey,
    _photoSoloSessionAwardedKey,
    _trainCompletionCountKey,
    _trainSoloCompletionCountKey,
    _trainSoloFirstBadgeKey,
    _trainModeKey,
    _trainGuidedSessionAwardedKey,
    _trainSoloSessionAwardedKey,
    _recentPracticeRecordsKey,
    _hamburgerCompletionCountKey,
    _hamburgerSoloCompletionCountKey,
    _hamburgerSoloFirstBadgeKey,
    _hamburgerModeKey,
    _hamburgerCurrentMissionKey,
    _hamburgerLastMissionKey,
    _hamburgerSoloSessionAwardedKey,
    _hamburgerGuidedSessionAwardedKey,
    _atmCompletionCountKey,
    _atmSessionAwardedKey,
    _atmSoloCompletionCountKey,
    _atmSoloFirstBadgeKey,
    _atmSoloSessionAwardedKey,
    _atmModeKey,
    _civilDocumentCompletionCountKey,
    _civilDocumentSessionAwardedKey,
    _civilDocumentSoloCompletionCountKey,
    _civilDocumentSoloFirstBadgeKey,
    _civilDocumentSoloSessionAwardedKey,
    _civilDocumentModeKey,
  ];
  final SharedPreferences _preferences;

  LearningProgressProvider(this._preferences) {
    _syncFamiliarBadge();
  }

  AccessibilityTextSize get accessibilityTextSize {
    final stored = _preferences.getString(_accessibilityTextSizeKey);
    return AccessibilityTextSize.values.firstWhere(
      (value) => value.name == stored,
      orElse: () => AccessibilityTextSize.normal,
    );
  }

  ScreenContrast get screenContrast {
    final stored = _preferences.getString(_screenContrastKey);
    return ScreenContrast.values.firstWhere(
      (value) => value.name == stored,
      orElse: () => ScreenContrast.comfortable,
    );
  }

  double get textScaleFactor => switch (accessibilityTextSize) {
    AccessibilityTextSize.normal => 1.0,
    AccessibilityTextSize.large => 1.18,
    AccessibilityTextSize.extraLarge => 1.33,
  };

  bool get usesVividContrast => screenContrast == ScreenContrast.vivid;

  Future<void> setAccessibilityTextSize(AccessibilityTextSize value) async {
    if (accessibilityTextSize == value) return;
    await _preferences.setString(_accessibilityTextSizeKey, value.name);
    notifyListeners();
  }

  Future<void> setScreenContrast(ScreenContrast value) async {
    if (screenContrast == value) return;
    await _preferences.setString(_screenContrastKey, value.name);
    notifyListeners();
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
  String? _hamburgerDineOption;
  String? _hamburgerMenu;
  bool? _hamburgerIsSet;
  String? _hamburgerDrink;
  bool _hamburgerCompletionAwarded = false;
  HamburgerLearningMode? _hamburgerMode;
  bool _hamburgerSoloCompletionAwarded = false;
  String? _atmAmount;
  bool _atmCompletionAwarded = false;
  AtmLearningMode? _atmMode;
  bool _atmSoloCompletionAwarded = false;
  String? _civilDocumentContent;
  String? _civilDocumentCopies;
  bool _civilDocumentCompletionAwarded = false;
  CivilDocumentLearningMode? _civilDocumentMode;
  bool _civilDocumentSoloCompletionAwarded = false;

  CafeLearningMode? get mode =>
      _mode ?? _modeFromStorage(_cafeModeKey, CafeLearningMode.values);
  String? get dineOption => _dineOption;
  String? get drink => _drink;
  String? get temperature => _temperature;
  bool get isSoloMode => mode == CafeLearningMode.solo;
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
  HospitalLearningMode? get hospitalMode =>
      _hospitalMode ??
      _modeFromStorage(_hospitalModeKey, HospitalLearningMode.values);
  bool get isHospitalSoloMode => hospitalMode == HospitalLearningMode.solo;
  int get hospitalSoloCompletionCount =>
      _preferences.getInt(_hospitalSoloCompletionCountKey) ?? 0;
  bool get hospitalSoloFirstBadgeEarned =>
      _preferences.getBool(_hospitalSoloFirstBadgeKey) ?? false;
  String? get photoRecipient => _photoRecipient;
  String? get photoSelection => _photoSelection;
  String? get photoMessage => _photoMessage;
  int get photoCompletionCount =>
      _preferences.getInt(_photoCompletionCountKey) ?? 0;
  PhotoLearningMode? get photoMode =>
      _photoMode ?? _modeFromStorage(_photoModeKey, PhotoLearningMode.values);
  bool get isPhotoSoloMode => photoMode == PhotoLearningMode.solo;
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
  TrainLearningMode? get trainMode =>
      _trainMode ?? _modeFromStorage(_trainModeKey, TrainLearningMode.values);
  bool get isTrainSoloMode => trainMode == TrainLearningMode.solo;
  int get trainSoloCompletionCount =>
      _preferences.getInt(_trainSoloCompletionCountKey) ?? 0;
  bool get trainSoloFirstBadgeEarned =>
      _preferences.getBool(_trainSoloFirstBadgeKey) ?? false;
  String? get hamburgerDineOption => _hamburgerDineOption;
  String? get hamburgerMenu => _hamburgerMenu;
  bool? get hamburgerIsSet => _hamburgerIsSet;
  String? get hamburgerDrink => _hamburgerDrink;
  int get hamburgerCompletionCount =>
      _preferences.getInt(_hamburgerCompletionCountKey) ?? 0;
  HamburgerLearningMode? get hamburgerMode => _hamburgerMode;
  bool get isHamburgerSoloMode =>
      _hamburgerMode == HamburgerLearningMode.solo ||
      (_hamburgerMode == null &&
          _preferences.getString(_hamburgerModeKey) == 'solo');
  HamburgerMission get currentHamburgerMission => HamburgerMission.byId(
    _preferences.getString(_hamburgerCurrentMissionKey),
  );
  int get hamburgerSoloCompletionCount =>
      _preferences.getInt(_hamburgerSoloCompletionCountKey) ?? 0;
  bool get hamburgerSoloFirstBadgeEarned =>
      _preferences.getBool(_hamburgerSoloFirstBadgeKey) ?? false;
  String? get atmAmount => _atmAmount;
  int get atmCompletionCount =>
      _preferences.getInt(_atmCompletionCountKey) ?? 0;
  bool get isAtmSoloMode =>
      _atmMode == AtmLearningMode.solo ||
      (_atmMode == null && _preferences.getString(_atmModeKey) == 'solo');
  int get atmSoloCompletionCount =>
      _preferences.getInt(_atmSoloCompletionCountKey) ?? 0;
  bool get atmSoloFirstBadgeEarned =>
      _preferences.getBool(_atmSoloFirstBadgeKey) ?? false;
  String? get civilDocumentContent => _civilDocumentContent;
  String? get civilDocumentCopies => _civilDocumentCopies;
  int get civilDocumentCompletionCount =>
      _preferences.getInt(_civilDocumentCompletionCountKey) ?? 0;
  bool get isCivilDocumentSoloMode =>
      _civilDocumentMode == CivilDocumentLearningMode.solo ||
      (_civilDocumentMode == null &&
          _preferences.getString(_civilDocumentModeKey) == 'solo');
  int get civilDocumentSoloCompletionCount =>
      _preferences.getInt(_civilDocumentSoloCompletionCountKey) ?? 0;
  bool get civilDocumentSoloFirstBadgeEarned =>
      _preferences.getBool(_civilDocumentSoloFirstBadgeKey) ?? false;
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

  T? _modeFromStorage<T extends Enum>(String key, List<T> values) {
    final stored = _preferences.getString(key);
    if (stored == null) return null;
    for (final value in values) {
      if (value.name == stored) return value;
    }
    return null;
  }

  void selectMode(CafeLearningMode value) {
    _mode = value;
    _preferences.setString(_cafeModeKey, value.name);
    _dineOption = null;
    _drink = null;
    _temperature = null;
    _currentCompletionAwarded = false;
    _preferences.setBool(
      value == CafeLearningMode.solo
          ? _cafeSoloSessionAwardedKey
          : _cafeGuidedSessionAwardedKey,
      false,
    );
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
    final completedMode = mode;
    final sessionKey = completedMode == CafeLearningMode.solo
        ? _cafeSoloSessionAwardedKey
        : _cafeGuidedSessionAwardedKey;
    if (completedMode == null ||
        _currentCompletionAwarded ||
        (_preferences.getBool(sessionKey) ?? false)) {
      return false;
    }

    final shouldAwardBadge =
        completedMode == CafeLearningMode.solo && !soloFirstBadgeEarned;
    _currentCompletionAwarded = true;
    await _preferences.setBool(sessionKey, true);
    await _recordCompletion(completedMode);
    await _saveRecentPractice(
      '카페 키오스크',
      completedMode == CafeLearningMode.solo ? '혼자 해보기' : '따라 해보기',
      completedMode == CafeLearningMode.solo ? 20 : 10,
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
    int points, [
    String? detail,
  ]) async {
    final record = RecentPracticeRecord(
      learningName: learningName,
      modeName: modeName,
      points: points,
      completedAt: DateTime.now(),
      detail: detail,
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
    final currentMode = mode;
    if (currentMode != null) {
      _preferences.setBool(
        currentMode == CafeLearningMode.solo
            ? _cafeSoloSessionAwardedKey
            : _cafeGuidedSessionAwardedKey,
        false,
      );
    }
    notifyListeners();
  }

  void clearCafeMode() {
    _mode = null;
    _preferences.remove(_cafeModeKey);
    resetCafeLearning();
  }

  void selectHospitalVisitPurpose(String value) {
    _hospitalVisitPurpose = value;
    notifyListeners();
  }

  void selectHospitalMode(HospitalLearningMode value) {
    _hospitalMode = value;
    _preferences.setString(_hospitalModeKey, value.name);
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
    if (_hospitalCompletionAwarded ||
        (_preferences.getBool(_hospitalGuidedSessionAwardedKey) ?? false)) {
      return;
    }

    _hospitalCompletionAwarded = true;
    await _preferences.setBool(_hospitalGuidedSessionAwardedKey, true);
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
    final currentMode = hospitalMode;
    if (currentMode != null) {
      _preferences.setBool(
        currentMode == HospitalLearningMode.solo
            ? _hospitalSoloSessionAwardedKey
            : _hospitalGuidedSessionAwardedKey,
        false,
      );
    }
    notifyListeners();
  }

  Future<bool> completeHospitalSoloLearning() async {
    if (_hospitalSoloCompletionAwarded ||
        (_preferences.getBool(_hospitalSoloSessionAwardedKey) ?? false)) {
      return false;
    }

    final shouldAwardBadge = !hospitalSoloFirstBadgeEarned;
    _hospitalSoloCompletionAwarded = true;
    await _preferences.setBool(_hospitalSoloSessionAwardedKey, true);
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
    _preferences.setString(_photoModeKey, value.name);
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
    if (_photoCompletionAwarded ||
        (_preferences.getBool(_photoGuidedSessionAwardedKey) ?? false)) {
      return;
    }

    _photoCompletionAwarded = true;
    await _preferences.setBool(_photoGuidedSessionAwardedKey, true);
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
    final currentMode = photoMode;
    if (currentMode != null) {
      _preferences.setBool(
        currentMode == PhotoLearningMode.solo
            ? _photoSoloSessionAwardedKey
            : _photoGuidedSessionAwardedKey,
        false,
      );
    }
    notifyListeners();
  }

  Future<bool> completePhotoSoloLearning() async {
    if (_photoSoloCompletionAwarded ||
        (_preferences.getBool(_photoSoloSessionAwardedKey) ?? false)) {
      return false;
    }

    final shouldAwardBadge = !photoSoloFirstBadgeEarned;
    _photoSoloCompletionAwarded = true;
    await _preferences.setBool(_photoSoloSessionAwardedKey, true);
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
    _preferences.setString(_trainModeKey, value.name);
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
    if (_trainCompletionAwarded ||
        (_preferences.getBool(_trainGuidedSessionAwardedKey) ?? false)) {
      return;
    }

    _trainCompletionAwarded = true;
    await _preferences.setBool(_trainGuidedSessionAwardedKey, true);
    await _preferences.setInt(_pointsKey, totalPoints + 10);
    await _preferences.setInt(
      _trainCompletionCountKey,
      trainCompletionCount + 1,
    );
    await _saveRecentPractice('기차표 예매', '따라 해보기', 10);
    notifyListeners();
  }

  Future<bool> completeTrainSoloLearning() async {
    if (_trainSoloCompletionAwarded ||
        (_preferences.getBool(_trainSoloSessionAwardedKey) ?? false)) {
      return false;
    }

    final shouldAwardBadge = !trainSoloFirstBadgeEarned;
    _trainSoloCompletionAwarded = true;
    await _preferences.setBool(_trainSoloSessionAwardedKey, true);
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
    final currentMode = trainMode;
    if (currentMode != null) {
      _preferences.setBool(
        currentMode == TrainLearningMode.solo
            ? _trainSoloSessionAwardedKey
            : _trainGuidedSessionAwardedKey,
        false,
      );
    }
    notifyListeners();
  }

  void selectHamburgerDineOption(String value) {
    _hamburgerDineOption = value;
    notifyListeners();
  }

  void selectHamburgerMode(HamburgerLearningMode value) {
    _hamburgerMode = value;
    _preferences.setString(
      _hamburgerModeKey,
      value == HamburgerLearningMode.solo ? 'solo' : 'guided',
    );
    _preferences.setBool(
      value == HamburgerLearningMode.solo
          ? _hamburgerSoloSessionAwardedKey
          : _hamburgerGuidedSessionAwardedKey,
      false,
    );
    resetHamburgerLearning();
  }

  Future<void> startHamburgerSoloMission() async {
    selectHamburgerMode(HamburgerLearningMode.solo);
    final lastMissionId = _preferences.getString(_hamburgerLastMissionKey);
    final candidates = HamburgerMission.missions
        .where((mission) => mission.id != lastMissionId)
        .toList(growable: false);
    final mission = candidates[Random().nextInt(candidates.length)];
    await _preferences.setString(_hamburgerCurrentMissionKey, mission.id);
    await _preferences.setString(_hamburgerLastMissionKey, mission.id);
    await _preferences.setBool(_hamburgerSoloSessionAwardedKey, false);
    notifyListeners();
  }

  void selectHamburgerMenu(String value) {
    _hamburgerMenu = value;
    notifyListeners();
  }

  void selectHamburgerOrderType(bool isSet) {
    _hamburgerIsSet = isSet;
    if (!isSet) {
      _hamburgerDrink = null;
    }
    notifyListeners();
  }

  void selectHamburgerDrink(String value) {
    _hamburgerDrink = value;
    notifyListeners();
  }

  Future<void> completeHamburgerLearning() async {
    if (_hamburgerCompletionAwarded ||
        (_preferences.getBool(_hamburgerGuidedSessionAwardedKey) ?? false)) {
      return;
    }

    _hamburgerCompletionAwarded = true;
    await _preferences.setBool(_hamburgerGuidedSessionAwardedKey, true);
    await _preferences.setInt(_pointsKey, totalPoints + 10);
    await _preferences.setInt(
      _hamburgerCompletionCountKey,
      hamburgerCompletionCount + 1,
    );
    await _saveRecentPractice('햄버거 주문', '따라 해보기', 10);
    notifyListeners();
  }

  Future<bool> completeHamburgerSoloLearning() async {
    if (_hamburgerSoloCompletionAwarded ||
        (_preferences.getBool(_hamburgerSoloSessionAwardedKey) ?? false)) {
      return false;
    }

    final shouldAwardBadge = !hamburgerSoloFirstBadgeEarned;
    _hamburgerSoloCompletionAwarded = true;
    await _preferences.setBool(_hamburgerSoloSessionAwardedKey, true);
    await _preferences.setInt(_pointsKey, totalPoints + 20);
    await _preferences.setInt(
      _hamburgerSoloCompletionCountKey,
      hamburgerSoloCompletionCount + 1,
    );
    if (shouldAwardBadge) {
      await _preferences.setBool(_hamburgerSoloFirstBadgeKey, true);
    }
    await _saveRecentPractice(
      '햄버거 주문',
      '혼자 해보기',
      20,
      currentHamburgerMission.title,
    );
    notifyListeners();
    return shouldAwardBadge;
  }

  void resetHamburgerLearning() {
    _hamburgerDineOption = null;
    _hamburgerMenu = null;
    _hamburgerIsSet = null;
    _hamburgerDrink = null;
    _hamburgerCompletionAwarded = false;
    _hamburgerSoloCompletionAwarded = false;
    final currentMode =
        _hamburgerMode ??
        (_preferences.getString(_hamburgerModeKey) == 'solo'
            ? HamburgerLearningMode.solo
            : HamburgerLearningMode.guided);
    _preferences.setBool(
      currentMode == HamburgerLearningMode.solo
          ? _hamburgerSoloSessionAwardedKey
          : _hamburgerGuidedSessionAwardedKey,
      false,
    );
    notifyListeners();
  }

  Future<void> startAtmLearning([
    AtmLearningMode mode = AtmLearningMode.guided,
  ]) async {
    _atmMode = mode;
    _atmAmount = null;
    _atmCompletionAwarded = false;
    _atmSoloCompletionAwarded = false;
    await _preferences.setString(
      _atmModeKey,
      mode == AtmLearningMode.solo ? 'solo' : 'guided',
    );
    await _preferences.setBool(
      mode == AtmLearningMode.solo
          ? _atmSoloSessionAwardedKey
          : _atmSessionAwardedKey,
      false,
    );
    notifyListeners();
  }

  void selectAtmAmount(String value) {
    _atmAmount = value;
    notifyListeners();
  }

  Future<void> completeAtmLearning() async {
    if (_atmCompletionAwarded ||
        (_preferences.getBool(_atmSessionAwardedKey) ?? false)) {
      return;
    }

    _atmCompletionAwarded = true;
    await _preferences.setBool(_atmSessionAwardedKey, true);
    await _preferences.setInt(_pointsKey, totalPoints + 10);
    await _preferences.setInt(_atmCompletionCountKey, atmCompletionCount + 1);
    await _saveRecentPractice('ATM 출금', '따라 해보기', 10);
    notifyListeners();
  }

  Future<bool> completeAtmSoloLearning() async {
    if (_atmSoloCompletionAwarded ||
        (_preferences.getBool(_atmSoloSessionAwardedKey) ?? false)) {
      return false;
    }

    final shouldAwardBadge = !atmSoloFirstBadgeEarned;
    _atmSoloCompletionAwarded = true;
    await _preferences.setBool(_atmSoloSessionAwardedKey, true);
    await _preferences.setInt(_pointsKey, totalPoints + 20);
    await _preferences.setInt(
      _atmSoloCompletionCountKey,
      atmSoloCompletionCount + 1,
    );
    if (shouldAwardBadge) {
      await _preferences.setBool(_atmSoloFirstBadgeKey, true);
    }
    await _saveRecentPractice('ATM 출금', '혼자 해보기', 20);
    notifyListeners();
    return shouldAwardBadge;
  }

  Future<void> startCivilDocumentLearning([
    CivilDocumentLearningMode mode = CivilDocumentLearningMode.guided,
  ]) async {
    _civilDocumentMode = mode;
    _civilDocumentContent = null;
    _civilDocumentCopies = null;
    _civilDocumentCompletionAwarded = false;
    _civilDocumentSoloCompletionAwarded = false;
    await _preferences.setString(
      _civilDocumentModeKey,
      mode == CivilDocumentLearningMode.solo ? 'solo' : 'guided',
    );
    await _preferences.setBool(
      mode == CivilDocumentLearningMode.solo
          ? _civilDocumentSoloSessionAwardedKey
          : _civilDocumentSessionAwardedKey,
      false,
    );
    notifyListeners();
  }

  void selectCivilDocumentContent(String value) {
    _civilDocumentContent = value;
    notifyListeners();
  }

  void selectCivilDocumentCopies(String value) {
    _civilDocumentCopies = value;
    notifyListeners();
  }

  Future<void> completeCivilDocumentLearning() async {
    if (_civilDocumentCompletionAwarded ||
        (_preferences.getBool(_civilDocumentSessionAwardedKey) ?? false)) {
      return;
    }

    _civilDocumentCompletionAwarded = true;
    await _preferences.setBool(_civilDocumentSessionAwardedKey, true);
    await _preferences.setInt(_pointsKey, totalPoints + 10);
    await _preferences.setInt(
      _civilDocumentCompletionCountKey,
      civilDocumentCompletionCount + 1,
    );
    await _saveRecentPractice('무인민원발급기', '따라 해보기', 10);
    notifyListeners();
  }

  Future<bool> completeCivilDocumentSoloLearning() async {
    if (_civilDocumentSoloCompletionAwarded ||
        (_preferences.getBool(_civilDocumentSoloSessionAwardedKey) ?? false)) {
      return false;
    }

    final shouldAwardBadge = !civilDocumentSoloFirstBadgeEarned;
    _civilDocumentSoloCompletionAwarded = true;
    await _preferences.setBool(_civilDocumentSoloSessionAwardedKey, true);
    await _preferences.setInt(_pointsKey, totalPoints + 20);
    await _preferences.setInt(
      _civilDocumentSoloCompletionCountKey,
      civilDocumentSoloCompletionCount + 1,
    );
    if (shouldAwardBadge) {
      await _preferences.setBool(_civilDocumentSoloFirstBadgeKey, true);
    }
    await _saveRecentPractice('무인민원발급기', '혼자 해보기', 20);
    notifyListeners();
    return shouldAwardBadge;
  }

  Future<void> resetPracticeRecords() async {
    for (final key in _practiceRecordKeys) {
      await _preferences.remove(key);
    }

    _mode = null;
    _dineOption = null;
    _drink = null;
    _temperature = null;
    _currentCompletionAwarded = false;
    _hospitalVisitPurpose = null;
    _hospitalRegistrationMethod = null;
    _hospitalDepartment = null;
    _hospitalCompletionAwarded = false;
    _hospitalMode = null;
    _hospitalSoloCompletionAwarded = false;
    _photoRecipient = null;
    _photoSelection = null;
    _photoMessage = null;
    _photoCompletionAwarded = false;
    _photoMode = null;
    _photoSoloCompletionAwarded = false;
    _trainDepartureStation = null;
    _trainArrivalStation = null;
    _trainDepartureTime = null;
    _trainSeat = null;
    _trainCompletionAwarded = false;
    _trainMode = null;
    _trainSoloCompletionAwarded = false;
    _hamburgerDineOption = null;
    _hamburgerMenu = null;
    _hamburgerIsSet = null;
    _hamburgerDrink = null;
    _hamburgerCompletionAwarded = false;
    _hamburgerMode = null;
    _hamburgerSoloCompletionAwarded = false;
    _atmAmount = null;
    _atmCompletionAwarded = false;
    _atmMode = null;
    _atmSoloCompletionAwarded = false;
    _civilDocumentContent = null;
    _civilDocumentCopies = null;
    _civilDocumentCompletionAwarded = false;
    _civilDocumentMode = null;
    _civilDocumentSoloCompletionAwarded = false;
    notifyListeners();
  }
}
