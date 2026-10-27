// ignore_for_file: constant_identifier_names

// ══════════════════════════════════════════════════════════════
// RAW NOTE — User gõ trực tiếp, KHÔNG qua AI
// ══════════════════════════════════════════════════════════════

/// Nguồn gốc raw note: feedback khi tập set, hoặc user tự ghi
enum RawNoteSource { SET_FEEDBACK, USER_RESPONSE, MANUAL }

/// Trạng thái: active (còn dùng), archived (đã cũ)
enum RawNoteStatus { ACTIVE, ARCHIVED }

class RawNote {
  const RawNote({
    required this.id,
    required this.userId,
    required this.exercise,
    this.muscleGroup,
    required this.content,
    required this.metadata,
    required this.source,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String exercise;
  final String? muscleGroup;

  /// NGUYÊN VĂN user gõ — KHÔNG qua AI
  final String content;

  /// Metadata từ event: weight, reps, target_reps, set_index...
  final Map<String, dynamic> metadata;

  final RawNoteSource source;
  final RawNoteStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool isUsable() => status == RawNoteStatus.ACTIVE;

  RawNote copyWith({RawNoteStatus? status, DateTime? updatedAt}) {
    return RawNote(
      id: id,
      userId: userId,
      exercise: exercise,
      muscleGroup: muscleGroup,
      content: content,
      metadata: metadata,
      source: source,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// ══════════════════════════════════════════════════════════════
// AI INSIGHT — AI suy luận từ RawNote, CÓ THỂ SAI
// ══════════════════════════════════════════════════════════════

enum MemoryType { USER_REPORTED_FATIGUE, WEIGHT_PREFERENCE, PERFORMANCE_TREND }

enum MemoryStatus { ACTIVE, SUPERSEDED, ARCHIVED }

class AiInsight {
  const AiInsight({
    required this.id,
    required this.userId,
    required this.type,
    required this.exercise,
    this.muscleGroup,
    required this.content,
    required this.evidence,
    required this.rawNoteId,
    required this.value,
    required this.confidence,
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

  /// TÓM TẮT do AI sinh — có thể sai, cần confidence
  final String content;

  /// Trích dẫn từ RawNote gốc — để user verify
  final String evidence;

  /// ID của RawNote đã sinh ra insight này
  final String rawNoteId;

  final Map<String, dynamic> value;
  final double confidence;
  final MemoryStatus status;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool isUsable(DateTime now) =>
      status == MemoryStatus.ACTIVE &&
      (expiresAt == null || expiresAt!.isAfter(now));

  AiInsight copyWith({
    Map<String, dynamic>? value,
    double? confidence,
    MemoryStatus? status,
    DateTime? expiresAt,
    DateTime? updatedAt,
  }) {
    return AiInsight(
      id: id,
      userId: userId,
      type: type,
      exercise: exercise,
      muscleGroup: muscleGroup,
      content: content,
      evidence: evidence,
      rawNoteId: rawNoteId,
      value: value ?? this.value,
      confidence: confidence ?? this.confidence,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
