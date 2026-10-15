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

  RewardState get state => _state;
  bool get isLoading => _isLoading;
  int get currentPoints => _progress.totalPoints;

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
    if (isApplied(reward)) return '적용 중';
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

  void _handleProgressChanged() {
    unawaited(refresh());
  }

  RewardDefinition? _definitionIfUnlocked(String? rewardId) {
    if (rewardId == null || !_state.unlockedRewardIds.contains(rewardId)) {
      return null;
    }
    return catalog.byId(rewardId);
  }

  @override
  void dispose() {
    _disposed = true;
    _progress.removeListener(_handleProgressChanged);
    super.dispose();
  }
}
