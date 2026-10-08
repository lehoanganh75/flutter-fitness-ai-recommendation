// ignore_for_file: constant_identifier_names

enum MemoryType { USER_REPORTED_FATIGUE, WEIGHT_PREFERENCE, PERFORMANCE_TREND }

enum MemorySource { SET_FEEDBACK, USER_RESPONSE, HISTORY }

enum MemoryStatus { ACTIVE, SUPERSEDED, ARCHIVED }

class Memory {
  const Memory({
    required this.id,
    required this.userId,
    required this.type,
    required this.exercise,
    this.muscleGroup,
    required this.content,
    required this.value,
    required this.confidence,
    required this.source,
    required this.status,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final MemoryType type;
  final String exercise;
  final String? muscleGroup;
  final String content;
  final Map<String, dynamic> value;
  final double confidence;
  final MemorySource source;
  final MemoryStatus status;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool isUsable(DateTime now) =>
      status == MemoryStatus.ACTIVE &&
      (expiresAt == null || expiresAt!.isAfter(now));
}
