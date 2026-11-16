import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/running_session.dart';
import '../../models/user_preferences.dart';
import '../../models/workout.dart';
import '../../services/database_service.dart';

class RunningLoggerScreen extends StatefulWidget {
  final UserPreferences preferences;

  // Non-null = edit mode.
  final Workout? workout;
  final RunningSession? session;

  const RunningLoggerScreen({
    super.key,
    required this.preferences,
    this.workout,
    this.session,
  });

  bool get editing =>
      workout != null && session != null;

  @override
  State<RunningLoggerScreen> createState() =>
      _RunningLoggerScreenState();
}

class _RunningLoggerScreenState
    extends State<RunningLoggerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _distanceController =
  TextEditingController();

  final _minutesController =
  TextEditingController();

  final _secondsController =
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

    _minutesController.text =
        (session.durationSeconds ~/ 60)
            .toString();

    _secondsController.text =
        (session.durationSeconds % 60)
            .toString()
            .padLeft(2, '0');
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
    _minutesController.dispose();
    _secondsController.dispose();

    super.dispose();
  }

  double? get _enteredDistance =>
      double.tryParse(
        _distanceController.text.trim(),
      );

  int? get _totalSeconds {
    final minutes =
        int.tryParse(
          _minutesController.text.trim(),
        ) ??
            0;

    final seconds =
        int.tryParse(
          _secondsController.text.trim(),
        ) ??
            0;

    if (minutes < 0 ||
        seconds < 0 ||
        seconds >= 60) {
      return null;
    }

    if (minutes == 0 && seconds == 0) {
      return null;
    }

    return minutes * 60 + seconds;
  }

  double? get _distanceMeters {
    final distance = _enteredDistance;

    if (distance == null || distance <= 0) {
      return null;
    }

    return _distanceUnit == 'km'
        ? distance * 1000
        : distance * _metersPerMile;
  }

  String? get _pace {
    final distance = _enteredDistance;
    final seconds = _totalSeconds;

    if (distance == null ||
        distance <= 0 ||
        seconds == null) {
      return null;
    }

    final secondsPerUnit =
        seconds / distance;

    int minutes =
        secondsPerUnit ~/ 60;

    int remainingSeconds =
    (secondsPerUnit % 60).round();

    if (remainingSeconds == 60) {
      minutes++;
      remainingSeconds = 0;
    }

    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')} / $_distanceUnit';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final distanceMeters =
        _distanceMeters;

    final durationSeconds =
        _totalSeconds;

    if (distanceMeters == null ||
        durationSeconds == null) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      if (widget.editing) {
        final oldWorkout =
        widget.workout!;

        final updatedWorkout =
        oldWorkout.copyWith(
          durationMinutes:
          (durationSeconds / 60).round(),
        );

        await DatabaseService.instance
            .updateRunningSession(
          workout: updatedWorkout,
          session: RunningSession(
            id: widget.session!.id,
            workoutId: oldWorkout.id!,
            distanceMeters:
            distanceMeters,
            durationSeconds:
            durationSeconds,
          ),
        );
      } else {
        final now = DateTime.now();

        final workout =
        await DatabaseService.instance
            .insertWorkout(
          Workout(
            type: 'Running',
            title: 'Run',
            date: now,
            durationMinutes:
            (durationSeconds / 60)
                .round(),
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
            .insertRunningSession(
          RunningSession(
            workoutId: workout.id!,
            distanceMeters:
            distanceMeters,
            durationSeconds:
            durationSeconds,
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
                ? 'Could not update run: $error'
                : 'Could not save run: $error',
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
      errorBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.redAccent,
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
    final pace = _pace;

    return Scaffold(
      backgroundColor: ShubXColors.black,
      appBar: AppBar(
        backgroundColor: ShubXColors.black,
        title: Text(
          widget.editing
              ? 'EDIT RUN'
              : 'RUNNING',
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
            const _SectionTitle(
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
                    : '3.1',
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

            const SizedBox(height: 28),

            const _SectionTitle(
              'TIME',
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller:
                    _minutesController,
                    keyboardType:
                    TextInputType.number,
                    onChanged: (_) {
                      setState(() {});
                    },
                    style: const TextStyle(
                      color:
                      ShubXColors.white,
                    ),
                    decoration: _decoration(
                      hint: '25',
                      suffix: 'min',
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: TextFormField(
                    controller:
                    _secondsController,
                    keyboardType:
                    TextInputType.number,
                    onChanged: (_) {
                      setState(() {});
                    },
                    style: const TextStyle(
                      color:
                      ShubXColors.white,
                    ),
                    decoration: _decoration(
                      hint: '00',
                      suffix: 'sec',
                    ),
                    validator: (value) {
                      final seconds =
                          int.tryParse(
                            value
                                ?.trim() ??
                                '',
                          ) ??
                              0;

                      if (seconds < 0 ||
                          seconds >= 60) {
                        return '0–59';
                      }

                      if (_totalSeconds ==
                          null) {
                        return 'Enter time';
                      }

                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Container(
              padding:
              const EdgeInsets.all(22),
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
                children: [
                  const Text(
                    'AVERAGE PACE',
                    style: TextStyle(
                      color: ShubXColors.grey,
                      fontSize: 10,
                      fontWeight:
                      FontWeight.w700,
                      letterSpacing: 1.3,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    pace ?? '--',
                    style: const TextStyle(
                      color: ShubXColors.white,
                      fontSize: 30,
                      fontWeight:
                      FontWeight.w900,
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
                    : 'COMPLETE RUN',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(
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