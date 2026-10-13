import 'dart:convert';

enum RewardType {
  title('title', '칭호', true),
  accessory('accessory', '캐릭터 장식', true),
  theme('theme', '홈 테마', true),
  expression('expression', '특별 표정', false),
  unknown('unknown', '알 수 없는 보상', false);

  const RewardType(this.storageValue, this.koreanName, this.isSelectable);

  final String storageValue;
  final String koreanName;
  final bool isSelectable;

  static RewardType fromStorageValue(Object? value) {
    if (value is! String) return RewardType.unknown;
    return RewardType.values.firstWhere(
      (type) => type != RewardType.unknown && type.storageValue == value,
      orElse: () => RewardType.unknown,
    );
  }
}

class RewardDefinition {
  RewardDefinition({
    required this.rewardId,
    required this.rewardType,
    required this.title,
    required this.description,
    required this.requiredPoints,
    required this.assetKey,
    required this.sortOrder,
    this.isActive = true,
    this.rewardVersion = 1,
  }) {
    if (rewardId.trim().isEmpty) {
      throw ArgumentError.value(rewardId, 'rewardId', 'must not be empty');
    }
    if (requiredPoints < 0) {
      throw ArgumentError.value(
        requiredPoints,
        'requiredPoints',
        'must not be negative',
      );
    }
    if (sortOrder < 0) {
      throw ArgumentError.value(sortOrder, 'sortOrder', 'must not be negative');
    }
    if (rewardVersion < 1) {
      throw ArgumentError.value(
        rewardVersion,
        'rewardVersion',
        'must be positive',
      );
    }
  }

  final String rewardId;
  final RewardType rewardType;
  final String title;
  final String description;
  final int requiredPoints;
  final String assetKey;
  final int sortOrder;
  final bool isActive;
  final int rewardVersion;

  Map<String, Object?> toJson() => {
    'rewardId': rewardId,
    'rewardType': rewardType.storageValue,
    'title': title,
    'description': description,
    'requiredPoints': requiredPoints,
    'assetKey': assetKey,
    'sortOrder': sortOrder,
    'isActive': isActive,
    'rewardVersion': rewardVersion,
  };

  factory RewardDefinition.fromJson(Map<String, Object?> json) {
    return RewardDefinition(
      rewardId: json['rewardId'] as String? ?? '',
      rewardType: RewardType.fromStorageValue(json['rewardType']),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      requiredPoints: json['requiredPoints'] is int
          ? json['requiredPoints']! as int
          : 0,
      assetKey: json['assetKey'] as String? ?? '',
      sortOrder: json['sortOrder'] is int ? json['sortOrder']! as int : 0,
      isActive: json['isActive'] is bool ? json['isActive']! as bool : false,
      rewardVersion: json['rewardVersion'] is int
          ? json['rewardVersion']! as int
          : 1,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RewardDefinition &&
        rewardId == other.rewardId &&
        rewardType == other.rewardType &&
        title == other.title &&
        description == other.description &&
        requiredPoints == other.requiredPoints &&
        assetKey == other.assetKey &&
        sortOrder == other.sortOrder &&
        isActive == other.isActive &&
        rewardVersion == other.rewardVersion;
  }

  @override
  int get hashCode => Object.hash(
    rewardId,
    rewardType,
    title,
    description,
    requiredPoints,
    assetKey,
    sortOrder,
    isActive,
    rewardVersion,
  );
}

class RewardState {
  RewardState({
    Set<String> unlockedRewardIds = const {},
    Map<String, DateTime> unlockedAtByRewardId = const {},
    Set<String> celebratedRewardIds = const {},
    this.selectedTitleId,
    Set<String> selectedAccessoryIds = const {},
    this.selectedThemeId,
    this.retroactiveGrantCompleted = false,
    this.dataVersion = 0,
    this.catalogVersion = 0,
  }) : unlockedRewardIds = Set.unmodifiable(unlockedRewardIds),
       unlockedAtByRewardId = Map.unmodifiable(unlockedAtByRewardId),
       celebratedRewardIds = Set.unmodifiable(celebratedRewardIds),
       selectedAccessoryIds = Set.unmodifiable(selectedAccessoryIds);

  factory RewardState.empty() => RewardState();

  final Set<String> unlockedRewardIds;
  final Map<String, DateTime> unlockedAtByRewardId;
  final Set<String> celebratedRewardIds;
  final String? selectedTitleId;
  final Set<String> selectedAccessoryIds;
  final String? selectedThemeId;
  final bool retroactiveGrantCompleted;
  final int dataVersion;
  final int catalogVersion;

  RewardState copyWith({
    Set<String>? unlockedRewardIds,
    Map<String, DateTime>? unlockedAtByRewardId,
    Set<String>? celebratedRewardIds,
    Object? selectedTitleId = _notProvided,
    Set<String>? selectedAccessoryIds,
    Object? selectedThemeId = _notProvided,
    bool? retroactiveGrantCompleted,
    int? dataVersion,
    int? catalogVersion,
  }) {
    return RewardState(
      unlockedRewardIds: unlockedRewardIds ?? this.unlockedRewardIds,
      unlockedAtByRewardId: unlockedAtByRewardId ?? this.unlockedAtByRewardId,
      celebratedRewardIds: celebratedRewardIds ?? this.celebratedRewardIds,
      selectedTitleId: identical(selectedTitleId, _notProvided)
          ? this.selectedTitleId
          : selectedTitleId as String?,
      selectedAccessoryIds: selectedAccessoryIds ?? this.selectedAccessoryIds,
      selectedThemeId: identical(selectedThemeId, _notProvided)
          ? this.selectedThemeId
          : selectedThemeId as String?,
      retroactiveGrantCompleted:
          retroactiveGrantCompleted ?? this.retroactiveGrantCompleted,
      dataVersion: dataVersion ?? this.dataVersion,
      catalogVersion: catalogVersion ?? this.catalogVersion,
    );
  }

