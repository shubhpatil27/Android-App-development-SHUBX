class HyroxTrainingSegment {
  final int? id;
  final int sessionId;
  final String segmentType;
  final String segmentName;
  final int segmentOrder;
  final int durationSeconds;

  const HyroxTrainingSegment({
    this.id,
    required this.sessionId,
    required this.segmentType,
    required this.segmentName,
    required this.segmentOrder,
    required this.durationSeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'segment_type': segmentType,
      'segment_name': segmentName,
      'segment_order': segmentOrder,
      'duration_seconds': durationSeconds,
    };
  }

  factory HyroxTrainingSegment.fromMap(
      Map<String, dynamic> map,
      ) {
    return HyroxTrainingSegment(
      id: map['id'] as int?,
      sessionId: map['session_id'] as int,
      segmentType: map['segment_type'] as String,
      segmentName: map['segment_name'] as String,
      segmentOrder: map['segment_order'] as int,
      durationSeconds: map['duration_seconds'] as int,
    );
  }
}

class HyroxTrainingSession {
  final int? id;
  final int workoutId;
  final List<HyroxTrainingSegment> segments;

  const HyroxTrainingSession({
    this.id,
    required this.workoutId,
    required this.segments,
  });

  int get totalSeconds {
    return segments.fold<int>(
      0,
          (sum, segment) =>
      sum + segment.durationSeconds,
    );
  }
}