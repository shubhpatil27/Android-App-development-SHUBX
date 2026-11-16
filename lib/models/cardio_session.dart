class CardioSession {
  final int? id;
  final int workoutId;
  final String activityType;

  final double? distanceMeters;
  final int durationSeconds;

  final double? level;
  final int? floors;
  final int? reps;
  final int? rounds;

  const CardioSession({
    this.id,
    required this.workoutId,
    required this.activityType,
    this.distanceMeters,
    required this.durationSeconds,
    this.level,
    this.floors,
    this.reps,
    this.rounds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_id': workoutId,
      'activity_type': activityType,
      'distance_meters': distanceMeters,
      'duration_seconds': durationSeconds,
      'level': level,
      'floors': floors,
      'reps': reps,
      'rounds': rounds,
    };
  }

  factory CardioSession.fromMap(
      Map<String, dynamic> map,
      ) {
    return CardioSession(
      id: map['id'] as int?,
      workoutId: map['workout_id'] as int,
      activityType: map['activity_type'] as String,
      distanceMeters:
      (map['distance_meters'] as num?)?.toDouble(),
      durationSeconds:
      map['duration_seconds'] as int,
      level:
      (map['level'] as num?)?.toDouble(),
      floors: map['floors'] as int?,
      reps: map['reps'] as int?,
      rounds: map['rounds'] as int?,
    );
  }
}