enum ExerciseTrackingType {
  weightAndReps,
  repsOnly,
  duration,
  weightAndDistance,
}

class Exercise {
  final String id;
  final String name;
  final String primaryMuscle;
  final List<String> secondaryMuscles;
  final String equipment;
  final ExerciseTrackingType trackingType;
  final String? visualAsset;

  const Exercise({
    required this.id,
    required this.name,
    required this.primaryMuscle,
    this.secondaryMuscles = const [],
    required this.equipment,
    required this.trackingType,
    this.visualAsset,
  });
}