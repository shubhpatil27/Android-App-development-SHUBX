class WalkingSession {
  final int? id;
  final int workoutId;

  // Canonical storage unit = meters.
  final double distanceMeters;

  final int durationSeconds;
  final int estimatedSteps;

  // Height used for the estimate, if available.
  final double? heightCm;

  const WalkingSession({
    this.id,
    required this.workoutId,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.estimatedSteps,
    this.heightCm,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_id': workoutId,
      'distance_meters': distanceMeters,
      'duration_seconds': durationSeconds,
      'estimated_steps': estimatedSteps,
      'height_cm': heightCm,
    };
  }

  factory WalkingSession.fromMap(
      Map<String, dynamic> map,
      ) {
    return WalkingSession(
      id: map['id'] as int?,
      workoutId: map['workout_id'] as int,
      distanceMeters:
      (map['distance_meters'] as num).toDouble(),
      durationSeconds:
      map['duration_seconds'] as int,
      estimatedSteps:
      map['estimated_steps'] as int,
      heightCm:
      (map['height_cm'] as num?)?.toDouble(),
    );
  }
}