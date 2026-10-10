import '../domain/models/memory.dart';
import '../domain/models/workout_event.dart';

class MemoryExtractor {
  static Memory? extract(SetFeedbackEvent event) {
    final feedback = event.feedbackText.trim().toLowerCase();

    if (!_containsFatigueSignal(feedback)) {
      return null;
    }

    return Memory(
      id: _memoryId(event),
      userId: event.userId,
      type: MemoryType.USER_REPORTED_FATIGUE,
      exercise: event.exercise,
      muscleGroup: event.muscleGroup,
      content: event.feedbackText.trim(),
      value: {
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

  static bool _containsFatigueSignal(String feedback) {
    const fatigueSignals = ['mệt', 'không nổi', 'quá nặng', 'đuối'];

    return fatigueSignals.any(feedback.contains);
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
