import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/data_migration/data_migration_coordinator.dart';
import 'features/learning/learning_progress_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  await DataMigrationCoordinator(preferences).migrate();

  runApp(
    ChangeNotifierProvider(
      create: (_) => LearningProgressProvider(preferences),
      child: const HanGeoleumDigitalApp(enableOnboarding: true),
    ),
  );
}
