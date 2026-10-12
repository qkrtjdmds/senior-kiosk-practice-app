import 'package:shared_preferences/shared_preferences.dart';

import 'data_migration_models.dart';
import 'migration_store.dart';
import 'preference_keys.dart';
import 'v3_foundation_revision.dart';

class DataMigrationCoordinator {
  DataMigrationCoordinator(
    SharedPreferences preferences, {
    MigrationCheckpointHook? checkpointHook,
    List<DataMigrationRevision>? revisions,
  }) : this.withStore(
         SharedPreferencesMigrationStore(preferences),
         checkpointHook: checkpointHook,
         revisions: revisions,
       );

  DataMigrationCoordinator.withStore(
    this._store, {
    MigrationCheckpointHook? checkpointHook,
    List<DataMigrationRevision>? revisions,
  }) : _checkpointHook = checkpointHook,
       _revisions = List.unmodifiable(
         revisions ?? const <DataMigrationRevision>[V3FoundationRevision()],
       );

  static const currentSchemaVersion = V3FoundationRevision.versionValue;
  static const supportedRevisionIds = <String>[V3FoundationRevision.idValue];

  final MigrationStore _store;
  final MigrationCheckpointHook? _checkpointHook;
  final List<DataMigrationRevision> _revisions;

  Future<DataMigrationResult> migrate() async {
    final rawSchema = _store.read(V3DataKeys.schemaVersion);
    if (rawSchema is int && rawSchema > currentSchemaVersion) {
      return DataMigrationResult(
        status: DataMigrationStatus.futureVersion,
        initialSchemaVersion: rawSchema,
        finalSchemaVersion: rawSchema,
      );
    }

    final schemaWasCorrupted =
        rawSchema != null && (rawSchema is! int || rawSchema < 0);
    var schemaVersion = rawSchema is int && rawSchema >= 0 ? rawSchema : 0;
    final initialSchemaVersion = schemaVersion;
    final completedRead = _readCompletedRevisions();
    final completed = completedRead.revisions;
    final pendingRead = _readPendingRevision();
    if (pendingRead.futureRevision != null) {
      return DataMigrationResult(
        status: DataMigrationStatus.futureVersion,
        initialSchemaVersion: initialSchemaVersion,
        finalSchemaVersion: schemaVersion,
      );
    }

    final recoveredKeys = <String>[];
    var recoveredMetadata =
        schemaWasCorrupted ||
        completedRead.wasCorrupted ||
        pendingRead.wasCorrupted;
    if (schemaWasCorrupted) recoveredKeys.add(V3DataKeys.schemaVersion);
    if (completedRead.wasCorrupted) {
      recoveredKeys.add(V3DataKeys.completedRevisions);
    }
    if (pendingRead.wasCorrupted) {
      recoveredKeys.add(V3DataKeys.pendingRevision);
    }

    final applied = <int>[];
    try {
      if (pendingRead.wasCorrupted) {
        await _store.remove(V3DataKeys.pendingRevision);
      }
      if (completedRead.wasCorrupted) {
        await _store.writeStringList(
          V3DataKeys.completedRevisions,
          _orderedCompletedRevisions(completed),
        );
      }
      final orderedRevisions = [..._revisions]
        ..sort((a, b) => a.version.compareTo(b.version));
      for (final revision in orderedRevisions) {
        if (revision.version > currentSchemaVersion) continue;
        final alreadyCompleted = completed.contains(revision.id);
        if (alreadyCompleted) {
          if (schemaVersion < revision.version) {
            await _store.writeInt(V3DataKeys.schemaVersion, revision.version);
            await _store.writeInt(
              V3DataKeys.lastSuccessRevision,
              revision.version,
            );
            schemaVersion = revision.version;
            recoveredMetadata = true;
          }
          if (pendingRead.revision == revision.version) {
            await _store.remove(V3DataKeys.pendingRevision);
            recoveredMetadata = true;
          }
          continue;
        }

        await _store.writeInt(V3DataKeys.pendingRevision, revision.version);
        await _checkpoint(MigrationCheckpoint.afterPendingRecorded, revision);

        final result = await revision.apply(_store);
        recoveredKeys.addAll(result.recoveredKeys);
        await _checkpoint(MigrationCheckpoint.afterRevisionWrites, revision);

        if (!revision.verify(_store)) {
          throw StateError('Migration verification failed.');
        }
        await _checkpoint(
          MigrationCheckpoint.beforeCompletedRevisionRecorded,
          revision,
        );

        completed.add(revision.id);
        await _store.writeStringList(
          V3DataKeys.completedRevisions,
          _orderedCompletedRevisions(completed),
        );
        await _checkpoint(
          MigrationCheckpoint.beforeSchemaVersionRecorded,
          revision,
        );

        await _store.writeInt(V3DataKeys.schemaVersion, revision.version);
        await _store.writeInt(V3DataKeys.lastSuccessRevision, revision.version);
        schemaVersion = revision.version;
        await _checkpoint(MigrationCheckpoint.beforePendingCleared, revision);

        await _store.remove(V3DataKeys.pendingRevision);
        applied.add(revision.version);
      }

      final status = recoveredKeys.isNotEmpty || recoveredMetadata
          ? DataMigrationStatus.recovered
          : applied.isNotEmpty
          ? DataMigrationStatus.migrated
          : DataMigrationStatus.alreadyCurrent;
      await _store.writeString(V3DataKeys.lastOutcome, status.name);
      return DataMigrationResult(
        status: status,
        initialSchemaVersion: initialSchemaVersion,
        finalSchemaVersion: schemaVersion,
        appliedRevisions: applied,
        recoveredKeys: recoveredKeys.toSet().toList(growable: false),
      );
    } catch (error) {
      try {
        await _store.writeString(
          V3DataKeys.lastOutcome,
          DataMigrationStatus.failed.name,
        );
      } catch (_) {
        // The pending revision remains the recovery marker for the next start.
      }
      return DataMigrationResult(
        status: DataMigrationStatus.failed,
        initialSchemaVersion: initialSchemaVersion,
        finalSchemaVersion: schemaVersion,
        appliedRevisions: applied,
        recoveredKeys: recoveredKeys.toSet().toList(growable: false),
        errorType: error.runtimeType.toString(),
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> _checkpoint(
    MigrationCheckpoint checkpoint,
    DataMigrationRevision revision,
  ) async {
    await _checkpointHook?.call(checkpoint, revision.version);
  }

  _CompletedRevisionsRead _readCompletedRevisions() {
    final raw = _store.read(V3DataKeys.completedRevisions);
    if (raw == null) {
      return _CompletedRevisionsRead(revisions: <String>{});
    }
    final values = raw is List<String>
        ? raw
        : raw is List && raw.every((item) => item is String)
        ? raw.cast<String>()
        : null;
    if (values == null) {
      return _CompletedRevisionsRead(revisions: <String>{}, wasCorrupted: true);
    }
    final supported = _revisions.map((item) => item.id).toSet();
    final wasCorrupted =
        values.any((id) => !supported.contains(id)) ||
        values.length != values.toSet().length;
    return _CompletedRevisionsRead(
      revisions: values.where(supported.contains).toSet(),
      wasCorrupted: wasCorrupted,
    );
  }

  _PendingRevisionRead _readPendingRevision() {
    final raw = _store.read(V3DataKeys.pendingRevision);
    if (raw == null) return const _PendingRevisionRead();
    if (raw is! int || raw < 1) {
      return const _PendingRevisionRead(wasCorrupted: true);
    }
    if (raw > currentSchemaVersion) {
      return _PendingRevisionRead(futureRevision: raw);
    }
    return _PendingRevisionRead(revision: raw);
  }

  List<String> _orderedCompletedRevisions(Set<String> completed) {
    return _revisions
        .where((revision) => completed.contains(revision.id))
        .map((revision) => revision.id)
        .toList(growable: false);
  }
}

class _CompletedRevisionsRead {
  const _CompletedRevisionsRead({
    required this.revisions,
    this.wasCorrupted = false,
  });

  final Set<String> revisions;
  final bool wasCorrupted;
}

class _PendingRevisionRead {
  const _PendingRevisionRead({
    this.revision,
    this.futureRevision,
    this.wasCorrupted = false,
  });

  final int? revision;
  final int? futureRevision;
  final bool wasCorrupted;
}
