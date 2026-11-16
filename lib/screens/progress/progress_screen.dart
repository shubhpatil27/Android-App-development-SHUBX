import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/progress_analytics.dart';
import '../../models/user_preferences.dart';
import '../../services/progress_service.dart';

class ProgressScreen extends StatefulWidget {
  final UserPreferences preferences;

  const ProgressScreen({
    super.key,
    required this.preferences,
  });

  @override
  State<ProgressScreen> createState() =>
      _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _loading = true;
  String? _error;

  ProgressAnalytics? _analytics;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(
      covariant ProgressScreen oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.preferences != widget.preferences) {
      _load();
    }
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final analytics =
      await ProgressService.instance.calculate(
        widget.preferences,
      );

      if (!mounted) return;

      setState(() {
        _analytics = analytics;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  bool _hasTrainingType(String type) {
    return widget.preferences.trainingTypes.contains(
      type,
    );
  }

  bool get _showWeights =>
      _hasTrainingType('Weight Training');

  bool get _showRunning =>
      _hasTrainingType('Running');

  bool get _showHyrox =>
      _hasTrainingType('HYROX');

  bool get _showCardio =>
      _hasTrainingType('Cardio') ||
          _hasTrainingType('Cardio & Endurance');

  String _formatPace(double seconds) {
    int minutes = seconds ~/ 60;
    int remaining =
    (seconds % 60).round();

    if (remaining == 60) {
      minutes++;
      remaining = 0;
    }

    return '$minutes:${remaining.toString().padLeft(2, '0')} /km';
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes =
        (seconds % 3600) ~/ 60;
    final remaining =
        seconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
    }

    return '$minutes:${remaining.toString().padLeft(2, '0')}';
  }

  String _formatTrainingTime(int minutes) {
    final hours = minutes ~/ 60;
    final remaining =
        minutes % 60;

    if (hours == 0) {
      return '${minutes}m';
    }

    if (remaining == 0) {
      return '${hours}h';
    }

    return '${hours}h ${remaining}m';
  }

  String _clean(double value) {
    if ((value - value.round()).abs() < 0.05) {
      return value.round().toString();
    }

    return value.toStringAsFixed(1);
  }

  String _formatInteger(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShubXColors.black,
      body: SafeArea(
        child: RefreshIndicator(
          color: ShubXColors.gold,
          backgroundColor: ShubXColors.card,
          onRefresh: _load,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: const [
          SizedBox(height: 260),
          Center(
            child: CircularProgressIndicator(
              color: ShubXColors.gold,
            ),
          ),
        ],
      );
    }

    if (_error != null) {
      return ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 170),

          const Icon(
            Icons.error_outline,
            color: Colors.redAccent,
            size: 44,
          ),

          const SizedBox(height: 16),

          const Text(
            'COULD NOT LOAD PROGRESS',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ShubXColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ShubXColors.grey,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(
              Icons.refresh,
            ),
            label: const Text(
              'TRY AGAIN',
            ),
          ),
        ],
      );
    }

    if (_analytics == null) {
      return _empty();
    }

    return _content(
      _analytics!,
    );
  }

  Widget _content(
      ProgressAnalytics data,
      ) {
    return ListView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        20,
        24,
        20,
        120,
      ),
      children: [
        // ============================================
        // HEADER
        // ============================================

        const Text(
          'PROGRESS',
          style: TextStyle(
            color: ShubXColors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'See the work adding up.',
          style: TextStyle(
            color: ShubXColors.grey,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 32),

        // ============================================
        // CURRENT PROGRESS
        // ============================================

        const _SectionHeading(
          title: 'CURRENT PROGRESS',
          subtitle: 'LAST 2 WEEKS',
        ),

        const SizedBox(height: 14),

        _buildCurrentHero(data),

        const SizedBox(height: 12),

        _TwoCardRow(
          left: _StatCard(
            label: 'CURRENT STREAK',
            value: '${data.currentStreak}',
            suffix:
            data.currentStreak == 1
                ? 'day'
                : 'days',
            icon:
            Icons.local_fire_department_outlined,
          ),
          right: _StatCard(
            label: 'VS PREVIOUS',
            value:
            data.sessionChange > 0
                ? '+${data.sessionChange}'
                : '${data.sessionChange}',
            suffix: 'sessions',
            icon:
            data.sessionChange >= 0
                ? Icons.trending_up
                : Icons.trending_down,
          ),
        ),

        const SizedBox(height: 18),

        _TrainingBreakdown(
          title: 'LAST 2 WEEKS',
          values: data.recentByType,
        ),

        // ============================================
        // CURRENT RUNNING
        // ============================================

        if (_showRunning) ...[
          const SizedBox(height: 30),

          const _SubHeading(
            'RUNNING — CURRENT',
          ),

          const SizedBox(height: 10),

          _TwoCardRow(
            left: _StatCard(
              label: 'DISTANCE',
              value: _clean(
                data.recentRunningKm,
              ),
              suffix: 'km',
              icon:
              Icons.directions_run,
            ),
            right: _StatCard(
              label: 'AVG PACE',
              value: data
                  .recentAverageRunPaceSecondsPerKm ==
                  null
                  ? '--'
                  : _formatPace(
                data.recentAverageRunPaceSecondsPerKm!,
              ),
              suffix: '',
              icon: Icons.speed,
            ),
          ),

          if (data.runningPaceImprovement !=
              null) ...[
            const SizedBox(height: 10),

            _InsightCard(
              icon:
              data.runningPaceImprovement! >= 0
                  ? Icons.trending_up
                  : Icons.trending_down,
              text:
              data.runningPaceImprovement! >= 0
                  ? 'Average running pace improved ${data.runningPaceImprovement!.abs().toStringAsFixed(1)}% compared with the previous 2 weeks.'
                  : 'Average running pace is ${data.runningPaceImprovement!.abs().toStringAsFixed(1)}% slower than the previous 2 weeks.',
            ),
          ],
        ],

        // ============================================
        // OVERALL
        // ============================================

        const SizedBox(height: 42),

        const _SectionHeading(
          title: 'OVERALL PROGRESS',
          subtitle: 'ALL TIME',
        ),

        const SizedBox(height: 14),

        _TwoCardRow(
          left: _StatCard(
            label: 'SESSIONS',
            value:
            '${data.totalSessions}',
            suffix: 'total',
            icon:
            Icons.check_circle_outline,
          ),
          right: _StatCard(
            label: 'TRAINING TIME',
            value:
            _formatTrainingTime(
              data.totalMinutes,
            ),
            suffix: '',
            icon:
            Icons.timer_outlined,
          ),
        ),

        const SizedBox(height: 10),

        _TwoCardRow(
          left: _StatCard(
            label: 'LONGEST STREAK',
            value:
            '${data.longestStreak}',
            suffix:
            data.longestStreak == 1
                ? 'day'
                : 'days',
            icon:
            Icons.local_fire_department,
          ),
          right: _StatCard(
            label: 'WEEKLY TARGET',
            value:
            '${widget.preferences.weeklyTarget}',
            suffix: 'sessions',
            icon:
            Icons.flag_outlined,
          ),
        ),

        const SizedBox(height: 18),

        _TrainingBreakdown(
          title: 'ALL-TIME TRAINING',
          values: data.overallByType,
        ),

        // ============================================
        // RUNNING OVERALL
        // ============================================

        if (_showRunning) ...[
          const SizedBox(height: 30),

          const _SubHeading(
            'RUNNING — ALL TIME',
          ),

          const SizedBox(height: 10),

          _TwoCardRow(
            left: _StatCard(
              label: 'TOTAL DISTANCE',
              value: _clean(
                data.totalRunningKm,
              ),
              suffix: 'km',
              icon:
              Icons.route_outlined,
            ),
            right: _StatCard(
              label: 'BEST PACE',
              value: data
                  .bestRunPaceSecondsPerKm ==
                  null
                  ? '--'
                  : _formatPace(
                data.bestRunPaceSecondsPerKm!,
              ),
              suffix: '',
              icon: Icons.speed,
            ),
          ),
        ],

        // ============================================
        // WEIGHT TRAINING
        // ============================================

        if (_showWeights) ...[
          const SizedBox(height: 30),

          const _SubHeading(
            'WEIGHT TRAINING',
          ),

          const SizedBox(height: 10),

          _TwoCardRow(
            left: _StatCard(
              label: 'WORKOUTS',
              value:
              '${data.totalWeightSessions}',
              suffix: '',
              icon:
              Icons.fitness_center,
            ),
            right: _StatCard(
              label: 'SETS',
              value:
              '${data.totalWeightSets}',
              suffix: '',
              icon:
              Icons.format_list_numbered,
            ),
          ),

          const SizedBox(height: 10),

          _WideStatCard(
            label:
            'TOTAL TRAINING VOLUME',
            value:
            '${_clean(data.totalWeightVolumeKg)} kg',
            subtitle:
            'Recorded weight × reps across all sessions.',
            icon:
            Icons.monitor_weight_outlined,
          ),
        ],

        // ============================================
        // HYROX
        // ============================================

        if (_showHyrox) ...[
          const SizedBox(height: 30),

          const _SubHeading(
            'HYROX',
          ),

          const SizedBox(height: 10),

          _TwoCardRow(
            left: _StatCard(
              label: 'SESSIONS',
              value:
              '${data.hyroxSessions}',
              suffix: '',
              icon: Icons.bolt,
            ),
            right: _StatCard(
              label: 'BEST FULL SIM',
              value:
              data.bestHyroxSeconds ==
                  null
                  ? '--'
                  : _formatTime(
                data.bestHyroxSeconds!,
              ),
              suffix: '',
              icon:
              Icons.emoji_events_outlined,
            ),
          ),

          if (data
              .bestHyroxStationSeconds
              .isNotEmpty) ...[
            const SizedBox(height: 12),

            _HyroxStationCard(
              values: data
                  .bestHyroxStationSeconds,
              formatTime:
              _formatTime,
            ),
          ],
        ],

        // ============================================
        // WALKING
        // ============================================

        if (_showCardio &&
            (data.totalWalkingKm > 0 ||
                data.totalEstimatedSteps >
                    0)) ...[
          const SizedBox(height: 30),

          const _SubHeading(
            'WALKING',
          ),

          const SizedBox(height: 10),

          _TwoCardRow(
            left: _StatCard(
              label: 'DISTANCE',
              value: _clean(
                data.totalWalkingKm,
              ),
              suffix: 'km',
              icon:
              Icons.directions_walk,
            ),
            right: _StatCard(
              label: 'EST. STEPS',
              value:
              _formatInteger(
                data.totalEstimatedSteps,
              ),
              suffix: '',
              icon:
              Icons.directions_walk_outlined,
            ),
          ),
        ],

        const SizedBox(height: 30),
      ],
    );
  }

  // ==================================================
  // CURRENT HERO
  // ==================================================

  Widget _buildCurrentHero(
      ProgressAnalytics data,
      ) {
    final completed =
        data.recentSessions;

    final target =
        data.recentTarget;

    final overTarget =
        target > 0 &&
            completed > target;

    final targetReached =
        target > 0 &&
            completed >= target;

    final difference =
        completed - target;

    final double progress;

    if (target <= 0) {
      progress = 0.0;
    } else {
      progress =
          (completed / target)
              .clamp(
            0.0,
            1.0,
          )
              .toDouble();
    }

    String status;

    if (target <= 0) {
      status =
      'Set a weekly target to track goal completion.';
    } else if (overTarget) {
      status =
      '+$difference above your two-week target ✓';
    } else if (targetReached) {
      status =
      'Two-week target complete ✓';
    } else {
      final remaining =
          target - completed;

      status =
      '$remaining session${remaining == 1 ? '' : 's'} remaining to reach your two-week target.';
    }

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: ShubXColors.card,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color:
          ShubXColors.gold
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
            'SESSIONS COMPLETED',
            style: TextStyle(
              color: ShubXColors.grey,
              fontSize: 9,
              fontWeight:
              FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            crossAxisAlignment:
            CrossAxisAlignment.end,
            children: [
              Text(
                '$completed',
                style: const TextStyle(
                  color:
                  ShubXColors.white,
                  fontSize: 42,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),

              const SizedBox(width: 8),

              Padding(
                padding:
                const EdgeInsets.only(
                  bottom: 7,
                ),
                child: Text(
                  'sessions',
                  style:
                  const TextStyle(
                    color:
                    ShubXColors.grey,
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Text(
            target > 0
                ? 'Two-week target: $target'
                : 'No target set',
            style: const TextStyle(
              color: ShubXColors.grey,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 16),

          ClipRRect(
            borderRadius:
            BorderRadius.circular(20),
            child:
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor:
              ShubXColors.charcoal,
              color:
              ShubXColors.gold,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              if (targetReached) ...[
                const Icon(
                  Icons.check_circle,
                  color:
                  ShubXColors.gold,
                  size: 16,
                ),

                const SizedBox(width: 7),
              ],

              Expanded(
                child: Text(
                  status,
                  style:
                  const TextStyle(
                    color:
                    ShubXColors.grey,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _empty() {
    return ListView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      padding:
      const EdgeInsets.all(24),
      children: const [
        SizedBox(height: 200),

        Icon(
          Icons.show_chart,
          color:
          ShubXColors.darkGrey,
          size: 45,
        ),

        SizedBox(height: 14),

        Center(
          child: Text(
            'No progress data yet.',
            style: TextStyle(
              color:
              ShubXColors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

// ====================================================
// TWO CARD ROW
// ====================================================

class _TwoCardRow
    extends StatelessWidget {
  final Widget left;
  final Widget right;

  const _TwoCardRow({
    required this.left,
    required this.right,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Expanded(
          child: left,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: right,
        ),
      ],
    );
  }
}

// ====================================================
// SECTION HEADING
// ====================================================

class _SectionHeading
    extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeading({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color:
              ShubXColors.gold,
              fontSize: 12,
              fontWeight:
              FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ),

        Text(
          subtitle,
          style: const TextStyle(
            color:
            ShubXColors.grey,
            fontSize: 9,
            fontWeight:
            FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ====================================================
// SUBHEADING
// ====================================================

class _SubHeading
    extends StatelessWidget {
  final String text;

  const _SubHeading(
      this.text,
      );

  @override
  Widget build(
      BuildContext context,
      ) {
    return Text(
      text,
      style: const TextStyle(
        color:
        ShubXColors.white,
        fontSize: 17,
        fontWeight:
        FontWeight.w800,
      ),
    );
  }
}

// ====================================================
// STAT CARD
// ====================================================

class _StatCard
    extends StatelessWidget {
  final String label;
  final String value;
  final String suffix;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.suffix,
    required this.icon,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      height: 148,
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ShubXColors.card,
        borderRadius:
        BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color:
            ShubXColors.gold,
            size: 20,
          ),

          const SizedBox(height: 16),

          Expanded(
            child: Align(
              alignment:
              Alignment.bottomLeft,
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                    style:
                    const TextStyle(
                      color:
                      ShubXColors.white,
                      fontSize: 20,
                      fontWeight:
                      FontWeight.w900,
                      height: 1.05,
                    ),
                  ),

                  if (suffix.isNotEmpty) ...[
                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      suffix,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style:
                      const TextStyle(
                        color:
                        ShubXColors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],

                  const SizedBox(height: 7),

                  Text(
                    label,
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                    style:
                    const TextStyle(
                      color:
                      ShubXColors.grey,
                      fontSize: 9,
                      fontWeight:
                      FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================
// WIDE STAT
// ====================================================

class _WideStatCard
    extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;

  const _WideStatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ShubXColors.card,
        borderRadius:
        BorderRadius.circular(17),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color:
            ShubXColors.gold,
            size: 25,
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                  const TextStyle(
                    color:
                    ShubXColors.grey,
                    fontSize: 9,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value,
                  style:
                  const TextStyle(
                    color:
                    ShubXColors.white,
                    fontSize: 22,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style:
                  const TextStyle(
                    color:
                    ShubXColors.grey,
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================
// BREAKDOWN
// ====================================================

class _TrainingBreakdown
    extends StatelessWidget {
  final String title;
  final Map<String, int> values;

  const _TrainingBreakdown({
    required this.title,
    required this.values,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final total =
    values.values.fold<int>(
      0,
          (sum, value) =>
      sum + value,
    );

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ShubXColors.card,
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color:
              ShubXColors.grey,
              fontSize: 10,
              fontWeight:
              FontWeight.w700,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 16),

          if (total == 0)
            const Text(
              'No sessions yet.',
              style: TextStyle(
                color:
                ShubXColors.grey,
              ),
            )
          else
            ...values.entries.map(
                  (entry) {
                final percentage =
                    entry.value / total;

                return Padding(
                  padding:
                  const EdgeInsets.only(
                    bottom: 14,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              style:
                              const TextStyle(
                                color:
                                ShubXColors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),

                          Text(
                            '${entry.value}',
                            style:
                            const TextStyle(
                              color:
                              ShubXColors.gold,
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      ClipRRect(
                        borderRadius:
                        BorderRadius.circular(
                          10,
                        ),
                        child:
                        LinearProgressIndicator(
                          value:
                          percentage,
                          minHeight: 5,
                          backgroundColor:
                          ShubXColors.charcoal,
                          color:
                          ShubXColors.gold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

// ====================================================
// INSIGHT
// ====================================================

class _InsightCard
    extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InsightCard({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color:
        ShubXColors.gold
            .withValues(
          alpha: 0.07,
        ),
        borderRadius:
        BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color:
            ShubXColors.gold,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              text,
              style:
              const TextStyle(
                color:
                ShubXColors.grey,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================
// HYROX STATIONS
// ====================================================

class _HyroxStationCard
    extends StatelessWidget {
  final Map<String, int> values;

  final String Function(int)
  formatTime;

  const _HyroxStationCard({
    required this.values,
    required this.formatTime,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ShubXColors.card,
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'BEST STATION TIMES',
            style: TextStyle(
              color:
              ShubXColors.gold,
              fontSize: 10,
              fontWeight:
              FontWeight.w700,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 14),

          ...values.entries.map(
                (entry) {
              return Padding(
                padding:
                const EdgeInsets.symmetric(
                  vertical: 7,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style:
                        const TextStyle(
                          color:
                          ShubXColors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ),

                    Text(
                      formatTime(
                        entry.value,
                      ),
                      style:
                      const TextStyle(
                        color:
                        ShubXColors.white,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}