enum DataMigrationStatus {
  migrated,
  alreadyCurrent,
  recovered,
  futureVersion,
  failed,
}

enum MigrationCheckpoint {
  afterPendingRecorded,
  afterRevisionWrites,
  beforeCompletedRevisionRecorded,
  beforeSchemaVersionRecorded,
  beforePendingCleared,
}

typedef MigrationCheckpointHook =
    Future<void> Function(MigrationCheckpoint checkpoint, int revision);

class MigrationRevisionResult {
  const MigrationRevisionResult({this.recoveredKeys = const <String>[]});

  final List<String> recoveredKeys;
}

class DataMigrationResult {
  const DataMigrationResult({
    required this.status,
    required this.initialSchemaVersion,
    required this.finalSchemaVersion,
    this.appliedRevisions = const <int>[],
    this.recoveredKeys = const <String>[],
    this.errorType,
    this.errorMessage,
  });

  final DataMigrationStatus status;
  final int initialSchemaVersion;
  final int finalSchemaVersion;
  final List<int> appliedRevisions;
  final List<String> recoveredKeys;
  final String? errorType;
  final String? errorMessage;

  bool get succeeded =>
      status != DataMigrationStatus.failed &&
      status != DataMigrationStatus.futureVersion;
}
