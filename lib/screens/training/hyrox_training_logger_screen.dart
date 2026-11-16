import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/hyrox_training_session.dart';
import '../../models/workout.dart';
import '../../services/database_service.dart';

class HyroxTrainingLoggerScreen
    extends StatefulWidget {
  final Workout? workout;
  final HyroxTrainingSession? session;

  const HyroxTrainingLoggerScreen({
    super.key,
    this.workout,
    this.session,
  });

  bool get editing =>
      workout != null && session != null;

  @override
  State<HyroxTrainingLoggerScreen> createState() =>
      _HyroxTrainingLoggerScreenState();
}

class _HyroxTrainingLoggerScreenState
    extends State<HyroxTrainingLoggerScreen> {
  final List<_EditableSegment>
  _segments = [];

  bool _saving = false;

  static const List<String> _available = [
    '1 km Run',
    'SkiErg',
    'Sled Push',
    'Sled Pull',
    'Burpee Broad Jumps',
    'Rowing',
    'Farmers Carry',
    'Sandbag Lunges',
    'Wall Balls',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.editing) {
      for (final segment
      in widget.session!.segments) {
        _segments.add(
          _EditableSegment(
            name: segment.segmentName,
            type: segment.segmentType,
            seconds:
            segment.durationSeconds,
          ),
        );
      }
    } else {
      _segments.add(
        _EditableSegment(
          name: '1 km Run',
          type: 'run',
        ),
      );
    }
  }

  @override
  void dispose() {
    for (final segment in _segments) {
      segment.dispose();
    }

    super.dispose();
  }

  int? _seconds(
      _EditableSegment segment,
      ) {
    final m =
        int.tryParse(
          segment.minutes.text,
        ) ??
            0;

    final s =
        int.tryParse(
          segment.seconds.text,
        ) ??
            0;

    if (m < 0 ||
        s < 0 ||
        s >= 60 ||
        (m == 0 && s == 0)) {
      return null;
    }

    return m * 60 + s;
  }

  int? get _total {
    int total = 0;

    for (final segment in _segments) {
      final seconds =
      _seconds(segment);

      if (seconds == null) {
        return null;
      }

      total += seconds;
    }

    return total;
  }

  void _addSegment() {
    showModalBottomSheet(
      context: context,
      backgroundColor:
      ShubXColors.card,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: _available.map(
                  (name) {
                return ListTile(
                  title: Text(
                    name,
                    style:
                    const TextStyle(
                      color:
                      ShubXColors.white,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);

                    setState(() {
                      _segments.add(
                        _EditableSegment(
                          name: name,
                          type: name ==
                              '1 km Run'
                              ? 'run'
                              : 'station',
                        ),
                      );
                    });
                  },
                );
              },
            ).toList(),
          ),
        );
      },
    );
  }

  void _move(
      int oldIndex,
      int newIndex,
      ) {
    setState(() {
      final item =
      _segments.removeAt(oldIndex);

      _segments.insert(
        newIndex,
        item,
      );
    });
  }

  Future<void> _save() async {
    final total = _total;

    if (total == null ||
        _segments.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a valid time for every segment.',
          ),
        ),
      );
      return;
    }

    final data =
    <HyroxTrainingSegment>[];

    for (int i = 0;
    i < _segments.length;
    i++) {
      final segment = _segments[i];

      data.add(
        HyroxTrainingSegment(
          sessionId:
          widget.session?.id ?? 0,
          segmentType: segment.type,
          segmentName: segment.name,
          segmentOrder: i,
          durationSeconds:
          _seconds(segment)!,
        ),
      );
    }

    setState(() {
      _saving = true;
    });

    try {
      if (widget.editing) {
        final workout =
        widget.workout!.copyWith(
          durationMinutes:
          (total / 60).round(),
        );

        await DatabaseService.instance
            .updateHyroxTrainingSession(
          workout: workout,
          segments: data,
        );
      } else {
        final now = DateTime.now();

        final workout =
        await DatabaseService.instance
            .insertWorkout(
          Workout(
            type: 'HYROX',
            title:
            'HYROX Training Session',
            date: now,
            durationMinutes:
            (total / 60).round(),
            completed: true,
            createdAt: now,
          ),
        );

        await DatabaseService.instance
            .insertHyroxTrainingSession(
          workoutId: workout.id!,
          segments: data,
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
            'Could not ${widget.editing ? 'update' : 'save'} HYROX training: $error',
          ),
        ),
      );
    }
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
              ? 'EDIT HYROX TRAINING'
              : 'HYROX TRAINING',
          style: const TextStyle(
            color: ShubXColors.white,
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ),
      body: ReorderableListView.builder(
        padding:
        const EdgeInsets.fromLTRB(
          20,
          16,
          20,
          120,
        ),
        itemCount:
        _segments.length + 2,
        onReorder: (oldIndex, newIndex) {
          if (oldIndex >=
              _segments.length ||
              newIndex >
                  _segments.length) {
            return;
          }

          if (newIndex > oldIndex) {
            newIndex--;
          }

          _move(
            oldIndex,
            newIndex,
          );
        },
        itemBuilder: (context, index) {
          if (index ==
              _segments.length) {
            return Padding(
              key: const ValueKey(
                'add',
              ),
              padding:
              const EdgeInsets.only(
                top: 12,
              ),
              child:
              OutlinedButton.icon(
                onPressed: _addSegment,
                icon: const Icon(
                  Icons.add,
                ),
                label: const Text(
                  'ADD SEGMENT',
                ),
              ),
            );
          }

          if (index ==
              _segments.length + 1) {
            return Column(
              key: const ValueKey(
                'summary',
              ),
              children: [
                const SizedBox(height: 24),

                Container(
                  padding:
                  const EdgeInsets.all(
                    20,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    ShubXColors.card,
                    borderRadius:
                    BorderRadius
                        .circular(18),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'TOTAL',
                          style:
                          TextStyle(
                            color:
                            ShubXColors
                                .gold,
                            fontWeight:
                            FontWeight
                                .w800,
                          ),
                        ),
                      ),
                      Text(
                        _total == null
                            ? '--'
                            : _format(
                          _total!,
                        ),
                        style:
                        const TextStyle(
                          color:
                          ShubXColors
                              .white,
                          fontSize: 22,
                          fontWeight:
                          FontWeight
                              .w900,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                ElevatedButton.icon(
                  onPressed:
                  _saving
                      ? null
                      : _save,
                  icon: Icon(
                    widget.editing
                        ? Icons
                        .save_outlined
                        : Icons.check,
                  ),
                  label: Text(
                    widget.editing
                        ? 'SAVE CHANGES'
                        : 'COMPLETE SESSION',
                  ),
                ),
              ],
            );
          }

          final segment =
          _segments[index];

          return Container(
            key: ValueKey(segment.id),
            margin:
            const EdgeInsets.only(
              bottom: 10,
            ),
            padding:
            const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: ShubXColors.card,
              borderRadius:
              BorderRadius.circular(
                16,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.drag_handle,
                      color:
                      ShubXColors.grey,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        segment.name,
                        style:
                        const TextStyle(
                          color:
                          ShubXColors
                              .white,
                          fontWeight:
                          FontWeight
                              .w700,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed:
                      _segments.length ==
                          1
                          ? null
                          : () {
                        segment
                            .dispose();

                        setState(() {
                          _segments
                              .removeAt(
                            index,
                          );
                        });
                      },
                      icon: const Icon(
                        Icons.close,
                        color:
                        Colors.redAccent,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller:
                        segment.minutes,
                        keyboardType:
                        TextInputType
                            .number,
                        onChanged: (_) {
                          setState(() {});
                        },
                        style:
                        const TextStyle(
                          color:
                          ShubXColors
                              .white,
                        ),
                        decoration:
                        const InputDecoration(
                          hintText: '5',
                          suffixText: 'min',
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: TextField(
                        controller:
                        segment.seconds,
                        keyboardType:
                        TextInputType
                            .number,
                        onChanged: (_) {
                          setState(() {});
                        },
                        style:
                        const TextStyle(
                          color:
                          ShubXColors
                              .white,
                        ),
                        decoration:
                        const InputDecoration(
                          hintText: '00',
                          suffixText: 'sec',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EditableSegment {
  static int _nextId = 0;

  final int id = _nextId++;

  final String name;
  final String type;

  final TextEditingController minutes =
  TextEditingController();

  final TextEditingController seconds =
  TextEditingController();

  _EditableSegment({
    required this.name,
    required this.type,
    int? seconds,
  }) {
    if (seconds != null) {
      minutes.text =
          (seconds ~/ 60).toString();

      this.seconds.text =
          (seconds % 60)
              .toString()
              .padLeft(2, '0');
    }
  }

  void dispose() {
    minutes.dispose();
    seconds.dispose();
  }
}