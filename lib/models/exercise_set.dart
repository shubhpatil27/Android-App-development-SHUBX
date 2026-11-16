class ExerciseSet {
  final int? id;
  final int workoutExerciseId;
  final int setNumber;

  final double? weightKg;
  final int? reps;
  final int? durationSeconds;
  final double? distanceMeters;

  const ExerciseSet({
    this.id,
    required this.workoutExerciseId,
    required this.setNumber,
    this.weightKg,
    this.reps,
    this.durationSeconds,
    this.distanceMeters,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_exercise_id': workoutExerciseId,
      'set_number': setNumber,
      'weight_kg': weightKg,
      'reps': reps,
      'duration_seconds': durationSeconds,
      'distance_meters': distanceMeters,
    };
  }

  factory ExerciseSet.fromMap(Map<String, dynamic> map) {
    return ExerciseSet(
      id: map['id'] as int?,
      workoutExerciseId:
      map['workout_exercise_id'] as int,
      setNumber: map['set_number'] as int,
      weightKg:
      (map['weight_kg'] as num?)?.toDouble(),
      reps: map['reps'] as int?,
      durationSeconds:
      map['duration_seconds'] as int?,
      distanceMeters:
      (map['distance_meters'] as num?)?.toDouble(),
    );
  }
}