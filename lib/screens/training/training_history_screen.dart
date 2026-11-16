import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/workout.dart';
import '../../services/database_service.dart';
import 'workout_detail_screen.dart';

enum _HistoryView {
  list,
  calendar,
}

class TrainingHistoryScreen extends StatefulWidget {
  const TrainingHistoryScreen({
    super.key,
  });

  @override
  State<TrainingHistoryScreen> createState() =>
      _TrainingHistoryScreenState();
}

class _TrainingHistoryScreenState
    extends State<TrainingHistoryScreen> {
  bool _loading = true;

  List<Workout> _workouts = [];

  _HistoryView _view = _HistoryView.list;

  String _filter = 'All';

  late DateTime _visibleMonth;

  DateTime? _selectedDate;

  final List<String> _filters = const [
    'All',
    'Weights',
    'Running',
    'HYROX',
    'Cardio',
  ];

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _visibleMonth = DateTime(
      now.year,
      now.month,
    );

    _selectedDate = DateTime(
      now.year,
      now.month,
      now.day,
    );

    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    final workouts =
    await DatabaseService.instance.getAllWorkouts();

    if (!mounted) return;

    setState(() {
      _workouts = workouts;
      _loading = false;
    });
  }

  bool _matchesFilter(
      Workout workout,
      ) {
    switch (_filter) {
      case 'Weights':
        return workout.type == 'Weight Training';

      case 'Running':
        return workout.type == 'Running';

      case 'HYROX':
        return workout.type == 'HYROX';

      case 'Cardio':
        return workout.type == 'Cardio' ||
            workout.type == 'Cardio & Endurance';

      default:
        return true;
    }
  }

  List<Workout> get _filteredWorkouts {
    return _workouts
        .where(_matchesFilter)
        .toList();
  }

  DateTime _dateOnly(
      DateTime date,
      ) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  bool _sameDay(
      DateTime a,
      DateTime b,
      ) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  List<Workout> _workoutsForDate(
      DateTime date,
      ) {
    return _filteredWorkouts
        .where(
          (workout) => _sameDay(
        workout.date,
        date,
      ),
    )
        .toList();
  }

  Future<void> _openWorkout(
      Workout workout,
      ) async {
    final changed =
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => WorkoutDetailScreen(
          workout: workout,
        ),
      ),
    );

    if (changed == true) {
      await _loadWorkouts();
    }
  }

  void _previousMonth() {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month - 1,
      );

      _selectedDate = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + 1,
      );

      _selectedDate = null;
    });
  }

  String _monthName(
      int month,
      ) {
    const months = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];

    return months[month - 1];
  }

  String _shortMonth(
      int month,
      ) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  String _listGroupTitle(
      DateTime date,
      ) {
    return '${_monthName(date.month)} ${date.year}';
  }

  IconData _iconForWorkout(
      Workout workout,
      ) {
    switch (workout.type) {
      case 'Weight Training':
        return Icons.fitness_center;

      case 'Running':
        return Icons.directions_run;

      case 'HYROX':
        return Icons.bolt;

      case 'Cardio':
      case 'Cardio & Endurance':
        if (workout.title == 'Walking') {
          return Icons.directions_walk;
        }

        if (workout.title == 'Cycling') {
          return Icons.directions_bike;
        }

        if (workout.title == 'Swimming') {
          return Icons.pool;
        }

        if (workout.title == 'Hiking') {
          return Icons.hiking;
        }

        if (workout.title == 'Rowing') {
          return Icons.rowing;
        }

        return Icons.favorite_outline;

      default:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShubXColors.black,
      appBar: AppBar(
        backgroundColor: ShubXColors.black,
        elevation: 0,
        title: const Text(
          'TRAINING HISTORY',
          style: TextStyle(
            color: ShubXColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildViewSelector(),

            const SizedBox(height: 14),

            _buildFilters(),

            const SizedBox(height: 14),

            Expanded(
              child: _loading
                  ? const Center(
                child:
                CircularProgressIndicator(
                  color: ShubXColors.gold,
                ),
              )
                  : _view == _HistoryView.list
                  ? _buildListView()
                  : _buildCalendarView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: ShubXColors.card,
          borderRadius:
          BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: _ViewButton(
                label: 'LIST',
                icon: Icons.view_list_outlined,
                selected:
                _view == _HistoryView.list,
                onTap: () {
                  setState(() {
                    _view = _HistoryView.list;
                  });
                },
              ),
            ),

            Expanded(
              child: _ViewButton(
                label: 'CALENDAR',
                icon:
                Icons.calendar_month_outlined,
                selected:
                _view == _HistoryView.calendar,
                onTap: () {
                  setState(() {
                    _view =
                        _HistoryView.calendar;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];

          final selected =
              _filter == filter;

          return ChoiceChip(
            label: Text(
              filter.toUpperCase(),
            ),
            selected: selected,
            showCheckmark: false,
            onSelected: (_) {
              setState(() {
                _filter = filter;
              });
            },
            backgroundColor:
            ShubXColors.card,
            selectedColor:
            ShubXColors.gold,
            side: BorderSide(
              color: selected
                  ? ShubXColors.gold
                  : ShubXColors.darkGrey,
            ),
            labelStyle: TextStyle(
              color: selected
                  ? ShubXColors.black
                  : ShubXColors.grey,
              fontSize: 10,
              fontWeight:
              FontWeight.w700,
            ),
          );
        },
      ),
    );
  }

  // ==================================================
  // LIST VIEW
  // ==================================================

  Widget _buildListView() {
    final workouts =
        _filteredWorkouts;

    if (workouts.isEmpty) {
      return _buildEmptyHistory();
    }

    final grouped =
    <String, List<Workout>>{};

    for (final workout in workouts) {
      final key =
      _listGroupTitle(
        workout.date,
      );

      grouped.putIfAbsent(
        key,
            () => [],
      );

      grouped[key]!.add(workout);
    }

    return RefreshIndicator(
      color: ShubXColors.gold,
      backgroundColor:
      ShubXColors.card,
      onRefresh: _loadWorkouts,
      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          20,
          6,
          20,
          40,
        ),
        children: [
          for (final entry
          in grouped.entries) ...[
            Padding(
              padding:
              const EdgeInsets.only(
                top: 14,
                bottom: 10,
              ),
              child: Text(
                entry.key,
                style: const TextStyle(
                  color:
                  ShubXColors.gold,
                  fontSize: 11,
                  fontWeight:
                  FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ),

            ...entry.value.map(
                  (workout) =>
                  _HistoryWorkoutCard(
                    workout: workout,
                    icon:
                    _iconForWorkout(
                      workout,
                    ),
                    dateLabel:
                    '${_shortMonth(workout.date.month)} ${workout.date.day}',
                    onTap: () {
                      _openWorkout(
                        workout,
                      );
                    },
                  ),
            ),
          ],
        ],
      ),
    );
  }

  // ==================================================
  // CALENDAR
  // ==================================================

  Widget _buildCalendarView() {
    final firstDay =
    DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
      1,
    );

    final daysInMonth =
        DateTime(
          _visibleMonth.year,
          _visibleMonth.month + 1,
          0,
        ).day;

    // Monday = first column.
    final leadingEmpty =
        firstDay.weekday - 1;

    final totalCells =
        leadingEmpty +
            daysInMonth;

    final rowCount =
    (totalCells / 7).ceil();

    final selectedWorkouts =
    _selectedDate == null
        ? <Workout>[]
        : _workoutsForDate(
      _selectedDate!,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        20,
        4,
        20,
        40,
      ),
      children: [
        Row(
          children: [
            IconButton(
              onPressed:
              _previousMonth,
              icon: const Icon(
                Icons.chevron_left,
                color:
                ShubXColors.white,
              ),
            ),

            Expanded(
              child: Text(
                '${_monthName(_visibleMonth.month)} ${_visibleMonth.year}',
                textAlign:
                TextAlign.center,
                style:
                const TextStyle(
                  color:
                  ShubXColors.white,
                  fontSize: 16,
                  fontWeight:
                  FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),

            IconButton(
              onPressed: _nextMonth,
              icon: const Icon(
                Icons.chevron_right,
                color:
                ShubXColors.white,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        const Row(
          children: [
            _WeekdayLabel('MON'),
            _WeekdayLabel('TUE'),
            _WeekdayLabel('WED'),
            _WeekdayLabel('THU'),
            _WeekdayLabel('FRI'),
            _WeekdayLabel('SAT'),
            _WeekdayLabel('SUN'),
          ],
        ),

        const SizedBox(height: 8),

        for (int row = 0;
        row < rowCount;
        row++)
          Row(
            children: [
              for (int column = 0;
              column < 7;
              column++)
                Expanded(
                  child: _buildCalendarCell(
                    cellIndex:
                    row * 7 +
                        column,
                    leadingEmpty:
                    leadingEmpty,
                    daysInMonth:
                    daysInMonth,
                  ),
                ),
            ],
          ),

        const SizedBox(height: 28),

        if (_selectedDate != null) ...[
          Text(
            '${_monthName(_selectedDate!.month)} ${_selectedDate!.day}',
            style: const TextStyle(
              color:
              ShubXColors.gold,
              fontSize: 12,
              fontWeight:
              FontWeight.w700,
              letterSpacing: 1.3,
            ),
          ),

          const SizedBox(height: 12),

          if (selectedWorkouts.isEmpty)
            Container(
              padding:
              const EdgeInsets.all(
                20,
              ),
              decoration: BoxDecoration(
                color:
                ShubXColors.card,
                borderRadius:
                BorderRadius.circular(
                  16,
                ),
              ),
              child: const Text(
                'No training recorded on this day.',
                style: TextStyle(
                  color:
                  ShubXColors.grey,
                ),
              ),
            )
          else
            ...selectedWorkouts.map(
                  (workout) =>
                  _HistoryWorkoutCard(
                    workout: workout,
                    icon:
                    _iconForWorkout(
                      workout,
                    ),
                    dateLabel:
                    workout.type,
                    onTap: () {
                      _openWorkout(
                        workout,
                      );
                    },
                  ),
            ),
        ],
      ],
    );
  }

  Widget _buildCalendarCell({
    required int cellIndex,
    required int leadingEmpty,
    required int daysInMonth,
  }) {
    final day =
        cellIndex -
            leadingEmpty +
            1;

    if (day < 1 ||
        day > daysInMonth) {
      return const SizedBox(
        height: 64,
      );
    }

    final date = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
      day,
    );

    final workouts =
    _workoutsForDate(date);

    final selected =
        _selectedDate != null &&
            _sameDay(
              _selectedDate!,
              date,
            );

    final today =
    _sameDay(
      date,
      DateTime.now(),
    );

    return InkWell(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      borderRadius:
      BorderRadius.circular(12),
      child: Container(
        height: 64,
        margin:
        const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: selected
              ? ShubXColors.gold
              .withValues(
            alpha: 0.12,
          )
              : Colors.transparent,
          borderRadius:
          BorderRadius.circular(12),
          border: selected
              ? Border.all(
            color:
            ShubXColors.gold,
          )
              : today
              ? Border.all(
            color:
            ShubXColors
                .darkGrey,
          )
              : null,
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                color: selected
                    ? ShubXColors.gold
                    : ShubXColors.white,
                fontSize: 13,
                fontWeight: today ||
                    selected
                    ? FontWeight.w800
                    : FontWeight.w500,
              ),
            ),

            const SizedBox(height: 7),

            if (workouts.isNotEmpty)
              _CalendarDots(
                workouts: workouts,
              )
            else
              const SizedBox(
                height: 8,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            const Icon(
              Icons.history,
              color:
              ShubXColors.darkGrey,
              size: 42,
            ),

            const SizedBox(height: 14),

            const Text(
              'No training found.',
              style: TextStyle(
                color:
                ShubXColors.white,
                fontSize: 17,
                fontWeight:
                FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              _filter == 'All'
                  ? 'Your completed sessions will appear here.'
                  : 'No $_filter sessions have been recorded yet.',
              textAlign:
              TextAlign.center,
              style: const TextStyle(
                color:
                ShubXColors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================================================
// CALENDAR DOTS
// ====================================================

class _CalendarDots
    extends StatelessWidget {
  final List<Workout> workouts;

  const _CalendarDots({
    required this.workouts,
  });

  @override
  Widget build(BuildContext context) {
    // Maximum 3 dots so busy days don't destroy
    // the calendar layout.
    final count =
    workouts.length > 3
        ? 3
        : workouts.length;

    return Row(
      mainAxisSize:
      MainAxisSize.min,
      children: [
        for (int i = 0;
        i < count;
        i++)
          Container(
            width: 5,
            height: 5,
            margin:
            const EdgeInsets
                .symmetric(
              horizontal: 1.5,
            ),
            decoration:
            const BoxDecoration(
              color:
              ShubXColors.gold,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}

// ====================================================
// WEEKDAY
// ====================================================

class _WeekdayLabel
    extends StatelessWidget {
  final String text;

  const _WeekdayLabel(
      this.text,
      );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        textAlign:
        TextAlign.center,
        style: const TextStyle(
          color:
          ShubXColors.grey,
          fontSize: 9,
          fontWeight:
          FontWeight.w700,
        ),
      ),
    );
  }
}

// ====================================================
// VIEW BUTTON
// ====================================================

class _ViewButton
    extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ViewButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(11),
      child: AnimatedContainer(
        duration:
        const Duration(
          milliseconds: 160,
        ),
        padding:
        const EdgeInsets.symmetric(
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: selected
              ? ShubXColors.gold
              : Colors.transparent,
          borderRadius:
          BorderRadius.circular(11),
        ),
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: selected
                  ? ShubXColors.black
                  : ShubXColors.grey,
            ),

            const SizedBox(width: 7),

            Text(
              label,
              style: TextStyle(
                color: selected
                    ? ShubXColors.black
                    : ShubXColors.grey,
                fontSize: 11,
                fontWeight:
                FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================================================
// HISTORY WORKOUT CARD
// ====================================================

class _HistoryWorkoutCard
    extends StatelessWidget {
  final Workout workout;
  final IconData icon;
  final String dateLabel;
  final VoidCallback onTap;

  const _HistoryWorkoutCard({
    required this.workout,
    required this.icon,
    required this.dateLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 9,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(16),
        child: Container(
          padding:
          const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color:
            ShubXColors.card,
            borderRadius:
            BorderRadius.circular(
              16,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration:
                BoxDecoration(
                  color:
                  ShubXColors.gold
                      .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(12),
                ),
                child: Icon(
                  icon,
                  color:
                  ShubXColors.gold,
                  size: 20,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      workout.title,
                      style:
                      const TextStyle(
                        color:
                        ShubXColors
                            .white,
                        fontSize: 14,
                        fontWeight:
                        FontWeight
                            .w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      workout.durationMinutes >
                          0
                          ? '${workout.type} • ${workout.durationMinutes} min'
                          : workout.type,
                      style:
                      const TextStyle(
                        color:
                        ShubXColors
                            .grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                dateLabel,
                style: const TextStyle(
                  color:
                  ShubXColors.grey,
                  fontSize: 10,
                ),
              ),

              const SizedBox(width: 4),

              const Icon(
                Icons.chevron_right,
                color:
                ShubXColors.darkGrey,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}