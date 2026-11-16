import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/user_preferences.dart';
import '../../models/walking_session.dart';
import '../../models/workout.dart';
import '../../services/database_service.dart';

class WalkingLoggerScreen extends StatefulWidget {
  final UserPreferences preferences;

  final Workout? workout;
  final WalkingSession? session;

  const WalkingLoggerScreen({
    super.key,
    required this.preferences,
    this.workout,
    this.session,
  });

  bool get editing =>
      workout != null && session != null;

  @override
  State<WalkingLoggerScreen> createState() =>
      _WalkingLoggerScreenState();
}

class _WalkingLoggerScreenState
    extends State<WalkingLoggerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _distanceController =
  TextEditingController();

  final _durationController =
  TextEditingController();

  bool _saving = false;

  static const double _metersPerMile = 1609.344;

  String get _distanceUnit =>
      widget.preferences.distanceUnit == 'km'
          ? 'km'
          : 'mi';

  @override
  void initState() {
    super.initState();

    if (widget.editing) {
      _prefill();
    }
  }

  void _prefill() {
    final session = widget.session!;

    final distance =
    _distanceUnit == 'km'
        ? session.distanceMeters / 1000
        : session.distanceMeters /
        _metersPerMile;

    _distanceController.text =
        _cleanNumber(distance);

    _durationController.text =
        _cleanNumber(
          session.durationSeconds / 60,
        );
  }

  String _cleanNumber(double value) {
    if ((value - value.round()).abs() < 0.001) {
      return value.round().toString();
    }

    return value.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _durationController.dispose();

    super.dispose();
  }

  double? get _enteredDistance =>
      double.tryParse(
        _distanceController.text.trim(),
      );

  double? get _durationMinutes =>
      double.tryParse(
        _durationController.text.trim(),
      );

  double? get _distanceMeters {
    final distance = _enteredDistance;

    if (distance == null || distance <= 0) {
      return null;
    }

    return _distanceUnit == 'km'
        ? distance * 1000
        : distance * _metersPerMile;
  }

  int? get _estimatedSteps {
    final meters = _distanceMeters;

    if (meters == null) {
      return null;
    }

    final height =
        widget.preferences.heightCm;

    final stepLengthMeters =
    height != null && height > 0
        ? (height / 100) * 0.414
        : 0.75;

    if (stepLengthMeters <= 0) {
      return null;
    }

    return (meters / stepLengthMeters)
        .round();
  }

  String? get _pace {
    final distance = _enteredDistance;
    final minutes = _durationMinutes;

    if (distance == null ||
        distance <= 0 ||
        minutes == null ||
        minutes <= 0) {
      return null;
    }

    final paceMinutes =
        minutes / distance;

    int wholeMinutes =
    paceMinutes.floor();

    int seconds =
    ((paceMinutes - wholeMinutes) * 60)
        .round();

    if (seconds == 60) {
      wholeMinutes++;
      seconds = 0;
    }

    return '$wholeMinutes:${seconds.toString().padLeft(2, '0')} / $_distanceUnit';
  }

  String _formatSteps(int steps) {
    final text = steps.toString();
    final buffer = StringBuffer();

    for (int i = 0;
    i < text.length;
    i++) {
      final remaining =
          text.length - i;

      buffer.write(text[i]);

      if (remaining > 1 &&
          remaining % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final meters = _distanceMeters;
    final minutes = _durationMinutes;
    final steps = _estimatedSteps;

    if (meters == null ||
        minutes == null ||
        steps == null) {
      return;
    }

    final seconds =
    (minutes * 60).round();

    setState(() {
      _saving = true;
    });

    try {
      if (widget.editing) {
        final workout =
        widget.workout!.copyWith(
          durationMinutes:
          minutes.round(),
        );

        await DatabaseService.instance
            .updateWalkingSession(
          workout: workout,
          session: WalkingSession(
            id: widget.session!.id,
            workoutId:
            widget.workout!.id!,
            distanceMeters: meters,
            durationSeconds: seconds,
            estimatedSteps: steps,
            heightCm:
            widget.preferences.heightCm,
          ),
        );
      } else {
        final now = DateTime.now();

        final workout =
        await DatabaseService.instance
            .insertWorkout(
          Workout(
            type: 'Cardio',
            title: 'Walking',
            date: now,
            durationMinutes:
            minutes.round(),
            completed: true,
            createdAt: now,
          ),
        );

        if (workout.id == null) {
          throw Exception(
            'Workout ID was not created.',
          );
        }

        await DatabaseService.instance
            .insertWalkingSession(
          WalkingSession(
            workoutId: workout.id!,
            distanceMeters: meters,
            durationSeconds: seconds,
            estimatedSteps: steps,
            heightCm:
            widget.preferences.heightCm,
          ),
        );
      }

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            widget.editing
                ? 'Could not update walk: $error'
                : 'Could not save walk: $error',
          ),
        ),
      );
    }
  }

  InputDecoration _decoration({
    required String hint,
    required String suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      suffixText: suffix,
      hintStyle: const TextStyle(
        color: ShubXColors.darkGrey,
      ),
      suffixStyle: const TextStyle(
        color: ShubXColors.grey,
      ),
      filled: true,
      fillColor: ShubXColors.card,
      enabledBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: ShubXColors.darkGrey,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: ShubXColors.gold,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = _estimatedSteps;
    final pace = _pace;

    return Scaffold(
      backgroundColor: ShubXColors.black,
      appBar: AppBar(
        backgroundColor: ShubXColors.black,
        title: Text(
          widget.editing
              ? 'EDIT WALK'
              : 'WALKING',
          style: const TextStyle(
            color: ShubXColors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.3,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            16,
            20,
            40,
          ),
          children: [
            const _WalkSectionTitle(
              'DISTANCE',
            ),

            const SizedBox(height: 10),

            TextFormField(
              controller:
              _distanceController,
              keyboardType:
              const TextInputType
                  .numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) {
                setState(() {});
              },
              style: const TextStyle(
                color: ShubXColors.white,
                fontSize: 18,
              ),
              decoration: _decoration(
                hint: _distanceUnit == 'km'
                    ? '5.0'
                    : '3.0',
                suffix: _distanceUnit,
              ),
              validator: (value) {
                final number =
                double.tryParse(
                  value?.trim() ?? '',
                );

                if (number == null ||
                    number <= 0) {
                  return 'Enter a valid distance.';
                }

                return null;
              },
            ),

            const SizedBox(height: 26),

            const _WalkSectionTitle(
              'TIME',
            ),

            const SizedBox(height: 10),

            TextFormField(
              controller:
              _durationController,
              keyboardType:
              const TextInputType
                  .numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) {
                setState(() {});
              },
              style: const TextStyle(
                color: ShubXColors.white,
                fontSize: 18,
              ),
              decoration: _decoration(
                hint: '45',
                suffix: 'minutes',
              ),
              validator: (value) {
                final number =
                double.tryParse(
                  value?.trim() ?? '',
                );

                if (number == null ||
                    number <= 0) {
                  return 'Enter a valid time.';
                }

                return null;
              },
            ),

            const SizedBox(height: 30),

            Container(
              padding:
              const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ShubXColors.card,
                borderRadius:
                BorderRadius.circular(18),
                border: Border.all(
                  color: ShubXColors.gold
                      .withValues(
                    alpha: 0.35,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'WALK SUMMARY',
                    style: TextStyle(
                      color: ShubXColors.gold,
                      fontSize: 11,
                      fontWeight:
                      FontWeight.w700,
                      letterSpacing: 1.3,
                    ),
                  ),

                  const SizedBox(height: 18),

                  _WalkMetric(
                    label: 'Average Pace',
                    value: pace ?? '--',
                  ),

                  const Padding(
                    padding:
                    EdgeInsets.symmetric(
                      vertical: 18,
                    ),
                    child: Divider(
                      color:
                      ShubXColors.darkGrey,
                    ),
                  ),

                  const Text(
                    'ESTIMATED STEP COUNT',
                    style: TextStyle(
                      color: ShubXColors.grey,
                      fontSize: 10,
                      fontWeight:
                      FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    steps == null
                        ? '--'
                        : '~${_formatSteps(steps)} steps',
                    style: const TextStyle(
                      color: ShubXColors.white,
                      fontSize: 30,
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    widget.preferences.heightCm !=
                        null
                        ? 'Estimated using your profile height.'
                        : 'Add your height in Profile for a more personalized estimate.',
                    style: const TextStyle(
                      color: ShubXColors.grey,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed:
              _saving ? null : _save,
              icon: Icon(
                widget.editing
                    ? Icons.save_outlined
                    : Icons.check,
              ),
              label: _saving
                  ? const SizedBox(
                width: 22,
                height: 22,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                  color:
                  ShubXColors.black,
                ),
              )
                  : Text(
                widget.editing
                    ? 'SAVE CHANGES'
                    : 'COMPLETE WALK',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalkSectionTitle
    extends StatelessWidget {
  final String title;

  const _WalkSectionTitle(
      this.title,
      );

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: ShubXColors.gold,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _WalkMetric
    extends StatelessWidget {
  final String label;
  final String value;

  const _WalkMetric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: ShubXColors.grey,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: ShubXColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}