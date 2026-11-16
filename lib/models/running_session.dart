class RunningSession {
  final int? id;
  final int workoutId;
  final double distanceMeters;
  final int durationSeconds;

  const RunningSession({
    this.id,
    required this.workoutId,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_id': workoutId,
      'distance_meters': distanceMeters,
      'duration_seconds': durationSeconds,
    };
  }

  factory RunningSession.fromMap(
      Map<String, dynamic> map,
      ) {
    return RunningSession(
      id: map['id'] as int?,
      workoutId: map['workout_id'] as int,
      distanceMeters:
      (map['distance_meters'] as num).toDouble(),
      durationSeconds:
      map['duration_seconds'] as int,
    );
  }
}