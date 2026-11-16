class WorkoutExercise {
  final int? id;
  final int workoutId;
  final String exerciseId;
  final String exerciseName;
  final String primaryMuscle;
  final String trackingType;
  final int exerciseOrder;

  const WorkoutExercise({
    this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.exerciseName,
    required this.primaryMuscle,
    required this.trackingType,
    required this.exerciseOrder,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_id': workoutId,
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      'primary_muscle': primaryMuscle,
      'tracking_type': trackingType,
      'exercise_order': exerciseOrder,
    };
  }

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      id: map['id'] as int?,
      workoutId: map['workout_id'] as int,
      exerciseId: map['exercise_id'] as String,
      exerciseName: map['exercise_name'] as String,
      primaryMuscle: map['primary_muscle'] as String,
      trackingType: map['tracking_type'] as String,
      exerciseOrder: map['exercise_order'] as int,
    );
  }

  WorkoutExercise copyWith({
    int? id,
  }) {
    return WorkoutExercise(
      id: id ?? this.id,
      workoutId: workoutId,
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      primaryMuscle: primaryMuscle,
      trackingType: trackingType,
      exerciseOrder: exerciseOrder,
    );
  }
}