import 'dart:async';

import 'package:flutter/foundation.dart';

import '../learning/learning_progress_provider.dart';
import 'reward_catalog.dart';
import 'reward_models.dart';
import 'reward_repository.dart';

class RewardProgressProvider extends ChangeNotifier {
  RewardProgressProvider({
    required RewardRepository repository,
    required LearningProgressProvider progress,
  }) : _repository = repository,
       _progress = progress,
       catalog = repository.catalog {
    _progress.addListener(_handleProgressChanged);
    unawaited(refresh());
  }

  final RewardRepository _repository;
  final LearningProgressProvider _progress;
  final RewardCatalog catalog;

  RewardState _state = RewardState.empty();
  bool _isLoading = true;
  bool _disposed = false;
  int _refreshGeneration = 0;
  Future<void> _selectionQueue = Future.value();
  String? _selectionMessage;

  RewardState get state => _state;
  bool get isLoading => _isLoading;
  int get currentPoints => _progress.totalPoints;
  String? get selectionMessage => _selectionMessage;

  RewardDefinition? get selectedTitle =>
      _definitionIfUnlocked(_state.selectedTitleId);

  RewardDefinition? get selectedTheme =>
      _definitionIfUnlocked(_state.selectedThemeId);

  Set<String> get selectedAccessoryIds => _state.selectedAccessoryIds;

  String get selectedThemeName => selectedTheme?.title ?? '기본 아이보리';

  List<RewardDefinition> get activeRewards =>
      List.unmodifiable(catalog.definitions.where((reward) => reward.isActive));

  List<RewardDefinition> get unlockedRewards => List.unmodifiable(
    activeRewards.where(
      (reward) => _state.unlockedRewardIds.contains(reward.rewardId),
    ),
  );

  List<RewardDefinition> get lockedRewards => List.unmodifiable(
    activeRewards.where(
      (reward) => !_state.unlockedRewardIds.contains(reward.rewardId),
    ),
  );

  int get unlockedCount => unlockedRewards.length;
  int get totalRewardCount => activeRewards.length;

  List<RewardDefinition> get nextRewards => catalog
      .rewardsAtNextThreshold(currentPoints)
      .where((reward) => reward.isActive)
      .toList(growable: false);

  int? get nextRequiredPoints =>
      nextRewards.isEmpty ? null : nextRewards.first.requiredPoints;

  int get pointsUntilNextReward {
    final target = nextRequiredPoints;
    if (target == null) return 0;
    return (target - currentPoints).clamp(0, target);
  }

  double get progressToNextReward {
    final target = nextRequiredPoints;
    if (target == null) return 1;
    if (target <= 0) return 1;
    return (currentPoints / target).clamp(0, 1).toDouble();
  }

  String get nextRewardName {
    if (nextRewards.isEmpty) return '모든 성장 보상을 획득했어요';
    if (nextRewards.length == 1) return nextRewards.first.title;
    return '${nextRewards.first.title} 외 ${nextRewards.length - 1}개';
  }

  String get currentGrowthStage {
    final selected = _definitionIfUnlocked(_state.selectedTitleId);
    if (selected?.rewardType == RewardType.title) return selected!.title;

    RewardDefinition? latestTitle;
    for (final reward in unlockedRewards) {
      if (reward.rewardType == RewardType.title) latestTitle = reward;
    }
    return latestTitle?.title ?? '첫걸음 준비 중';
  }

  bool isUnlocked(RewardDefinition reward) =>
      _state.unlockedRewardIds.contains(reward.rewardId);

  bool isApplied(RewardDefinition reward) {
    return switch (reward.rewardType) {
      RewardType.title => _state.selectedTitleId == reward.rewardId,
      RewardType.accessory => _state.selectedAccessoryIds.contains(
        reward.rewardId,
      ),
      RewardType.theme => _state.selectedThemeId == reward.rewardId,
      RewardType.expression || RewardType.unknown => false,
    };
  }

  String statusFor(RewardDefinition reward) {
    if (isApplied(reward)) {
      return reward.rewardType == RewardType.accessory ? '착용 중' : '적용 중';
    }
    if (isUnlocked(reward)) return '획득';
    return '${(reward.requiredPoints - currentPoints).clamp(0, reward.requiredPoints)}점 더 필요';
  }

  Future<void> refresh() async {
    final generation = ++_refreshGeneration;
    final loaded = await _repository.load();
    if (_disposed || generation != _refreshGeneration) return;
    _state = loaded;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> selectTitle(String? rewardId) => _enqueueSelection(() async {
    if (_state.selectedTitleId == rewardId) return null;
    final state = await _repository.selectTitle(rewardId);
    return (state, rewardId == null ? '칭호 사용을 해제했어요' : '칭호를 바꿨어요');
  });

  Future<bool> toggleAccessory(String rewardId) => _enqueueSelection(() async {
    final selected = Set<String>.of(_state.selectedAccessoryIds);
    final removing = selected.remove(rewardId);
    if (!removing) {
      final slot = rewardAccessorySlot(rewardId);
      if (slot == null) throw StateError('지원하지 않는 장식입니다.');
      selected.removeWhere((id) => rewardAccessorySlot(id) == slot);
      selected.add(rewardId);
    }
    final state = await _repository.selectAccessories(selected);
    final name = _accessoryFeedbackName(rewardId);
    return (state, removing ? '$name 벗었어요' : '$name 착용했어요');
  });

  Future<bool> clearAccessories() => _enqueueSelection(() async {
    if (_state.selectedAccessoryIds.isEmpty) return null;
    final state = await _repository.selectAccessories({});
    return (state, '장식을 모두 벗었어요');
  });

  Future<bool> selectTheme(String? rewardId) => _enqueueSelection(() async {
    if (_state.selectedThemeId == rewardId) return null;
    final state = await _repository.selectTheme(rewardId);
    return (state, rewardId == null ? '기본 화면으로 바꿨어요' : '홈 테마를 바꿨어요');
  });

  Future<bool> _enqueueSelection(
    Future<(RewardState, String)?> Function() operation,
  ) {
    final result = Completer<bool>();
    _selectionQueue = _selectionQueue.then((_) async {
      try {
        final change = await operation();
        if (change == null) {
          result.complete(true);
          return;
        }
        _state = change.$1;
        _selectionMessage = change.$2;
        if (!_disposed) notifyListeners();
        result.complete(true);
      } catch (_) {
        _selectionMessage = '저장하지 못했어요. 이전 상태를 유지했어요.';
        if (!_disposed) notifyListeners();
        result.complete(false);
      }
    });
    return result.future;
  }

  void _handleProgressChanged() {
    unawaited(refresh());
  }

  RewardDefinition? _definitionIfUnlocked(String? rewardId) {
    if (rewardId == null || !_state.unlockedRewardIds.contains(rewardId)) {
      return null;
    }
    return catalog.byId(rewardId);
  }

  String _accessoryFeedbackName(String rewardId) => switch (rewardId) {
    'accessory_scarf' => '목도리를',
    'accessory_hat' => '모자를',
    'accessory_glasses' => '안경을',
    'accessory_bag' => '가방을',
    _ => '장식을',
  };

  @override
  void dispose() {
    _disposed = true;
    _progress.removeListener(_handleProgressChanged);
    super.dispose();
  }
}
