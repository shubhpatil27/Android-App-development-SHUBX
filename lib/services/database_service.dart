import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/cardio_session.dart';
import '../models/exercise_set.dart';
import '../models/hyrox_session.dart';
import '../models/hyrox_training_session.dart';
import '../models/running_session.dart';
import '../models/walking_session.dart';
import '../models/workout.dart';
import '../models/workout_exercise.dart';

class DatabaseService {
  DatabaseService._internal();

  static final DatabaseService instance =
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(
      databasePath,
      'shubx.db',
    );

    return openDatabase(
      path,
      version: 7,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
      onConfigure: (db) async {
        await db.execute(
          'PRAGMA foreign_keys = ON',
        );
      },
    );
  }

  // ==================================================
  // DATABASE CREATION
  // ==================================================

  Future<void> _createDatabase(
      Database db,
      int version,
      ) async {
    await _createWorkoutTable(db);
    await _createWeightTrainingTables(db);
    await _createWalkingTable(db);
    await _createRunningTable(db);
    await _createCardioTable(db);
    await _createHyroxTables(db);
    await _createHyroxTrainingTables(db);
  }

  Future<void> _upgradeDatabase(
      Database db,
      int oldVersion,
      int newVersion,
      ) async {
    if (oldVersion < 2) {
      await _createWeightTrainingTables(db);
    }

    if (oldVersion < 3) {
      await _createWalkingTable(db);
    }

    if (oldVersion < 4) {
      await _createRunningTable(db);
    }

    if (oldVersion < 5) {
      await _createCardioTable(db);
    }

    if (oldVersion < 6) {
      await _createHyroxTables(db);
    }

    if (oldVersion < 7) {
      await _createHyroxTrainingTables(db);
    }
  }

  // ==================================================
  // TABLES
  // ==================================================

  Future<void> _createWorkoutTable(
      Database db,
      ) async {
    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        completed INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createWeightTrainingTables(
      Database db,
      ) async {
    await db.execute('''
      CREATE TABLE workout_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER NOT NULL,
        exercise_id TEXT NOT NULL,
        exercise_name TEXT NOT NULL,
        primary_muscle TEXT NOT NULL,
        tracking_type TEXT NOT NULL,
        exercise_order INTEGER NOT NULL,

        FOREIGN KEY (workout_id)
          REFERENCES workouts(id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE exercise_sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_exercise_id INTEGER NOT NULL,
        set_number INTEGER NOT NULL,
        weight_kg REAL,
        reps INTEGER,
        duration_seconds INTEGER,
        distance_meters REAL,

        FOREIGN KEY (workout_exercise_id)
          REFERENCES workout_exercises(id)
          ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createWalkingTable(
      Database db,
      ) async {
    await db.execute('''
      CREATE TABLE walking_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER NOT NULL UNIQUE,
        distance_meters REAL NOT NULL,
        duration_seconds INTEGER NOT NULL,
        estimated_steps INTEGER NOT NULL,
        height_cm REAL,

        FOREIGN KEY (workout_id)
          REFERENCES workouts(id)
          ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createRunningTable(
      Database db,
      ) async {
    await db.execute('''
      CREATE TABLE running_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER NOT NULL UNIQUE,
        distance_meters REAL NOT NULL,
        duration_seconds INTEGER NOT NULL,

        FOREIGN KEY (workout_id)
          REFERENCES workouts(id)
          ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createCardioTable(
      Database db,
      ) async {
    await db.execute('''
      CREATE TABLE cardio_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER NOT NULL UNIQUE,
        activity_type TEXT NOT NULL,
        distance_meters REAL,
        duration_seconds INTEGER NOT NULL,
        level REAL,
        floors INTEGER,
        reps INTEGER,
        rounds INTEGER,

        FOREIGN KEY (workout_id)
          REFERENCES workouts(id)
          ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createHyroxTables(
      Database db,
      ) async {
    await db.execute('''
      CREATE TABLE hyrox_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER NOT NULL UNIQUE,

        FOREIGN KEY (workout_id)
          REFERENCES workouts(id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE hyrox_splits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hyrox_session_id INTEGER NOT NULL,
        segment_number INTEGER NOT NULL,
        run_seconds INTEGER NOT NULL,
        station_name TEXT NOT NULL,
        station_seconds INTEGER NOT NULL,

        FOREIGN KEY (hyrox_session_id)
          REFERENCES hyrox_sessions(id)
          ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createHyroxTrainingTables(
      Database db,
      ) async {
    await db.execute('''
      CREATE TABLE hyrox_training_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER NOT NULL UNIQUE,

        FOREIGN KEY (workout_id)
          REFERENCES workouts(id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE hyrox_training_segments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        segment_type TEXT NOT NULL,
        segment_name TEXT NOT NULL,
        segment_order INTEGER NOT NULL,
        duration_seconds INTEGER NOT NULL,

        FOREIGN KEY (session_id)
          REFERENCES hyrox_training_sessions(id)
          ON DELETE CASCADE
      )
    ''');
  }

  // ==================================================
  // WORKOUT CRUD
  // ==================================================

  Future<Workout> insertWorkout(
      Workout workout,
      ) async {
    final db = await database;

    final map = workout.toMap();
    map.remove('id');

    final id = await db.insert(
      'workouts',
      map,
    );

    return workout.copyWith(
      id: id,
    );
  }

  Future<List<Workout>> getAllWorkouts() async {
    final db = await database;

    final result = await db.query(
      'workouts',
      orderBy: 'date DESC',
    );

    return result
        .map(Workout.fromMap)
        .toList();
  }

  Future<Workout?> getWorkoutById(
      int id,
      ) async {
    final db = await database;

    final result = await db.query(
      'workouts',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return Workout.fromMap(
      result.first,
    );
  }

  Future<List<Workout>> getWorkoutsBetween(
      DateTime start,
      DateTime end,
      ) async {
    final db = await database;

    final result = await db.query(
      'workouts',
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        start.toIso8601String(),
        end.toIso8601String(),
      ],
      orderBy: 'date DESC',
    );

    return result
        .map(Workout.fromMap)
        .toList();
  }

  Future<List<Workout>> getWorkoutsByType(
      String type,
      ) async {
    final db = await database;

    final result = await db.query(
      'workouts',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );

    return result
        .map(Workout.fromMap)
        .toList();
  }

  Future<void> updateWorkout(
      Workout workout,
      ) async {
    if (workout.id == null) {
      throw ArgumentError(
        'Workout must have an ID.',
      );
    }

    final db = await database;

    await db.update(
      'workouts',
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [workout.id],
    );
  }

  Future<void> deleteWorkout(
      int id,
      ) async {
    final db = await database;

    await db.delete(
      'workouts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================================================
  // WEIGHT TRAINING
  // ==================================================

  Future<WorkoutExercise> insertWorkoutExercise(
      WorkoutExercise exercise,
      ) async {
    final db = await database;

    final map = exercise.toMap();
    map.remove('id');

    final id = await db.insert(
      'workout_exercises',
      map,
    );

    return exercise.copyWith(
      id: id,
    );
  }

  Future<void> insertExerciseSet(
      ExerciseSet exerciseSet,
      ) async {
    final db = await database;

    final map = exerciseSet.toMap();
    map.remove('id');

    await db.insert(
      'exercise_sets',
      map,
    );
  }

  Future<List<WorkoutExercise>>
  getExercisesForWorkout(
      int workoutId,
      ) async {
    final db = await database;

    final result = await db.query(
      'workout_exercises',
      where: 'workout_id = ?',
      whereArgs: [workoutId],
      orderBy: 'exercise_order ASC',
    );

    return result
        .map(WorkoutExercise.fromMap)
        .toList();
  }

  Future<List<ExerciseSet>>
  getSetsForWorkoutExercise(
      int workoutExerciseId,
      ) async {
    final db = await database;

    final result = await db.query(
      'exercise_sets',
      where: 'workout_exercise_id = ?',
      whereArgs: [workoutExerciseId],
      orderBy: 'set_number ASC',
    );

    return result
        .map(ExerciseSet.fromMap)
        .toList();
  }

  Future<void> replaceWeightWorkoutDetails({
    required Workout workout,
    required List<WorkoutExerciseEditData>
    exercises,
  }) async {
    if (workout.id == null) {
      throw ArgumentError(
        'Workout must have an ID.',
      );
    }

    final db = await database;

    await db.transaction(
          (txn) async {
        await txn.update(
          'workouts',
          workout.toMap(),
          where: 'id = ?',
          whereArgs: [workout.id],
        );

        await txn.delete(
          'workout_exercises',
          where: 'workout_id = ?',
          whereArgs: [workout.id],
        );

        for (int i = 0;
        i < exercises.length;
        i++) {
          final item = exercises[i];

          final workoutExerciseId =
          await txn.insert(
            'workout_exercises',
            {
              'workout_id': workout.id,
              'exercise_id':
              item.exerciseId,
              'exercise_name':
              item.exerciseName,
              'primary_muscle':
              item.primaryMuscle,
              'tracking_type':
              item.trackingType,
              'exercise_order': i,
            },
          );

          for (int j = 0;
          j < item.sets.length;
          j++) {
            final set = item.sets[j];

            await txn.insert(
              'exercise_sets',
              {
                'workout_exercise_id':
                workoutExerciseId,
                'set_number': j + 1,
                'weight_kg':
                set.weightKg,
                'reps': set.reps,
                'duration_seconds':
                set.durationSeconds,
                'distance_meters':
                set.distanceMeters,
              },
            );
          }
        }
      },
    );
  }

  // ==================================================
  // WALKING
  // ==================================================

  Future<void> insertWalkingSession(
      WalkingSession session,
      ) async {
    final db = await database;

    final map = session.toMap();
    map.remove('id');

    await db.insert(
      'walking_sessions',
      map,
    );
  }

  Future<WalkingSession?>
  getWalkingSessionForWorkout(
      int workoutId,
      ) async {
    final db = await database;

    final result = await db.query(
      'walking_sessions',
      where: 'workout_id = ?',
      whereArgs: [workoutId],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return WalkingSession.fromMap(
      result.first,
    );
  }

  Future<void> updateWalkingSession({
    required Workout workout,
    required WalkingSession session,
  }) async {
    if (workout.id == null) {
      throw ArgumentError(
        'Workout must have an ID.',
      );
    }

    final db = await database;

    await db.transaction(
          (txn) async {
        await txn.update(
          'workouts',
          workout.toMap(),
          where: 'id = ?',
          whereArgs: [workout.id],
        );

        await txn.update(
          'walking_sessions',
          {
            'distance_meters':
            session.distanceMeters,
            'duration_seconds':
            session.durationSeconds,
            'estimated_steps':
            session.estimatedSteps,
            'height_cm':
            session.heightCm,
          },
          where: 'workout_id = ?',
          whereArgs: [workout.id],
        );
      },
    );
  }

  // ==================================================
  // RUNNING
  // ==================================================

  Future<void> insertRunningSession(
      RunningSession session,
      ) async {
    final db = await database;

    final map = session.toMap();
    map.remove('id');

    await db.insert(
      'running_sessions',
      map,
    );
  }

  Future<RunningSession?>
  getRunningSessionForWorkout(
      int workoutId,
      ) async {
    final db = await database;

    final result = await db.query(
      'running_sessions',
      where: 'workout_id = ?',
      whereArgs: [workoutId],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return RunningSession.fromMap(
      result.first,
    );
  }

  Future<void> updateRunningSession({
    required Workout workout,
    required RunningSession session,
  }) async {
    if (workout.id == null) {
      throw ArgumentError(
        'Workout must have an ID.',
      );
    }

    final db = await database;

    await db.transaction(
          (txn) async {
        await txn.update(
          'workouts',
          workout.toMap(),
          where: 'id = ?',
          whereArgs: [workout.id],
        );

        await txn.update(
          'running_sessions',
          {
            'distance_meters':
            session.distanceMeters,
            'duration_seconds':
            session.durationSeconds,
          },
          where: 'workout_id = ?',
          whereArgs: [workout.id],
        );
      },
    );
  }

  // ==================================================
  // GENERAL CARDIO
  // ==================================================

  Future<void> insertCardioSession(
      CardioSession session,
      ) async {
    final db = await database;

    final map = session.toMap();
    map.remove('id');

    await db.insert(
      'cardio_sessions',
      map,
    );
  }

  Future<CardioSession?>
  getCardioSessionForWorkout(
      int workoutId,
      ) async {
    final db = await database;

    final result = await db.query(
      'cardio_sessions',
      where: 'workout_id = ?',
      whereArgs: [workoutId],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return CardioSession.fromMap(
      result.first,
    );
  }

  Future<void> updateCardioSession({
    required Workout workout,
    required CardioSession session,
  }) async {
    if (workout.id == null) {
      throw ArgumentError(
        'Workout must have an ID.',
      );
    }

    final db = await database;

    await db.transaction(
          (txn) async {
        await txn.update(
          'workouts',
          workout.toMap(),
          where: 'id = ?',
          whereArgs: [workout.id],
        );

        await txn.update(
          'cardio_sessions',
          {
            'activity_type':
            session.activityType,
            'distance_meters':
            session.distanceMeters,
            'duration_seconds':
            session.durationSeconds,
            'level':
            session.level,
            'floors':
            session.floors,
            'reps':
            session.reps,
            'rounds':
            session.rounds,
          },
          where: 'workout_id = ?',
          whereArgs: [workout.id],
        );
      },
    );
  }

  // ==================================================
  // FULL HYROX
  // ==================================================

  Future<void> insertHyroxSession(
      HyroxSession session,
      ) async {
    if (session.runTimesSeconds.length != 8 ||
        session.stationTimesSeconds.length != 8) {
      throw ArgumentError(
        'HYROX requires exactly 8 runs and 8 stations.',
      );
    }

    const stations = [
      'SkiErg',
      'Sled Push',
      'Sled Pull',
      'Burpee Broad Jumps',
      'Rowing',
      'Farmers Carry',
      'Sandbag Lunges',
      'Wall Balls',
    ];

    final db = await database;

    await db.transaction(
          (txn) async {
        final sessionId =
        await txn.insert(
          'hyrox_sessions',
          {
            'workout_id':
            session.workoutId,
          },
        );

        for (int i = 0; i < 8; i++) {
          await txn.insert(
            'hyrox_splits',
            {
              'hyrox_session_id':
              sessionId,
              'segment_number':
              i + 1,
              'run_seconds':
              session
                  .runTimesSeconds[i],
              'station_name':
              stations[i],
              'station_seconds':
              session
                  .stationTimesSeconds[i],
            },
          );
        }
      },
    );
  }

  Future<HyroxSession?>
  getHyroxSessionForWorkout(
      int workoutId,
      ) async {
    final db = await database;

    final sessions = await db.query(
      'hyrox_sessions',
      where: 'workout_id = ?',
      whereArgs: [workoutId],
      limit: 1,
    );

    if (sessions.isEmpty) {
      return null;
    }

    final sessionId =
    sessions.first['id'] as int;

    final splits = await db.query(
      'hyrox_splits',
      where: 'hyrox_session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'segment_number ASC',
    );

    if (splits.length != 8) {
      return null;
    }

    return HyroxSession(
      id: sessionId,
      workoutId: workoutId,
      runTimesSeconds: splits
          .map(
            (row) =>
        row['run_seconds'] as int,
      )
          .toList(),
      stationTimesSeconds: splits
          .map(
            (row) =>
        row['station_seconds']
        as int,
      )
          .toList(),
    );
  }

  Future<void> updateHyroxSession({
    required Workout workout,
    required HyroxSession session,
  }) async {
    if (workout.id == null) {
      throw ArgumentError(
        'Workout must have an ID.',
      );
    }

    if (session.runTimesSeconds.length != 8 ||
        session.stationTimesSeconds.length != 8) {
      throw ArgumentError(
        'Full HYROX requires 8 runs and 8 stations.',
      );
    }

    const stations = [
      'SkiErg',
      'Sled Push',
      'Sled Pull',
      'Burpee Broad Jumps',
      'Rowing',
      'Farmers Carry',
      'Sandbag Lunges',
      'Wall Balls',
    ];

    final db = await database;

    await db.transaction(
          (txn) async {
        await txn.update(
          'workouts',
          workout.toMap(),
          where: 'id = ?',
          whereArgs: [workout.id],
        );

        final sessionRows =
        await txn.query(
          'hyrox_sessions',
          where: 'workout_id = ?',
          whereArgs: [workout.id],
          limit: 1,
        );

        if (sessionRows.isEmpty) {
          throw Exception(
            'HYROX session not found.',
          );
        }

        final sessionId =
        sessionRows.first['id']
        as int;

        await txn.delete(
          'hyrox_splits',
          where:
          'hyrox_session_id = ?',
          whereArgs: [sessionId],
        );

        for (int i = 0; i < 8; i++) {
          await txn.insert(
            'hyrox_splits',
            {
              'hyrox_session_id':
              sessionId,
              'segment_number':
              i + 1,
              'run_seconds':
              session
                  .runTimesSeconds[i],
              'station_name':
              stations[i],
              'station_seconds':
              session
                  .stationTimesSeconds[i],
            },
          );
        }
      },
    );
  }

  // ==================================================
  // CUSTOM HYROX TRAINING
  // ==================================================

  Future<void> insertHyroxTrainingSession({
    required int workoutId,
    required List<HyroxTrainingSegment>
    segments,
  }) async {
    if (segments.isEmpty) {
      throw ArgumentError(
        'HYROX training requires at least one segment.',
      );
    }

    final db = await database;

    await db.transaction(
          (txn) async {
        final sessionId =
        await txn.insert(
          'hyrox_training_sessions',
          {
            'workout_id': workoutId,
          },
        );

        for (int i = 0;
        i < segments.length;
        i++) {
          final segment =
          segments[i];

          await txn.insert(
            'hyrox_training_segments',
            {
              'session_id':
              sessionId,
              'segment_type':
              segment.segmentType,
              'segment_name':
              segment.segmentName,
              'segment_order':
              i,
              'duration_seconds':
              segment.durationSeconds,
            },
          );
        }
      },
    );
  }

  Future<HyroxTrainingSession?>
  getHyroxTrainingSessionForWorkout(
      int workoutId,
      ) async {
    final db = await database;

    final sessions = await db.query(
      'hyrox_training_sessions',
      where: 'workout_id = ?',
      whereArgs: [workoutId],
      limit: 1,
    );

    if (sessions.isEmpty) {
      return null;
    }

    final sessionId =
    sessions.first['id'] as int;

    final rows = await db.query(
      'hyrox_training_segments',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'segment_order ASC',
    );

    final segments = rows
        .map(
      HyroxTrainingSegment.fromMap,
    )
        .toList();

    return HyroxTrainingSession(
      id: sessionId,
      workoutId: workoutId,
      segments: segments,
    );
  }

  Future<void> updateHyroxTrainingSession({
    required Workout workout,
    required List<HyroxTrainingSegment>
    segments,
  }) async {
    if (workout.id == null) {
      throw ArgumentError(
        'Workout must have an ID.',
      );
    }

    if (segments.isEmpty) {
      throw ArgumentError(
        'HYROX training requires at least one segment.',
      );
    }

    final db = await database;

    await db.transaction(
          (txn) async {
        await txn.update(
          'workouts',
          workout.toMap(),
          where: 'id = ?',
          whereArgs: [workout.id],
        );

        final sessionRows =
        await txn.query(
          'hyrox_training_sessions',
          where: 'workout_id = ?',
          whereArgs: [workout.id],
          limit: 1,
        );

        if (sessionRows.isEmpty) {
          throw Exception(
            'HYROX training session not found.',
          );
        }

        final sessionId =
        sessionRows.first['id']
        as int;

        await txn.delete(
          'hyrox_training_segments',
          where: 'session_id = ?',
          whereArgs: [sessionId],
        );

        for (int i = 0;
        i < segments.length;
        i++) {
          final segment =
          segments[i];

          await txn.insert(
            'hyrox_training_segments',
            {
              'session_id':
              sessionId,
              'segment_type':
              segment.segmentType,
              'segment_name':
              segment.segmentName,
              'segment_order':
              i,
              'duration_seconds':
              segment.durationSeconds,
            },
          );
        }
      },
    );
  }

  // ==================================================
  // STATISTICS
  // ==================================================

  Future<int>
  getCompletedWorkoutCount() async {
    final db = await database;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM workouts
      WHERE completed = 1
      ''',
    );

    return Sqflite.firstIntValue(
      result,
    ) ??
        0;
  }

  // ==================================================
  // DATABASE
  // ==================================================

  Future<void> close() async {
    final db = await database;

    await db.close();

    _database = null;
  }
}

// ====================================================
// WEIGHT EDIT DATA
// ====================================================

class WorkoutExerciseEditData {
  final String exerciseId;
  final String exerciseName;
  final String primaryMuscle;
  final String trackingType;

  final List<ExerciseSetEditData> sets;

  const WorkoutExerciseEditData({
    required this.exerciseId,
    required this.exerciseName,
    required this.primaryMuscle,
    required this.trackingType,
    required this.sets,
  });
}

class ExerciseSetEditData {
  final double? weightKg;
  final int? reps;
  final int? durationSeconds;
  final double? distanceMeters;

  const ExerciseSetEditData({
    this.weightKg,
    this.reps,
    this.durationSeconds,
    this.distanceMeters,
  });
}