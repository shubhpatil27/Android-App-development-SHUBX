import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/cardio_session.dart';
import '../../models/user_preferences.dart';
import '../../models/workout.dart';
import '../../services/database_service.dart';

class CardioActivityLoggerScreen extends StatefulWidget {
  final String activity;
  final UserPreferences preferences;

  final Workout? workout;
  final CardioSession? session;

  const CardioActivityLoggerScreen({
    super.key,
    required this.activity,
    required this.preferences,
    this.workout,
    this.session,
  });

  bool get editing =>
      workout != null && session != null;

  @override
  State<CardioActivityLoggerScreen> createState() =>
      _CardioActivityLoggerScreenState();
}

class _CardioActivityLoggerScreenState
    extends State<CardioActivityLoggerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _customNameController =
  TextEditingController();
  final _distanceController =
  TextEditingController();
  final _minutesController =
  TextEditingController();
  final _secondsController =
  TextEditingController();
  final _levelController =
  TextEditingController();
  final _floorsController =
  TextEditingController();
  final _repsController =
  TextEditingController();
  final _roundsController =
  TextEditingController();

  bool _saving = false;

  static const double _metersPerMile = 1609.344;

  String get _activity =>
      widget.session?.activityType ??
          widget.activity;

  String get _distanceUnit =>
      widget.preferences.distanceUnit == 'km'
          ? 'km'
          : 'mi';

  bool get _usesDistance => [
    'Cycling',
    'Elliptical',
    'Swimming',
    'Hiking',
  ].contains(_activity);

  bool get _usesMeters => [
    'Rowing',
    'SkiErg',
  ].contains(_activity);

  bool get _isStairMaster =>
      _activity == 'StairMaster';

  bool get _isJumpRope =>
      _activity == 'Jump Rope';

  bool get _isOther =>
      _activity == 'Other Cardio';

  @override
  void initState() {
    super.initState();

    if (widget.editing) {
      _prefill();
    }
  }

  void _prefill() {
    final session = widget.session!;

    if (_isOther) {
      _customNameController.text =
          widget.workout!.title;
    }

    if (session.distanceMeters != null) {
      final distance =
      _usesMeters
          ? session.distanceMeters!
          : _distanceUnit == 'km'
          ? session.distanceMeters! / 1000
          : session.distanceMeters! /
          _metersPerMile;

      _distanceController.text =
          _cleanNumber(distance);
    }

    _minutesController.text =
        (session.durationSeconds ~/ 60)
            .toString();

    _secondsController.text =
        (session.durationSeconds % 60)
            .toString()
            .padLeft(2, '0');

    if (session.level != null) {
      _levelController.text =
          _cleanNumber(session.level!);
    }

    if (session.floors != null) {
      _floorsController.text =
          session.floors.toString();
    }

    if (session.reps != null) {
      _repsController.text =
          session.reps.toString();
    }

    if (session.rounds != null) {
      _roundsController.text =
          session.rounds.toString();
    }
  }

  String _cleanNumber(double value) {
    if ((value - value.round()).abs() < 0.001) {
      return value.round().toString();
    }

    return value.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _customNameController.dispose();
    _distanceController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    _levelController.dispose();
    _floorsController.dispose();
    _repsController.dispose();
    _roundsController.dispose();

    super.dispose();
  }

  int? get _durationSeconds {
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

    if (minutes == 0 &&
        seconds == 0) {
      return null;
    }

    return minutes * 60 + seconds;
  }

  double? get _distanceMeters {
    final value = double.tryParse(
      _distanceController.text.trim(),
    );

    if (value == null || value <= 0) {
      return null;
    }

    if (_usesMeters) {
      return value;
    }

    return _distanceUnit == 'km'
        ? value * 1000
        : value * _metersPerMile;
  }

  String _formatPace(
      double totalSeconds,
      ) {
    int minutes =
        totalSeconds ~/ 60;

    int seconds =
    (totalSeconds % 60).round();

    if (seconds == 60) {
      minutes++;
      seconds = 0;
    }

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String? get _metric {
    final seconds = _durationSeconds;
    final meters = _distanceMeters;

    if (seconds == null ||
        meters == null ||
        meters <= 0) {
      return null;
    }

    if (_activity == 'Cycling') {
      final hours = seconds / 3600;

      if (_distanceUnit == 'km') {
        return '${((meters / 1000) / hours).toStringAsFixed(1)} km/h';
      }

      return '${((meters / _metersPerMile) / hours).toStringAsFixed(1)} mph';
    }

    if (_activity == 'Rowing' ||
        _activity == 'SkiErg') {
      final secondsPer500 =
          seconds / (meters / 500);

      return '${_formatPace(secondsPer500)} /500m';
    }

    if (_activity == 'Hiking' ||
        _activity == 'Elliptical' ||
        _activity == 'Swimming') {
      final distance =
      _distanceUnit == 'km'
          ? meters / 1000
          : meters / _metersPerMile;

      return '${_formatPace(seconds / distance)} /$_distanceUnit';
    }

    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final duration = _durationSeconds;

    if (duration == null) {
      return;
    }

    if ((_usesDistance || _usesMeters) &&
        _distanceMeters == null) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final title = _isOther
          ? _customNameController.text.trim()
          : _activity;

      final session = CardioSession(
        id: widget.session?.id,
        workoutId:
        widget.workout?.id ?? 0,
        activityType: _activity,
        distanceMeters: _distanceMeters,
        durationSeconds: duration,
        level: double.tryParse(
          _levelController.text.trim(),
        ),
        floors: int.tryParse(
          _floorsController.text.trim(),
        ),
        reps: int.tryParse(
          _repsController.text.trim(),
        ),
        rounds: int.tryParse(
          _roundsController.text.trim(),
        ),
      );

      if (widget.editing) {
        final updatedWorkout =
        widget.workout!.copyWith(
          title: title,
          durationMinutes:
          (duration / 60).round(),
        );

        await DatabaseService.instance
            .updateCardioSession(
          workout: updatedWorkout,
          session: CardioSession(
            id: session.id,
            workoutId:
            widget.workout!.id!,
            activityType:
            session.activityType,
            distanceMeters:
            session.distanceMeters,
            durationSeconds:
            session.durationSeconds,
            level: session.level,
            floors: session.floors,
            reps: session.reps,
            rounds: session.rounds,
          ),
        );
      } else {
        final now = DateTime.now();

        final workout =
        await DatabaseService.instance
            .insertWorkout(
          Workout(
            type: 'Cardio',
            title: title,
            date: now,
            durationMinutes:
            (duration / 60).round(),
            completed: true,
            createdAt: now,
          ),
        );

        await DatabaseService.instance
            .insertCardioSession(
          CardioSession(
            workoutId: workout.id!,
            activityType: _activity,
            distanceMeters:
            session.distanceMeters,
            durationSeconds:
            duration,
            level: session.level,
            floors: session.floors,
            reps: session.reps,
            rounds: session.rounds,
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not ${widget.editing ? 'update' : 'save'} cardio: $error',
          ),
        ),
      );
    }
  }

  InputDecoration _decoration(
      String hint,
      String suffix,
      ) {
    return InputDecoration(
      hintText: hint,
      suffixText: suffix,
      filled: true,
      fillColor: ShubXColors.card,
      hintStyle: const TextStyle(
        color: ShubXColors.darkGrey,
      ),
      suffixStyle: const TextStyle(
        color: ShubXColors.grey,
      ),
      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(16),
      ),
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
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required String suffix,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType:
      const TextInputType.numberWithOptions(
        decimal: true,
      ),
      onChanged: (_) {
        setState(() {});
      },
      style: const TextStyle(
        color: ShubXColors.white,
      ),
      decoration:
      _decoration(hint, suffix),
      validator: required
          ? (value) {
        final number =
        double.tryParse(
          value?.trim() ?? '',
        );

        if (number == null ||
            number <= 0) {
          return 'Required';
        }

        return null;
      }
          : null,
    );
  }

  Widget _label(String value) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 9,
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: ShubXColors.gold,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      ShubXColors.black,
      appBar: AppBar(
        backgroundColor:
        ShubXColors.black,
        title: Text(
          widget.editing
              ? 'EDIT ${_activity.toUpperCase()}'
              : _activity.toUpperCase(),
          style: const TextStyle(
            color: ShubXColors.white,
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding:
          const EdgeInsets.all(20),
          children: [
            if (_isOther) ...[
              _label('ACTIVITY NAME'),
              TextFormField(
                controller:
                _customNameController,
                style: const TextStyle(
                  color:
                  ShubXColors.white,
                ),
                decoration: _decoration(
                  'Activity name',
                  '',
                ),
                validator: (value) =>
                value == null ||
                    value
                        .trim()
                        .isEmpty
                    ? 'Required'
                    : null,
              ),
              const SizedBox(height: 24),
            ],

            if (_usesDistance ||
                _usesMeters) ...[
              _label('DISTANCE'),
              _field(
                controller:
                _distanceController,
                hint: _usesMeters
                    ? '2000'
                    : '5.0',
                suffix: _usesMeters
                    ? 'm'
                    : _distanceUnit,
                required: true,
              ),
              const SizedBox(height: 24),
            ],

            _label('TIME'),

            Row(
              children: [
                Expanded(
                  child: _field(
                    controller:
                    _minutesController,
                    hint: '30',
                    suffix: 'min',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _field(
                    controller:
                    _secondsController,
                    hint: '00',
                    suffix: 'sec',
                  ),
                ),
              ],
            ),

            if (_isStairMaster) ...[
              const SizedBox(height: 24),
              _label('LEVEL'),
              _field(
                controller:
                _levelController,
                hint: '8',
                suffix: '',
              ),
              const SizedBox(height: 20),
              _label('FLOORS'),
              _field(
                controller:
                _floorsController,
                hint: '50',
                suffix: 'floors',
              ),
            ],

            if (_isJumpRope) ...[
              const SizedBox(height: 24),
              _label('REPS'),
              _field(
                controller:
                _repsController,
                hint: '1000',
                suffix: 'reps',
              ),
              const SizedBox(height: 20),
              _label('ROUNDS'),
              _field(
                controller:
                _roundsController,
                hint: '10',
                suffix: 'rounds',
              ),
            ],

            if (_metric != null) ...[
              const SizedBox(height: 28),
              Container(
                padding:
                const EdgeInsets.all(
                  22,
                ),
                decoration: BoxDecoration(
                  color: ShubXColors.card,
                  borderRadius:
                  BorderRadius.circular(
                    18,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _activity == 'Cycling'
                          ? 'AVERAGE SPEED'
                          : 'AVERAGE PACE',
                      style:
                      const TextStyle(
                        color:
                        ShubXColors.grey,
                        fontSize: 10,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      _metric!,
                      style:
                      const TextStyle(
                        color:
                        ShubXColors.white,
                        fontSize: 28,
                        fontWeight:
                        FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed:
              _saving ? null : _save,
              icon: Icon(
                widget.editing
                    ? Icons.save_outlined
                    : Icons.check,
              ),
              label: Text(
                widget.editing
                    ? 'SAVE CHANGES'
                    : 'COMPLETE CARDIO',
              ),
            ),
          ],
        ),
      ),
    );
  }
}