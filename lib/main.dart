import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/data_migration/data_migration_coordinator.dart';
import 'core/data_migration/preference_keys.dart';
import 'features/learning/learning_progress_provider.dart';
import 'features/rewards/reward_repository.dart';
import 'features/rewards/reward_unlock_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final migration = await DataMigrationCoordinator(preferences).migrate();
  final rewardUnlockService = RewardUnlockService(
    RewardRepository(preferences),
  );
  if (migration.succeeded) {
    await rewardUnlockService.reconcile(
      preferences.getInt(V2PreferenceKeys.points) ?? 0,
    );
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => LearningProgressProvider(
        preferences,
        rewardUnlockService: rewardUnlockService,
      ),
      child: const HanGeoleumDigitalApp(enableOnboarding: true),
    ),
  );
}