  RewardState normalized(RewardDefinition? Function(String id) definitionById) {
    final unlocked = Set<String>.of(unlockedRewardIds.where(_isUsableId));
    final timestamps = <String, DateTime>{
      for (final entry in unlockedAtByRewardId.entries)
        if (unlocked.contains(entry.key) && _isUsableId(entry.key))
          entry.key: entry.value.toUtc(),
    };
    final celebrated = celebratedRewardIds
        .where((id) => unlocked.contains(id))
        .toSet();

    bool validSelection(String? id, RewardType expectedType) {
      if (id == null || !unlocked.contains(id)) return false;
      return definitionById(id)?.rewardType == expectedType;
    }

    final accessories = selectedAccessoryIds.where((id) {
      return validSelection(id, RewardType.accessory);
    }).toSet();

    return RewardState(
      unlockedRewardIds: unlocked,
      unlockedAtByRewardId: timestamps,
      celebratedRewardIds: celebrated,
      selectedTitleId: validSelection(selectedTitleId, RewardType.title)
          ? selectedTitleId
          : null,
      selectedAccessoryIds: accessories,
      selectedThemeId: validSelection(selectedThemeId, RewardType.theme)
          ? selectedThemeId
          : null,
      retroactiveGrantCompleted: retroactiveGrantCompleted,
      dataVersion: dataVersion < 0 ? 0 : dataVersion,
      catalogVersion: catalogVersion < 0 ? 0 : catalogVersion,
    );
  }

  Map<String, Object?> toJson() => {
    'unlockedRewardIds': unlockedRewardIds.toList()..sort(),
    'unlockedAtByRewardId': {
      for (final entry in unlockedAtByRewardId.entries)
        entry.key: entry.value.toUtc().toIso8601String(),
    },
    'celebratedRewardIds': celebratedRewardIds.toList()..sort(),
    'selectedTitleId': selectedTitleId,
    'selectedAccessoryIds': selectedAccessoryIds.toList()..sort(),
    'selectedThemeId': selectedThemeId,
    'retroactiveGrantCompleted': retroactiveGrantCompleted,
    'dataVersion': dataVersion,
    'catalogVersion': catalogVersion,
  };

  String toJsonString() => jsonEncode(toJson());

  factory RewardState.fromJson(Map<String, Object?> json) {
    Set<String> stringSet(Object? value) {
      if (value is! List) return <String>{};
      return value.whereType<String>().where(_isUsableId).toSet();
    }

    final timestamps = <String, DateTime>{};
    final rawTimestamps = json['unlockedAtByRewardId'];
    if (rawTimestamps is Map) {
      for (final entry in rawTimestamps.entries) {
        if (entry.key is! String || entry.value is! String) continue;
        final parsed = DateTime.tryParse(entry.value as String);
        if (parsed != null && _isUsableId(entry.key as String)) {
          timestamps[entry.key as String] = parsed.toUtc();
        }
      }
    }

    return RewardState(
      unlockedRewardIds: stringSet(json['unlockedRewardIds']),
      unlockedAtByRewardId: timestamps,
      celebratedRewardIds: stringSet(json['celebratedRewardIds']),
      selectedTitleId: json['selectedTitleId'] is String
          ? json['selectedTitleId']! as String
          : null,
      selectedAccessoryIds: stringSet(json['selectedAccessoryIds']),
      selectedThemeId: json['selectedThemeId'] is String
          ? json['selectedThemeId']! as String
          : null,
      retroactiveGrantCompleted:
          json['retroactiveGrantCompleted'] is bool &&
          json['retroactiveGrantCompleted']! as bool,
      dataVersion: json['dataVersion'] is int ? json['dataVersion']! as int : 0,
      catalogVersion: json['catalogVersion'] is int
          ? json['catalogVersion']! as int
          : 0,
    );
  }

  factory RewardState.fromJsonString(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Reward state must be a JSON object.');
    }
    return RewardState.fromJson(decoded);
  }

  @override
  bool operator ==(Object other) {
    return other is RewardState &&
        _setEquals(unlockedRewardIds, other.unlockedRewardIds) &&
        _mapEquals(unlockedAtByRewardId, other.unlockedAtByRewardId) &&
        _setEquals(celebratedRewardIds, other.celebratedRewardIds) &&
        selectedTitleId == other.selectedTitleId &&
        _setEquals(selectedAccessoryIds, other.selectedAccessoryIds) &&
        selectedThemeId == other.selectedThemeId &&
        retroactiveGrantCompleted == other.retroactiveGrantCompleted &&
        dataVersion == other.dataVersion &&
        catalogVersion == other.catalogVersion;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(unlockedRewardIds),
    Object.hashAllUnordered(
      unlockedAtByRewardId.entries.map(
        (entry) => Object.hash(entry.key, entry.value),
      ),
    ),
    Object.hashAllUnordered(celebratedRewardIds),
    selectedTitleId,
    Object.hashAllUnordered(selectedAccessoryIds),
    selectedThemeId,
    retroactiveGrantCompleted,
    dataVersion,
    catalogVersion,
  );
}

const _notProvided = Object();

bool _isUsableId(String id) => id.trim().isNotEmpty;

bool _setEquals<T>(Set<T> left, Set<T> right) {
  return left.length == right.length && left.containsAll(right);
}

bool _mapEquals<K, V>(Map<K, V> left, Map<K, V> right) {
  if (left.length != right.length) return false;
  return left.entries.every((entry) => right[entry.key] == entry.value);
}
