class UserPreferences {
  final Set<String> trainingTypes;
  final Set<String> goals;
  final int weeklyTarget;

  final String weightUnit;
  final String distanceUnit;

  final double? heightCm;
  final double? weightKg;

  const UserPreferences({
    required this.trainingTypes,
    required this.goals,
    required this.weeklyTarget,
    this.weightUnit = 'lb',
    this.distanceUnit = 'mi',
    this.heightCm,
    this.weightKg,
  });

  UserPreferences copyWith({
    Set<String>? trainingTypes,
    Set<String>? goals,
    int? weeklyTarget,
    String? weightUnit,
    String? distanceUnit,
    double? heightCm,
    double? weightKg,
  }) {
    return UserPreferences(
      trainingTypes:
      trainingTypes ?? this.trainingTypes,
      goals: goals ?? this.goals,
      weeklyTarget:
      weeklyTarget ?? this.weeklyTarget,
      weightUnit:
      weightUnit ?? this.weightUnit,
      distanceUnit:
      distanceUnit ?? this.distanceUnit,
      heightCm:
      heightCm ?? this.heightCm,
      weightKg:
      weightKg ?? this.weightKg,
    );
  }
}