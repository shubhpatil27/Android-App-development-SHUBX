import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/hyrox_session.dart';
import '../../models/workout.dart';
import '../../services/database_service.dart';

class HyroxLoggerScreen extends StatefulWidget {
  final Workout? workout;
  final HyroxSession? session;

  const HyroxLoggerScreen({
    super.key,
    this.workout,
    this.session,
  });

  bool get editing =>
      workout != null && session != null;

  @override
  State<HyroxLoggerScreen> createState() =>
      _HyroxLoggerScreenState();
}

class _HyroxLoggerScreenState
    extends State<HyroxLoggerScreen> {
  bool _saving = false;

  static const _stations = [
    'SkiErg',
    'Sled Push',
    'Sled Pull',
    'Burpee Broad Jumps',
    'Rowing',
    'Farmers Carry',
    'Sandbag Lunges',
    'Wall Balls',
  ];

  late final List<TextEditingController>
  _runMinutes;
  late final List<TextEditingController>
  _runSeconds;
  late final List<TextEditingController>
  _stationMinutes;
  late final List<TextEditingController>
  _stationSeconds;

  @override
  void initState() {
    super.initState();

    _runMinutes = List.generate(
      8,
          (_) => TextEditingController(),
    );
    _runSeconds = List.generate(
      8,
          (_) => TextEditingController(),
    );
    _stationMinutes = List.generate(
      8,
          (_) => TextEditingController(),
    );
    _stationSeconds = List.generate(
      8,
          (_) => TextEditingController(),
    );

    if (widget.editing) {
      for (int i = 0; i < 8; i++) {
        final run =
        widget.session!.runTimesSeconds[i];
        final station = widget
            .session!.stationTimesSeconds[i];

        _runMinutes[i].text =
            (run ~/ 60).toString();
        _runSeconds[i].text =
            (run % 60)
                .toString()
                .padLeft(2, '0');

        _stationMinutes[i].text =
            (station ~/ 60).toString();
        _stationSeconds[i].text =
            (station % 60)
                .toString()
                .padLeft(2, '0');
      }
    }
  }

  @override
  void dispose() {
    for (final controller in [
      ..._runMinutes,
      ..._runSeconds,
      ..._stationMinutes,
      ..._stationSeconds,
    ]) {
      controller.dispose();
    }

    super.dispose();
  }

  int? _time(
      TextEditingController minutes,
      TextEditingController seconds,
      ) {
    final m =
        int.tryParse(minutes.text) ?? 0;
    final s =
        int.tryParse(seconds.text) ?? 0;

    if (m < 0 ||
        s < 0 ||
        s >= 60 ||
        (m == 0 && s == 0)) {
      return null;
    }

    return m * 60 + s;
  }

  List<int>? get _runs {
    final values = <int>[];

    for (int i = 0; i < 8; i++) {
      final value = _time(
        _runMinutes[i],
        _runSeconds[i],
      );

      if (value == null) return null;

      values.add(value);
    }

    return values;
  }

  List<int>? get _stationsTimes {
    final values = <int>[];

    for (int i = 0; i < 8; i++) {
      final value = _time(
        _stationMinutes[i],
        _stationSeconds[i],
      );

      if (value == null) return null;

      values.add(value);
    }

    return values;
  }

  int? get _overall {
    final runs = _runs;
    final stations = _stationsTimes;

    if (runs == null ||
        stations == null) {
      return null;
    }

    return runs.fold<int>(
      0,
          (a, b) => a + b,
    ) +
        stations.fold<int>(
          0,
              (a, b) => a + b,
        );
  }

  String _format(int seconds) {
    final h = seconds ~/ 3600;
    final m =
        (seconds % 3600) ~/ 60;
    final s = seconds % 60;

    return h > 0
        ? '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
        : '$m:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _save() async {
    final runs = _runs;
    final stations = _stationsTimes;
    final overall = _overall;

    if (runs == null ||
        stations == null ||
        overall == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Enter all 8 run and station times.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      if (widget.editing) {
        final workout =
        widget.workout!.copyWith(
          durationMinutes:
          (overall / 60).round(),
        );

        await DatabaseService.instance
            .updateHyroxSession(
          workout: workout,
          session: HyroxSession(
            id: widget.session!.id,
            workoutId:
            widget.workout!.id!,
            runTimesSeconds: runs,
            stationTimesSeconds:
            stations,
          ),
        );
      } else {
        final now = DateTime.now();

        final workout =
        await DatabaseService.instance
            .insertWorkout(
          Workout(
            type: 'HYROX',
            title: 'HYROX Training',
            date: now,
            durationMinutes:
            (overall / 60).round(),
            completed: true,
            createdAt: now,
          ),
        );

        await DatabaseService.instance
            .insertHyroxSession(
          HyroxSession(
            workoutId: workout.id!,
            runTimesSeconds: runs,
            stationTimesSeconds:
            stations,
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
            'Could not ${widget.editing ? 'update' : 'save'} HYROX: $error',
          ),
        ),
      );
    }
  }

  Widget _timeField(
      TextEditingController controller,
      String suffix,
      ) {
    return Expanded(
      child: TextField(
        controller: controller,
        keyboardType:
        TextInputType.number,
        onChanged: (_) {
          setState(() {});
        },
        style: const TextStyle(
          color: ShubXColors.white,
        ),
        decoration: InputDecoration(
          hintText:
          suffix == 'min'
              ? '5'
              : '00',
          suffixText: suffix,
          filled: true,
          fillColor:
          ShubXColors.charcoal,
          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              12,
            ),
            borderSide:
            BorderSide.none,
          ),
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
              ? 'EDIT HYROX'
              : 'HYROX',
          style: const TextStyle(
            color: ShubXColors.white,
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding:
        const EdgeInsets.fromLTRB(
          20,
          16,
          20,
          40,
        ),
        children: [
          for (int i = 0;
          i < 8;
          i++) ...[
            Container(
              padding:
              const EdgeInsets.all(
                16,
              ),
              decoration: BoxDecoration(
                color: ShubXColors.card,
                borderRadius:
                BorderRadius.circular(
                  17,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    '${i + 1}. ${_stations[i]}',
                    style:
                    const TextStyle(
                      color:
                      ShubXColors.white,
                      fontSize: 17,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    '1 KM RUN',
                    style: TextStyle(
                      color:
                      ShubXColors.gold,
                      fontSize: 10,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Row(
                    children: [
                      _timeField(
                        _runMinutes[i],
                        'min',
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      _timeField(
                        _runSeconds[i],
                        'sec',
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Text(
                    _stations[i]
                        .toUpperCase(),
                    style:
                    const TextStyle(
                      color:
                      ShubXColors.gold,
                      fontSize: 10,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Row(
                    children: [
                      _timeField(
                        _stationMinutes[i],
                        'min',
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      _timeField(
                        _stationSeconds[i],
                        'sec',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 11),
          ],

          const SizedBox(height: 15),

          Container(
            padding:
            const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ShubXColors.card,
              borderRadius:
              BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                const Text(
                  'OVERALL',
                  style: TextStyle(
                    color:
                    ShubXColors.gold,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _overall == null
                      ? '--'
                      : _format(_overall!),
                  style:
                  const TextStyle(
                    color:
                    ShubXColors.white,
                    fontSize: 30,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

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
                  : 'COMPLETE HYROX',
            ),
          ),
        ],
      ),
    );
  }
}