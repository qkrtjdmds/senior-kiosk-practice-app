import 'dart:async';

import 'reward_catalog.dart';
import 'reward_models.dart';
import 'reward_repository.dart';

typedef RewardClock = DateTime Function();

enum RewardUnlockStatus {
  unlocked,
  noNewRewards,
  alreadyCurrent,
  futureVersion,
  saveFailed,
}

class RewardUnlockResult {
  const RewardUnlockResult({
    required this.status,
    required this.state,
    this.newRewardIds = const <String>[],
    this.error,
  });

  final RewardUnlockStatus status;
  final RewardState state;
  final List<String> newRewardIds;
  final Object? error;

  bool get succeeded =>
      status != RewardUnlockStatus.futureVersion &&
      status != RewardUnlockStatus.saveFailed;
}

class RewardUnlockService {
  RewardUnlockService(
    this._repository, {
    RewardCatalog? catalog,
    RewardClock? clock,
  }) : catalog = catalog ?? _repository.catalog,
       _clock = clock ?? DateTime.now;

  final RewardRepository _repository;
  final RewardCatalog catalog;
  final RewardClock _clock;
  Future<void> _queue = Future<void>.value();

  Future<RewardUnlockResult> reconcile(
    int points, {
    bool markRetroactiveGrantCompleted = false,
  }) {
    final completer = Completer<RewardUnlockResult>();
    _queue = _queue.then((_) async {
      try {
        completer.complete(
          await _reconcile(
            points,
            markRetroactiveGrantCompleted: markRetroactiveGrantCompleted,
          ),
        );
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }

  Future<List<RewardDefinition>> pendingRewards() async {
    final state = await _repository.load();
    final pendingIds = state.unlockedRewardIds.difference(
      state.celebratedRewardIds,
    );
    return List<RewardDefinition>.unmodifiable(
      catalog.definitions.where(
        (reward) => pendingIds.contains(reward.rewardId),
      ),
    );
  }

  Future<RewardUnlockResult> _reconcile(
    int points, {
    required bool markRetroactiveGrantCompleted,
  }) async {
    RewardState state;
    try {
      state = await _repository.load();
    } catch (error) {
      return RewardUnlockResult(
        status: RewardUnlockStatus.saveFailed,
        state: RewardState.empty(),
        error: error,
      );
    }
    if (state.dataVersion > RewardRepository.currentDataVersion ||
        state.catalogVersion > catalog.version) {
      return RewardUnlockResult(
        status: RewardUnlockStatus.futureVersion,
        state: state,
      );
    }

    final normalizedPoints = points < 0 ? 0 : points;
    final eligibleIds = catalog
        .availableAt(normalizedPoints)
        .map((reward) => reward.rewardId)
        .toSet();
    final newIds = eligibleIds.difference(state.unlockedRewardIds);
    final shouldMarkRetroactive =
        markRetroactiveGrantCompleted && !state.retroactiveGrantCompleted;
    if (newIds.isEmpty && !shouldMarkRetroactive) {
      return RewardUnlockResult(
        status: RewardUnlockStatus.alreadyCurrent,
        state: state,
      );
    }

    final orderedNewIds = catalog.definitions
        .where((reward) => newIds.contains(reward.rewardId))
        .map((reward) => reward.rewardId)
        .toList(growable: false);
    final unlockedAt = Map<String, DateTime>.of(state.unlockedAtByRewardId);
    if (orderedNewIds.isNotEmpty) {
      final unlockedAtNow = _clock().toUtc();
      for (final rewardId in orderedNewIds) {
        unlockedAt.putIfAbsent(rewardId, () => unlockedAtNow);
      }
    }
    final updated = state.copyWith(
      unlockedRewardIds: {...state.unlockedRewardIds, ...orderedNewIds},
      unlockedAtByRewardId: unlockedAt,
      retroactiveGrantCompleted:
          state.retroactiveGrantCompleted || markRetroactiveGrantCompleted,
    );

    try {
      await _repository.save(updated);
      final stored = await _repository.load();
      return RewardUnlockResult(
        status: orderedNewIds.isEmpty
            ? RewardUnlockStatus.noNewRewards
            : RewardUnlockStatus.unlocked,
        state: stored,
        newRewardIds: orderedNewIds,
      );
    } catch (error) {
      return RewardUnlockResult(
        status: RewardUnlockStatus.saveFailed,
        state: state,
        newRewardIds: orderedNewIds,
        error: error,
      );
    }
  }
}
