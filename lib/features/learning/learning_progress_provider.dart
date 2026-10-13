import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/data_migration/preference_keys.dart';
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
  static const onboardingCompletedKey = V2PreferenceKeys.onboardingCompleted;
  static const _accessibilityTextSizeKey =
      V2PreferenceKeys.accessibilityTextSize;
  static const _screenContrastKey = V2PreferenceKeys.screenContrast;
  static const _completionCountKey = V2PreferenceKeys.cafeLegacyCompletionCount;
  static const _guidedCompletionCountKey =
      V2PreferenceKeys.cafeGuidedCompletionCount;
  static const _soloCompletionCountKey =
      V2PreferenceKeys.cafeSoloCompletionCount;
  static const _pointsKey = V2PreferenceKeys.points;
  static const _dailyMissionRewardTokensKey =
      V2PreferenceKeys.dailyMissionRewardTokens;
  static const _soloFirstBadgeKey = V2PreferenceKeys.cafeSoloFirstBadge;
  static const _cafeFamiliarBadgeKey = V2PreferenceKeys.cafeFamiliarBadge;
  static const _cafeModeKey = V2PreferenceKeys.cafeMode;
  static const _cafeGuidedSessionAwardedKey =
      V2PreferenceKeys.cafeGuidedSessionAwarded;
  static const _cafeSoloSessionAwardedKey =
      V2PreferenceKeys.cafeSoloSessionAwarded;
  static const _hospitalCompletionCountKey =
      V2PreferenceKeys.hospitalGuidedCompletionCount;
  static const _hospitalSoloCompletionCountKey =
      V2PreferenceKeys.hospitalSoloCompletionCount;
  static const _hospitalSoloFirstBadgeKey =
      V2PreferenceKeys.hospitalSoloFirstBadge;
  static const _hospitalModeKey = V2PreferenceKeys.hospitalMode;
  static const _hospitalGuidedSessionAwardedKey =
      V2PreferenceKeys.hospitalGuidedSessionAwarded;
  static const _hospitalSoloSessionAwardedKey =
      V2PreferenceKeys.hospitalSoloSessionAwarded;
  static const _hospitalReservationCompletionCountKey =
      V2PreferenceKeys.hospitalReservationGuidedCompletionCount;
  static const _hospitalReservationSoloCompletionCountKey =
      V2PreferenceKeys.hospitalReservationSoloCompletionCount;
  static const _hospitalReservationGuidedSessionAwardedKey =
      V2PreferenceKeys.hospitalReservationGuidedSessionAwarded;
  static const _hospitalReservationSoloSessionAwardedKey =
      V2PreferenceKeys.hospitalReservationSoloSessionAwarded;
  static const _hospitalPaymentCompletionCountKey =
      V2PreferenceKeys.hospitalPaymentGuidedCompletionCount;
  static const _hospitalPaymentSoloCompletionCountKey =
      V2PreferenceKeys.hospitalPaymentSoloCompletionCount;
  static const _hospitalPaymentGuidedSessionAwardedKey =
      V2PreferenceKeys.hospitalPaymentGuidedSessionAwarded;
  static const _hospitalPaymentSoloSessionAwardedKey =
      V2PreferenceKeys.hospitalPaymentSoloSessionAwarded;
  static const _hospitalDocumentCompletionCountKey =
      V2PreferenceKeys.hospitalDocumentGuidedCompletionCount;
  static const _hospitalDocumentSoloCompletionCountKey =
      V2PreferenceKeys.hospitalDocumentSoloCompletionCount;
  static const _hospitalDocumentGuidedSessionAwardedKey =
      V2PreferenceKeys.hospitalDocumentGuidedSessionAwarded;
  static const _hospitalDocumentSoloSessionAwardedKey =
      V2PreferenceKeys.hospitalDocumentSoloSessionAwarded;
  static const _photoCompletionCountKey =
      V2PreferenceKeys.photoGuidedCompletionCount;
  static const _photoSoloCompletionCountKey =
      V2PreferenceKeys.photoSoloCompletionCount;
  static const _photoSoloFirstBadgeKey = V2PreferenceKeys.photoSoloFirstBadge;
  static const _photoModeKey = V2PreferenceKeys.photoMode;
  static const _photoGuidedSessionAwardedKey =
      V2PreferenceKeys.photoGuidedSessionAwarded;
  static const _photoSoloSessionAwardedKey =
      V2PreferenceKeys.photoSoloSessionAwarded;
  static const _trainCompletionCountKey =
      V2PreferenceKeys.trainGuidedCompletionCount;
  static const _trainSoloCompletionCountKey =
      V2PreferenceKeys.trainSoloCompletionCount;
  static const _trainSoloFirstBadgeKey = V2PreferenceKeys.trainSoloFirstBadge;
  static const _trainModeKey = V2PreferenceKeys.trainMode;
  static const _trainGuidedSessionAwardedKey =
      V2PreferenceKeys.trainGuidedSessionAwarded;
  static const _trainSoloSessionAwardedKey =
      V2PreferenceKeys.trainSoloSessionAwarded;
  static const _recentPracticeRecordsKey =
      V2PreferenceKeys.recentPracticeRecords;
  static const _hamburgerCompletionCountKey =
      V2PreferenceKeys.hamburgerGuidedCompletionCount;
  static const _hamburgerSoloCompletionCountKey =
      V2PreferenceKeys.hamburgerSoloCompletionCount;
  static const _hamburgerSoloFirstBadgeKey =
      V2PreferenceKeys.hamburgerSoloFirstBadge;
  static const _hamburgerModeKey = V2PreferenceKeys.hamburgerMode;
  static const _hamburgerCurrentMissionKey =
      V2PreferenceKeys.hamburgerCurrentMission;
  static const _hamburgerLastMissionKey = V2PreferenceKeys.hamburgerLastMission;
  static const _hamburgerSoloSessionAwardedKey =
      V2PreferenceKeys.hamburgerSoloSessionAwarded;
  static const _hamburgerGuidedSessionAwardedKey =
      V2PreferenceKeys.hamburgerGuidedSessionAwarded;
  static const _atmCompletionCountKey =
      V2PreferenceKeys.atmGuidedCompletionCount;
  static const _atmSessionAwardedKey = V2PreferenceKeys.atmGuidedSessionAwarded;
  static const _atmSoloCompletionCountKey =
      V2PreferenceKeys.atmSoloCompletionCount;
  static const _atmSoloFirstBadgeKey = V2PreferenceKeys.atmSoloFirstBadge;
  static const _atmSoloSessionAwardedKey =
      V2PreferenceKeys.atmSoloSessionAwarded;
  static const _atmModeKey = V2PreferenceKeys.atmMode;
  static const _civilDocumentCompletionCountKey =
      V2PreferenceKeys.civilDocumentGuidedCompletionCount;
  static const _civilDocumentSessionAwardedKey =
      V2PreferenceKeys.civilDocumentGuidedSessionAwarded;
  static const _civilDocumentSoloCompletionCountKey =
      V2PreferenceKeys.civilDocumentSoloCompletionCount;
  static const _civilDocumentSoloFirstBadgeKey =
      V2PreferenceKeys.civilDocumentSoloFirstBadge;
  static const _civilDocumentSoloSessionAwardedKey =
      V2PreferenceKeys.civilDocumentSoloSessionAwarded;
  static const _civilDocumentModeKey = V2PreferenceKeys.civilDocumentMode;
  static const _practiceRecordKeys = <String>{
    ...V2PreferenceKeys.practiceRecordKeys,
    ...V3RewardKeys.stateKeys,
  };
  final SharedPreferences _preferences;
  final List<Future<void> Function()> _practiceResetHandlers = [];
  final List<VoidCallback> _practiceStartHandlers = [];
  final Set<String> _awardingDailyMissionTokens = {};
  SharedPreferences get preferences => _preferences;

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

  bool get onboardingCompleted =>
      _preferences.getBool(onboardingCompletedKey) ?? false;

  Future<void> completeOnboarding() async {
    await _preferences.setBool(onboardingCompletedKey, true);
    notifyListeners();
  }

  Future<void> showOnboardingAgain() async {
    await _preferences.setBool(onboardingCompletedKey, false);
    notifyListeners();
  }

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
  bool _hospitalReservationGuidedAwarded = false;
  bool _hospitalReservationSoloAwarded = false;
  bool _hospitalPaymentGuidedAwarded = false;
  bool _hospitalPaymentSoloAwarded = false;
  bool _hospitalDocumentGuidedAwarded = false;
  bool _hospitalDocumentSoloAwarded = false;
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
  bool hasDailyMissionReward(String token) =>
      (_preferences.getStringList(_dailyMissionRewardTokensKey) ?? const [])
          .contains(token);

  Future<bool> awardDailyMissionBonus(String token) async {
    if (_awardingDailyMissionTokens.contains(token)) return false;
    final tokens =
        _preferences.getStringList(_dailyMissionRewardTokensKey) ?? <String>[];
    if (tokens.contains(token)) return false;
    _awardingDailyMissionTokens.add(token);
    try {
      await _preferences.setStringList(_dailyMissionRewardTokensKey, [
        ...tokens,
        token,
      ]);
      await _preferences.setInt(_pointsKey, totalPoints + 10);
      notifyListeners();
      return true;
    } finally {
      _awardingDailyMissionTokens.remove(token);
    }
  }

  void registerPracticeResetHandler(Future<void> Function() handler) {
    if (!_practiceResetHandlers.contains(handler)) {
      _practiceResetHandlers.add(handler);
    }
  }

  void unregisterPracticeResetHandler(Future<void> Function() handler) {
    _practiceResetHandlers.remove(handler);
  }

  void registerPracticeStartHandler(VoidCallback handler) {
    if (!_practiceStartHandlers.contains(handler)) {
      _practiceStartHandlers.add(handler);
    }
  }

  void unregisterPracticeStartHandler(VoidCallback handler) {
    _practiceStartHandlers.remove(handler);
  }

  void _notifyPracticeStarted() {
    for (final handler in List.of(_practiceStartHandlers)) {
      handler();
    }
  }

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
  int get hospitalReservationCompletionCount =>
      _preferences.getInt(_hospitalReservationCompletionCountKey) ?? 0;
  int get hospitalReservationSoloCompletionCount =>
      _preferences.getInt(_hospitalReservationSoloCompletionCountKey) ?? 0;
  int get hospitalPaymentCompletionCount =>
      _preferences.getInt(_hospitalPaymentCompletionCountKey) ?? 0;
  int get hospitalPaymentSoloCompletionCount =>
      _preferences.getInt(_hospitalPaymentSoloCompletionCountKey) ?? 0;
  int get hospitalDocumentCompletionCount =>
      _preferences.getInt(_hospitalDocumentCompletionCountKey) ?? 0;
  int get hospitalDocumentSoloCompletionCount =>
      _preferences.getInt(_hospitalDocumentSoloCompletionCountKey) ?? 0;
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
    _notifyPracticeStarted();
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
    _notifyPracticeStarted();
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

  void startHospitalReservationLearning({required bool solo}) {
    _hospitalReservationGuidedAwarded = false;
    _hospitalReservationSoloAwarded = false;
    _preferences.setBool(
      solo
          ? _hospitalReservationSoloSessionAwardedKey
          : _hospitalReservationGuidedSessionAwardedKey,
      false,
    );
  }

  Future<bool> completeHospitalReservationLearning({required bool solo}) async {
    final key = solo
        ? _hospitalReservationSoloSessionAwardedKey
        : _hospitalReservationGuidedSessionAwardedKey;
    final alreadyAwarded = solo
        ? _hospitalReservationSoloAwarded
        : _hospitalReservationGuidedAwarded;
    if (alreadyAwarded || (_preferences.getBool(key) ?? false)) return false;

    if (solo) {
      _hospitalReservationSoloAwarded = true;
    } else {
      _hospitalReservationGuidedAwarded = true;
    }
    await _preferences.setBool(key, true);
    final points = solo ? 20 : 10;
    await _preferences.setInt(_pointsKey, totalPoints + points);
    final countKey = solo
        ? _hospitalReservationSoloCompletionCountKey
        : _hospitalReservationCompletionCountKey;
    final count = solo
        ? hospitalReservationSoloCompletionCount
        : hospitalReservationCompletionCount;
    await _preferences.setInt(countKey, count + 1);
    await _saveRecentPractice('병원 예약 확인', solo ? '혼자 해보기' : '따라 해보기', points);
    notifyListeners();
    return true;
  }

  void startHospitalPaymentLearning({required bool solo}) {
    _hospitalPaymentGuidedAwarded = false;
    _hospitalPaymentSoloAwarded = false;
    _preferences.setBool(
      solo
          ? _hospitalPaymentSoloSessionAwardedKey
          : _hospitalPaymentGuidedSessionAwardedKey,
      false,
    );
  }

  Future<bool> completeHospitalPaymentLearning({required bool solo}) async {
    final key = solo
        ? _hospitalPaymentSoloSessionAwardedKey
        : _hospitalPaymentGuidedSessionAwardedKey;
    final alreadyAwarded = solo
        ? _hospitalPaymentSoloAwarded
        : _hospitalPaymentGuidedAwarded;
    if (alreadyAwarded || (_preferences.getBool(key) ?? false)) return false;
    if (solo) {
      _hospitalPaymentSoloAwarded = true;
    } else {
      _hospitalPaymentGuidedAwarded = true;
    }
    await _preferences.setBool(key, true);
    final points = solo ? 20 : 10;
    await _preferences.setInt(_pointsKey, totalPoints + points);
    final countKey = solo
        ? _hospitalPaymentSoloCompletionCountKey
        : _hospitalPaymentCompletionCountKey;
    final count = solo
        ? hospitalPaymentSoloCompletionCount
        : hospitalPaymentCompletionCount;
    await _preferences.setInt(countKey, count + 1);
    await _saveRecentPractice('병원 진료비 수납', solo ? '혼자 해보기' : '따라 해보기', points);
    notifyListeners();
    return true;
  }

  void startHospitalDocumentLearning({required bool solo}) {
    _hospitalDocumentGuidedAwarded = false;
    _hospitalDocumentSoloAwarded = false;
    _preferences.setBool(
      solo
          ? _hospitalDocumentSoloSessionAwardedKey
          : _hospitalDocumentGuidedSessionAwardedKey,
      false,
    );
  }

  Future<bool> completeHospitalDocumentLearning({required bool solo}) async {
    final key = solo
        ? _hospitalDocumentSoloSessionAwardedKey
        : _hospitalDocumentGuidedSessionAwardedKey;
    final alreadyAwarded = solo
        ? _hospitalDocumentSoloAwarded
        : _hospitalDocumentGuidedAwarded;
    if (alreadyAwarded || (_preferences.getBool(key) ?? false)) return false;
    if (solo) {
      _hospitalDocumentSoloAwarded = true;
    } else {
      _hospitalDocumentGuidedAwarded = true;
    }
    await _preferences.setBool(key, true);
    final points = solo ? 20 : 10;
    await _preferences.setInt(_pointsKey, totalPoints + points);
    final countKey = solo
        ? _hospitalDocumentSoloCompletionCountKey
        : _hospitalDocumentCompletionCountKey;
    final count = solo
        ? hospitalDocumentSoloCompletionCount
        : hospitalDocumentCompletionCount;
    await _preferences.setInt(countKey, count + 1);
    await _saveRecentPractice('병원 서류 발급', solo ? '혼자 해보기' : '따라 해보기', points);
    notifyListeners();
    return true;
  }

  void selectPhotoRecipient(String value) {
    _photoRecipient = value;
    notifyListeners();
  }

  void selectPhotoMode(PhotoLearningMode value) {
    _notifyPracticeStarted();
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
    _notifyPracticeStarted();
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
    _notifyPracticeStarted();
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
    _notifyPracticeStarted();
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
    _notifyPracticeStarted();
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
    _hospitalReservationGuidedAwarded = false;
    _hospitalReservationSoloAwarded = false;
    _hospitalPaymentGuidedAwarded = false;
    _hospitalPaymentSoloAwarded = false;
    _hospitalDocumentGuidedAwarded = false;
    _hospitalDocumentSoloAwarded = false;
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
    _awardingDailyMissionTokens.clear();
    for (final handler in List.of(_practiceResetHandlers)) {
      await handler();
    }
    notifyListeners();
  }
}
