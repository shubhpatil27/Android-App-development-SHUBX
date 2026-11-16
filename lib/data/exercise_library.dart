import '../models/exercise.dart';

class ExerciseLibrary {
  static const List<String> muscleGroups = [
    'Chest',
    'Back',
    'Shoulders',
    'Biceps',
    'Triceps',
    'Quads',
    'Hamstrings',
    'Glutes',
    'Calves',
    'Abs',
  ];

  static const List<Exercise> exercises = [
    // --------------------------------------------------
    // CHEST
    // --------------------------------------------------

    Exercise(
      id: 'barbell_bench_press',
      name: 'Barbell Bench Press',
      primaryMuscle: 'Chest',
      secondaryMuscles: [
        'Triceps',
        'Shoulders',
      ],
      equipment: 'Barbell',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'incline_barbell_press',
      name: 'Incline Barbell Press',
      primaryMuscle: 'Chest',
      secondaryMuscles: [
        'Triceps',
        'Shoulders',
      ],
      equipment: 'Barbell',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'dumbbell_bench_press',
      name: 'Dumbbell Bench Press',
      primaryMuscle: 'Chest',
      secondaryMuscles: [
        'Triceps',
        'Shoulders',
      ],
      equipment: 'Dumbbells',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'incline_dumbbell_press',
      name: 'Incline Dumbbell Press',
      primaryMuscle: 'Chest',
      secondaryMuscles: [
        'Triceps',
        'Shoulders',
      ],
      equipment: 'Dumbbells',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'machine_chest_press',
      name: 'Machine Chest Press',
      primaryMuscle: 'Chest',
      secondaryMuscles: [
        'Triceps',
      ],
      equipment: 'Machine',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'cable_fly',
      name: 'Cable Fly',
      primaryMuscle: 'Chest',
      secondaryMuscles: [],
      equipment: 'Cable',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'pec_deck',
      name: 'Pec Deck',
      primaryMuscle: 'Chest',
      secondaryMuscles: [],
      equipment: 'Machine',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'push_up',
      name: 'Push-Up',
      primaryMuscle: 'Chest',
      secondaryMuscles: [
        'Triceps',
        'Shoulders',
      ],
      equipment: 'Bodyweight',
      trackingType: ExerciseTrackingType.repsOnly,
    ),

    // --------------------------------------------------
    // BACK
    // --------------------------------------------------

    Exercise(
      id: 'lat_pulldown',
      name: 'Lat Pulldown',
      primaryMuscle: 'Back',
      secondaryMuscles: [
        'Biceps',
      ],
      equipment: 'Cable',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'pull_up',
      name: 'Pull-Up',
      primaryMuscle: 'Back',
      secondaryMuscles: [
        'Biceps',
      ],
      equipment: 'Bodyweight',
      trackingType: ExerciseTrackingType.repsOnly,
    ),

    Exercise(
      id: 'seated_cable_row',
      name: 'Seated Cable Row',
      primaryMuscle: 'Back',
      secondaryMuscles: [
        'Biceps',
      ],
      equipment: 'Cable',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'chest_supported_row',
      name: 'Chest-Supported Row',
      primaryMuscle: 'Back',
      secondaryMuscles: [
        'Biceps',
      ],
      equipment: 'Machine / Dumbbells',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'one_arm_dumbbell_row',
      name: 'One-Arm Dumbbell Row',
      primaryMuscle: 'Back',
      secondaryMuscles: [
        'Biceps',
      ],
      equipment: 'Dumbbell',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'machine_row',
      name: 'Machine Row',
      primaryMuscle: 'Back',
      secondaryMuscles: [
        'Biceps',
      ],
      equipment: 'Machine',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    // --------------------------------------------------
    // SHOULDERS
    // --------------------------------------------------

    Exercise(
      id: 'shoulder_press',
      name: 'Shoulder Press',
      primaryMuscle: 'Shoulders',
      secondaryMuscles: [
        'Triceps',
      ],
      equipment: 'Dumbbells / Machine',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'barbell_overhead_press',
      name: 'Barbell Overhead Press',
      primaryMuscle: 'Shoulders',
      secondaryMuscles: [
        'Triceps',
      ],
      equipment: 'Barbell',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'lateral_raise',
      name: 'Lateral Raise',
      primaryMuscle: 'Shoulders',
      equipment: 'Dumbbells',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'cable_lateral_raise',
      name: 'Cable Lateral Raise',
      primaryMuscle: 'Shoulders',
      equipment: 'Cable',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'rear_delt_fly',
      name: 'Rear Delt Fly',
      primaryMuscle: 'Shoulders',
      secondaryMuscles: ['Back'],
      equipment: 'Machine / Dumbbells',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'face_pull',
      name: 'Face Pull',
      primaryMuscle: 'Shoulders',
      secondaryMuscles: ['Back'],
      equipment: 'Cable',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    // --------------------------------------------------
    // BICEPS
    // --------------------------------------------------

    Exercise(
      id: 'barbell_curl',
      name: 'Barbell Curl',
      primaryMuscle: 'Biceps',
      equipment: 'Barbell',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'dumbbell_curl',
      name: 'Dumbbell Curl',
      primaryMuscle: 'Biceps',
      equipment: 'Dumbbells',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'hammer_curl',
      name: 'Hammer Curl',
      primaryMuscle: 'Biceps',
      equipment: 'Dumbbells',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'preacher_curl',
      name: 'Preacher Curl',
      primaryMuscle: 'Biceps',
      equipment: 'Barbell / Machine',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'cable_curl',
      name: 'Cable Curl',
      primaryMuscle: 'Biceps',
      equipment: 'Cable',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    // --------------------------------------------------
    // TRICEPS
    // --------------------------------------------------

    Exercise(
      id: 'triceps_pushdown',
      name: 'Triceps Pushdown',
      primaryMuscle: 'Triceps',
      equipment: 'Cable',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'overhead_triceps_extension',
      name: 'Overhead Triceps Extension',
      primaryMuscle: 'Triceps',
      equipment: 'Cable / Dumbbell',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'skull_crusher',
      name: 'Skull Crusher',
      primaryMuscle: 'Triceps',
      equipment: 'EZ Bar / Dumbbells',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'close_grip_bench_press',
      name: 'Close-Grip Bench Press',
      primaryMuscle: 'Triceps',
      secondaryMuscles: ['Chest'],
      equipment: 'Barbell',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'triceps_dip',
      name: 'Triceps Dip',
      primaryMuscle: 'Triceps',
      secondaryMuscles: ['Chest'],
      equipment: 'Bodyweight',
      trackingType: ExerciseTrackingType.repsOnly,
    ),

    // --------------------------------------------------
    // QUADS
    // --------------------------------------------------

    Exercise(
      id: 'back_squat',
      name: 'Back Squat',
      primaryMuscle: 'Quads',
      secondaryMuscles: [
        'Glutes',
        'Hamstrings',
      ],
      equipment: 'Barbell',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'front_squat',
      name: 'Front Squat',
      primaryMuscle: 'Quads',
      secondaryMuscles: ['Glutes'],
      equipment: 'Barbell',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'leg_press',
      name: 'Leg Press',
      primaryMuscle: 'Quads',
      secondaryMuscles: ['Glutes'],
      equipment: 'Machine',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'leg_extension',
      name: 'Leg Extension',
      primaryMuscle: 'Quads',
      equipment: 'Machine',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'bulgarian_split_squat',
      name: 'Bulgarian Split Squat',
      primaryMuscle: 'Quads',
      secondaryMuscles: ['Glutes'],
      equipment: 'Dumbbells / Bodyweight',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'walking_lunge',
      name: 'Walking Lunge',
      primaryMuscle: 'Quads',
      secondaryMuscles: [
        'Glutes',
        'Hamstrings',
      ],
      equipment: 'Dumbbells / Bodyweight',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    // --------------------------------------------------
    // HAMSTRINGS
    // --------------------------------------------------

    Exercise(
      id: 'seated_leg_curl',
      name: 'Seated Leg Curl',
      primaryMuscle: 'Hamstrings',
      equipment: 'Machine',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'lying_leg_curl',
      name: 'Lying Leg Curl',
      primaryMuscle: 'Hamstrings',
      equipment: 'Machine',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'single_leg_curl',
      name: 'Single-Leg Curl',
      primaryMuscle: 'Hamstrings',
      equipment: 'Machine',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    // --------------------------------------------------
    // GLUTES
    // --------------------------------------------------

    Exercise(
      id: 'hip_thrust',
      name: 'Hip Thrust',
      primaryMuscle: 'Glutes',
      secondaryMuscles: ['Hamstrings'],
      equipment: 'Barbell / Machine',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'glute_bridge',
      name: 'Glute Bridge',
      primaryMuscle: 'Glutes',
      secondaryMuscles: ['Hamstrings'],
      equipment: 'Bodyweight / Barbell',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'cable_kickback',
      name: 'Cable Kickback',
      primaryMuscle: 'Glutes',
      equipment: 'Cable',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'step_up',
      name: 'Step-Up',
      primaryMuscle: 'Glutes',
      secondaryMuscles: ['Quads'],
      equipment: 'Dumbbells / Bodyweight',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    // --------------------------------------------------
    // CALVES
    // --------------------------------------------------

    Exercise(
      id: 'standing_calf_raise',
      name: 'Standing Calf Raise',
      primaryMuscle: 'Calves',
      equipment: 'Machine / Bodyweight',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'seated_calf_raise',
      name: 'Seated Calf Raise',
      primaryMuscle: 'Calves',
      equipment: 'Machine',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'leg_press_calf_raise',
      name: 'Leg Press Calf Raise',
      primaryMuscle: 'Calves',
      equipment: 'Leg Press',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    // --------------------------------------------------
    // ABS
    // --------------------------------------------------

    Exercise(
      id: 'cable_crunch',
      name: 'Cable Crunch',
      primaryMuscle: 'Abs',
      equipment: 'Cable',
      trackingType: ExerciseTrackingType.weightAndReps,
    ),

    Exercise(
      id: 'hanging_leg_raise',
      name: 'Hanging Leg Raise',
      primaryMuscle: 'Abs',
      equipment: 'Bodyweight',
      trackingType: ExerciseTrackingType.repsOnly,
    ),

    Exercise(
      id: 'reverse_crunch',
      name: 'Reverse Crunch',
      primaryMuscle: 'Abs',
      equipment: 'Bodyweight',
      trackingType: ExerciseTrackingType.repsOnly,
    ),

    Exercise(
      id: 'ab_wheel',
      name: 'Ab Wheel Rollout',
      primaryMuscle: 'Abs',
      equipment: 'Ab Wheel',
      trackingType: ExerciseTrackingType.repsOnly,
    ),

    Exercise(
      id: 'plank',
      name: 'Plank',
      primaryMuscle: 'Abs',
      equipment: 'Bodyweight',
      trackingType: ExerciseTrackingType.duration,
    ),

    Exercise(
      id: 'side_plank',
      name: 'Side Plank',
      primaryMuscle: 'Abs',
      equipment: 'Bodyweight',
      trackingType: ExerciseTrackingType.duration,
    ),
  ];

  static List<Exercise> forMuscle(String muscle) {
    return exercises
        .where((exercise) => exercise.primaryMuscle == muscle)
        .toList();
  }

  static List<Exercise> search(String query) {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return exercises;
    }

    return exercises.where((exercise) {
      return exercise.name.toLowerCase().contains(normalizedQuery) ||
          exercise.primaryMuscle
              .toLowerCase()
              .contains(normalizedQuery) ||
          exercise.equipment
              .toLowerCase()
              .contains(normalizedQuery);
    }).toList();
  }
}