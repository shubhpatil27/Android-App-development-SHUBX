import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database_service.dart';
import 'preferences_service.dart';

class CloudSyncService {
  CloudSyncService._();

  static final CloudSyncService instance =
  CloudSyncService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  static const _tables = [
    'workouts',
    'workout_exercises',
    'exercise_sets',
    'walking_sessions',
    'running_sessions',
    'cardio_sessions',
    'hyrox_sessions',
    'hyrox_splits',
    'hyrox_training_sessions',
    'hyrox_training_segments',
  ];

  User get _user {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError(
        'No Firebase user is signed in.',
      );
    }

    return user;
  }

  DocumentReference<Map<String, dynamic>>
  get _backupDocument {
    return _firestore
        .collection('users')
        .doc(_user.uid)
        .collection('shubx')
        .doc('backup');
  }

  // ==================================================
  // BACKUP
  // ==================================================

  Future<CloudSyncResult> backup() async {
    final db =
    await DatabaseService.instance.database;

    final preferences =
    await PreferencesService.instance
        .loadPreferences();

    final tables =
    <String, dynamic>{};

    for (final table in _tables) {
      final rows =
      await db.query(table);

      tables[table] =
          rows.map(
                (row) {
              return Map<String, dynamic>.from(
                row,
              );
            },
          ).toList();
    }

    final workoutCount =
        (tables['workouts'] as List).length;

    final data =
    <String, dynamic>{
      'version': 1,
      'uid': _user.uid,
      'email': _user.email,
      'updatedAt':
      FieldValue.serverTimestamp(),
      'workoutCount': workoutCount,
      'preferences':
      preferences == null
          ? null
          : {
        'trainingTypes':
        preferences
            .trainingTypes
            .toList(),
        'goals':
        preferences.goals
            .toList(),
        'weeklyTarget':
        preferences
            .weeklyTarget,
        'weightUnit':
        preferences
            .weightUnit,
        'distanceUnit':
        preferences
            .distanceUnit,
        'heightCm':
        preferences
            .heightCm,
        'weightKg':
        preferences
            .weightKg,
      },
      'tables': tables,
    };

    await _backupDocument.set(
      data,
      SetOptions(
        merge: false,
      ),
    );

    await _saveLastSyncNow();

    return CloudSyncResult(
      workoutCount: workoutCount,
      syncedAt: DateTime.now(),
    );
  }

  // ==================================================
  // CLOUD INFO
  // ==================================================

  Future<CloudBackupInfo?>
  getBackupInfo() async {
    final snapshot =
    await _backupDocument.get();

    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();

    if (data == null) {
      return null;
    }

    final timestamp =
    data['updatedAt'];

    DateTime? updatedAt;

    if (timestamp is Timestamp) {
      updatedAt =
          timestamp.toDate();
    }

    return CloudBackupInfo(
      workoutCount:
      (data['workoutCount']
      as num?)
          ?.toInt() ??
          0,
      updatedAt: updatedAt,
    );
  }

  // ==================================================
  // RESTORE
  // ==================================================

  Future<CloudSyncResult>
  restore() async {
    final snapshot =
    await _backupDocument.get();

    if (!snapshot.exists) {
      throw StateError(
        'No SHUBX cloud backup exists for this account.',
      );
    }

    final data = snapshot.data();

    if (data == null) {
      throw StateError(
        'Cloud backup is empty.',
      );
    }

    if (data['uid'] != _user.uid) {
      throw StateError(
        'Cloud backup does not belong to this account.',
      );
    }

    final tablesRaw =
    data['tables'];

    if (tablesRaw is! Map) {
      throw StateError(
        'Cloud backup is invalid.',
      );
    }

    final db =
    await DatabaseService.instance.database;

    await db.transaction(
          (txn) async {
        // Child tables first because foreign
        // keys are enabled.
        const deleteOrder = [
          'exercise_sets',
          'workout_exercises',
          'walking_sessions',
          'running_sessions',
          'cardio_sessions',
          'hyrox_splits',
          'hyrox_sessions',
          'hyrox_training_segments',
          'hyrox_training_sessions',
          'workouts',
        ];

        for (final table
        in deleteOrder) {
          await txn.delete(table);
        }

        // Parents first during restore.
        const insertOrder = [
          'workouts',
          'workout_exercises',
          'exercise_sets',
          'walking_sessions',
          'running_sessions',
          'cardio_sessions',
          'hyrox_sessions',
          'hyrox_splits',
          'hyrox_training_sessions',
          'hyrox_training_segments',
        ];

        for (final table
        in insertOrder) {
          final rawRows =
          tablesRaw[table];

          if (rawRows is! List) {
            continue;
          }

          for (final rawRow
          in rawRows) {
            if (rawRow is! Map) {
              continue;
            }

            final row =
            <String, Object?>{};

            for (final entry
            in rawRow.entries) {
              row[
              entry.key
                  .toString()] =
                  entry.value;
            }

            await txn.insert(
              table,
              row,
            );
          }
        }
      },
    );

    await _restorePreferences(
      data['preferences'],
    );

    await _saveLastSyncNow();

    final workoutCount =
        (data['workoutCount']
        as num?)
            ?.toInt() ??
            0;

    return CloudSyncResult(
      workoutCount: workoutCount,
      syncedAt: DateTime.now(),
    );
  }

  // ==================================================
  // PREFERENCES RESTORE
  // ==================================================

  Future<void> _restorePreferences(
      dynamic raw,
      ) async {
    if (raw is! Map) {
      return;
    }

    final trainingTypesRaw =
    raw['trainingTypes'];

    final goalsRaw =
    raw['goals'];

    final trainingTypes =
    trainingTypesRaw is List
        ? trainingTypesRaw
        .map(
          (value) =>
          value.toString(),
    )
        .toSet()
        : <String>{};

    if (trainingTypes.isEmpty) {
      return;
    }

    final goals =
    goalsRaw is List
        ? goalsRaw
        .map(
          (value) =>
          value.toString(),
    )
        .toSet()
        : <String>{};

    final preferences =
    await PreferencesService.instance
        .preferencesFromCloud(
      trainingTypes:
      trainingTypes,
      goals: goals,
      weeklyTarget:
      (raw['weeklyTarget']
      as num?)
          ?.toInt() ??
          4,
      weightUnit:
      raw['weightUnit']
          ?.toString() ??
          'lb',
      distanceUnit:
      raw['distanceUnit']
          ?.toString() ??
          'mi',
      heightCm:
      (raw['heightCm']
      as num?)
          ?.toDouble(),
      weightKg:
      (raw['weightKg']
      as num?)
          ?.toDouble(),
    );

    await PreferencesService.instance
        .savePreferences(
      preferences,
    );
  }

  // ==================================================
  // LAST SYNC
  // ==================================================

  Future<void> _saveLastSyncNow() async {
    final prefs =
    await SharedPreferences
        .getInstance();

    await prefs.setString(
      _lastSyncKey,
      DateTime.now()
          .toIso8601String(),
    );
  }

  String get _lastSyncKey =>
      'last_cloud_sync_${_user.uid}';

  Future<DateTime?>
  getLastLocalSync() async {
    final prefs =
    await SharedPreferences
        .getInstance();

    final raw =
    prefs.getString(
      _lastSyncKey,
    );

    if (raw == null) {
      return null;
    }

    return DateTime.tryParse(raw);
  }
}

class CloudSyncResult {
  final int workoutCount;
  final DateTime syncedAt;

  const CloudSyncResult({
    required this.workoutCount,
    required this.syncedAt,
  });
}

class CloudBackupInfo {
  final int workoutCount;
  final DateTime? updatedAt;

  const CloudBackupInfo({
    required this.workoutCount,
    required this.updatedAt,
  });
}