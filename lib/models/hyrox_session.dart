class HyroxSession {
  final int? id;
  final int workoutId;

  final List<int> runTimesSeconds;
  final List<int> stationTimesSeconds;

  const HyroxSession({
    this.id,
    required this.workoutId,
    required this.runTimesSeconds,
    required this.stationTimesSeconds,
  });

  int get totalRunSeconds =>
      runTimesSeconds.fold(0, (sum, value) => sum + value);

  int get totalStationSeconds =>
      stationTimesSeconds.fold(0, (sum, value) => sum + value);

  int get totalSeconds =>
      totalRunSeconds + totalStationSeconds;
}