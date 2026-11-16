import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_preferences.dart';

class PreferencesService {
  PreferencesService._();

  static final PreferencesService instance =
  PreferencesService._();

  static const String _trainingTypesKey =
      'training_types';

  static const String _goalsKey =
      'training_goals';

  static const String _weeklyTargetKey =
      'weekly_target';

  static const String _weightUnitKey =
      'weight_unit';

  static const String _distanceUnitKey =
      'distance_unit';

  static const String _heightKey =
      'height_cm';

  static const String _weightKey =
      'weight_kg';

  static const String _onboardingKey =
      'onboarding_complete';

  // ==================================================
  // SAVE
  // ==================================================

  Future<void> savePreferences(
      UserPreferences preferences,
      ) async {
    final prefs =
    await SharedPreferences
        .getInstance();

    await prefs.setStringList(
      _trainingTypesKey,
      preferences.trainingTypes
          .toList(),
    );

    await prefs.setStringList(
      _goalsKey,
      preferences.goals.toList(),
    );

    await prefs.setInt(
      _weeklyTargetKey,
      preferences.weeklyTarget,
    );

    await prefs.setString(
      _weightUnitKey,
      preferences.weightUnit,
    );

    await prefs.setString(
      _distanceUnitKey,
      preferences.distanceUnit,
    );

    if (preferences.heightCm != null) {
      await prefs.setDouble(
        _heightKey,
        preferences.heightCm!,
      );
    } else {
      await prefs.remove(
        _heightKey,
      );
    }

    if (preferences.weightKg != null) {
      await prefs.setDouble(
        _weightKey,
        preferences.weightKg!,
      );
    } else {
      await prefs.remove(
        _weightKey,
      );
    }

    await prefs.setBool(
      _onboardingKey,
      true,
    );
  }

  // ==================================================
  // LOAD
  // ==================================================

  Future<UserPreferences?>
  loadPreferences() async {
    final prefs =
    await SharedPreferences
        .getInstance();

    final onboardingComplete =
        prefs.getBool(
          _onboardingKey,
        ) ??
            false;

    if (!onboardingComplete) {
      return null;
    }

    final trainingTypes =
        prefs.getStringList(
          _trainingTypesKey,
        ) ??
            [];

    final goals =
        prefs.getStringList(
          _goalsKey,
        ) ??
            [];

    if (trainingTypes.isEmpty) {
      return null;
    }

    return UserPreferences(
      trainingTypes:
      trainingTypes.toSet(),
      goals: goals.toSet(),
      weeklyTarget:
      prefs.getInt(
        _weeklyTargetKey,
      ) ??
          4,
      weightUnit:
      prefs.getString(
        _weightUnitKey,
      ) ??
          'lb',
      distanceUnit:
      prefs.getString(
        _distanceUnitKey,
      ) ??
          'mi',
      heightCm:
      prefs.getDouble(
        _heightKey,
      ),
      weightKg:
      prefs.getDouble(
        _weightKey,
      ),
    );
  }

  // ==================================================
  // CLOUD CONSTRUCTOR
  // ==================================================

  Future<UserPreferences>
  preferencesFromCloud({
    required Set<String>
    trainingTypes,
    required Set<String> goals,
    required int weeklyTarget,
    required String weightUnit,
    required String distanceUnit,
    double? heightCm,
    double? weightKg,
  }) async {
    return UserPreferences(
      trainingTypes:
      trainingTypes,
      goals: goals,
      weeklyTarget:
      weeklyTarget,
      weightUnit:
      weightUnit,
      distanceUnit:
      distanceUnit,
      heightCm:
      heightCm,
      weightKg:
      weightKg,
    );
  }

  // ==================================================
  // ONBOARDING
  // ==================================================

  Future<bool>
  hasCompletedOnboarding() async {
    final prefs =
    await SharedPreferences
        .getInstance();

    return prefs.getBool(
      _onboardingKey,
    ) ??
        false;
  }
}