import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_recommendation/src/domain/models/memory.dart';
import 'package:fitness_recommendation/src/domain/models/workout_event.dart';
import 'package:fitness_recommendation/src/services/memory_extractor.dart';

SetFeedbackEvent createEvent(String feedback, {DateTime? timestamp}) {
  return SetFeedbackEvent(
    userId: 'user-001',
    exercise: 'Bench Press',
    muscleGroup: 'Chest',
    setIndex: 1,
    weight: 50,
    reps: 8,
    targetReps: 10,
    feedbackText: feedback,
    timestamp: timestamp ?? DateTime(2026, 10, 10, 18),
  );
}

void main() {
  test('extracts fatigue memory from set feedback', () {
    final event = SetFeedbackEvent(
      userId: 'user-001',
      exercise: 'Bench Press',
      muscleGroup: 'Chest',
      setIndex: 1,
      weight: 50,
      reps: 8,
      targetReps: 10,
      feedbackText: 'Mệt, không nổi',
      timestamp: DateTime(2026, 10, 10, 18),
    );

    final memory = MemoryExtractor.extract(event);

    expect(memory, isNotNull);
    expect(memory?.userId, 'user-001');
    expect(memory?.exercise, 'Bench Press');
    expect(memory?.muscleGroup, 'Chest');
    expect(memory?.type, MemoryType.USER_REPORTED_FATIGUE);
    expect(memory?.source, MemorySource.SET_FEEDBACK);
    expect(memory?.status, MemoryStatus.ACTIVE);
    expect(memory?.confidence, 0.9);
    expect(memory?.content, 'Mệt, không nổi');
  });

  test('ignores feedback without fatigue signal', () {
    final event = SetFeedbackEvent(
      userId: 'user-001',
      exercise: 'Bench Press',
      muscleGroup: 'Chest',
      setIndex: 1,
      weight: 50,
      reps: 10,
      targetReps: 10,
      feedbackText: 'Dễ',
      timestamp: DateTime(2026, 10, 10, 18),
    );

    final memory = MemoryExtractor.extract(event);

    expect(memory, isNull);
  });

  test('extracts fatigue memory from supported feedback signals', () {
    const fatigueFeedback = ['Mệt', 'Không nổi', 'Quá nặng', 'Đuối'];

    for (final feedback in fatigueFeedback) {
      final memory = MemoryExtractor.extract(createEvent(feedback));

      expect(memory, isNotNull, reason: feedback);
      expect(memory?.type, MemoryType.USER_REPORTED_FATIGUE);
      expect(memory?.source, MemorySource.SET_FEEDBACK);
    }
  });

  test('normalizes case and whitespace before extracting fatigue memory', () {
    final memory = MemoryExtractor.extract(createEvent('  MỆT  '));

    expect(memory, isNotNull);
    expect(memory?.content, 'MỆT');
    expect(memory?.type, MemoryType.USER_REPORTED_FATIGUE);
  });

  test('stores set context in memory value', () {
    final memory = MemoryExtractor.extract(createEvent('Quá nặng'));

    expect(memory, isNotNull);
    expect(memory?.value, {
      'weight': 50.0,
      'reps': 8,
      'target_reps': 10,
      'set_index': 1,
    });
  });

  test('sets fatigue memory expiration fourteen days after event', () {
    final timestamp = DateTime(2026, 10, 10, 18);

    final memory = MemoryExtractor.extract(
      createEvent('Mệt', timestamp: timestamp),
    );

    expect(memory?.expiresAt, timestamp.add(const Duration(days: 14)));
  });
  test('memory is usable before expiration', () {
    final timestamp = DateTime(2026, 10, 10, 18);

    final memory = MemoryExtractor.extract(
      createEvent('Mệt', timestamp: timestamp),
    );

    expect(memory?.isUsable(DateTime(2026, 10, 24, 17, 59)), true);
  });

  test('memory is not usable at expiration time', () {
    final timestamp = DateTime(2026, 10, 10, 18);

    final memory = MemoryExtractor.extract(
      createEvent('Mệt', timestamp: timestamp),
    );

    expect(memory?.isUsable(DateTime(2026, 10, 24, 18)), false);
  });

  test('memory is not usable after expiration', () {
    final timestamp = DateTime(2026, 10, 10, 18);

    final memory = MemoryExtractor.extract(
      createEvent('Mệt', timestamp: timestamp),
    );

    expect(memory?.isUsable(DateTime(2026, 10, 25)), false);
  });
}
