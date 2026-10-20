import '../../domain/models/memory.dart';
import '../../domain/models/workout_event.dart';

class MemoryExtractor {
  static Memory? extract(SetFeedbackEvent event) {
    final originalFeedback = event.feedbackText.trim();
    final feedback = _normalize(originalFeedback);

    if (!_containsFatigueSignal(feedback)) {
      return null;
    }

    return Memory(
      id: _memoryId(event),
      userId: event.userId,
      type: MemoryType.USER_REPORTED_FATIGUE,
      exercise: event.exercise,
      muscleGroup: event.muscleGroup,
      content: _buildContent(
        originalFeedback: originalFeedback,
        exercise: event.exercise,
      ),
      value: {
        'feedback': originalFeedback,
        'weight': event.weight,
        'reps': event.reps,
        'target_reps': event.targetReps,
        'set_index': event.setIndex,
      },
      confidence: 0.9,
      source: MemorySource.SET_FEEDBACK,
      status: MemoryStatus.ACTIVE,
      expiresAt: event.timestamp.add(const Duration(days: 14)),
      createdAt: event.timestamp,
      updatedAt: event.timestamp,
    );
  }

  static String _normalize(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static bool _containsFatigueSignal(String feedback) {
    if (feedback.isEmpty) return false;

    // Phủ định rõ ràng: không tạo memory mệt.
    const negations = [
      'không mệt',
      'khong met',
      'không bị mệt',
      'khong bi met',
      'not tired',
      'not fatigued',
      'not exhausted',
    ];

    if (negations.any(feedback.contains)) {
      return false;
    }

    // Các cụm từ cần được nhận diện như một cụm hoàn chỉnh.
    const phrases = [
      'không nổi',
      'khong noi',
      'quá nặng',
      'qua nang',
      'không thể tiếp tục',
      'khong the tiep tuc',
      'too heavy',
      'too tired',
      'give up',
      'gave up',
      'out of energy',
      "can't continue",
      'cannot continue',
      'could not continue',
      "couldn't continue",
      'not able to continue',
    ];

    if (phrases.any(feedback.contains)) {
      return true;
    }

    // Chỉ nhận từ độc lập, tránh "met" trong một từ dài hơn.
    const fatigueWords = [
      'mệt',
      'met',
      'đuối',
      'duoi',
      'exhausted',
      'fatigued',
      'failed',
    ];

    for (final word in fatigueWords) {
      final pattern = RegExp(
        r'(?<![a-z])' + RegExp.escape(word) + r'(?![a-z])',
      );

      if (pattern.hasMatch(feedback)) {
        return true;
      }
    }

    return false;
  }

  static String _buildContent({
    required String originalFeedback,
    required String exercise,
  }) {
    return 'Người dùng phản hồi "$originalFeedback" '
        'khi tập $exercise.';
  }

  static String _memoryId(SetFeedbackEvent event) {
    return [
      event.userId,
      event.exercise,
      event.timestamp.microsecondsSinceEpoch,
      event.setIndex,
    ].join('_');
  }
}
