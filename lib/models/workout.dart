class Workout {
  final int? id;
  final String type;
  final String title;
  final DateTime date;
  final int durationMinutes;
  final bool completed;
  final DateTime createdAt;

  const Workout({
    this.id,
    required this.type,
    required this.title,
    required this.date,
    required this.durationMinutes,
    this.completed = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'date': date.toIso8601String(),
      'duration_minutes': durationMinutes,
      'completed': completed ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'] as int?,
      type: map['type'] as String,
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
      durationMinutes: map['duration_minutes'] as int,
      completed: (map['completed'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Workout copyWith({
    int? id,
    String? type,
    String? title,
    DateTime? date,
    int? durationMinutes,
    bool? completed,
    DateTime? createdAt,
  }) {
    return Workout(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      date: date ?? this.date,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}