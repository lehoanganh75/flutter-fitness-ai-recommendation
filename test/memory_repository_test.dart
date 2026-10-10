import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_recommendation/src/domain/memory.dart';
import 'package:fitness_recommendation/src/domain/repositories/memory_repository.dart';

class FakeMemoryRepository implements MemoryRepository {
  final List<Memory> memories = [];

  @override
  Future<void> save(Memory memory) async {
    memories.add(memory);
  }

  @override
  Future<List<Memory>> activeForExercise({
    required String userId,
    required String exercise,
    required DateTime now,
  }) async {
    return memories.where((memory) {
      return memory.userId == userId &&
          memory.exercise == exercise &&
          memory.isUsable(now);
    }).toList();
  }

  @override
  Future<bool> archive(String id) async {
    final index = memories.indexWhere((memory) => memory.id == id);

    if (index == -1) {
      return false;
    }

    final memory = memories[index];

    memories[index] = Memory(
      id: memory.id,
      userId: memory.userId,
      type: memory.type,
      exercise: memory.exercise,
      muscleGroup: memory.muscleGroup,
      content: memory.content,
      value: memory.value,
      confidence: memory.confidence,
      source: memory.source,
      status: MemoryStatus.ARCHIVED,
      expiresAt: memory.expiresAt,
      createdAt: memory.createdAt,
      updatedAt: memory.updatedAt,
    );

    return true;
  }
}

void main() {
  test('saves and retrieves active memories for an exercise', () async {
    final repository = FakeMemoryRepository();

    final memory = Memory(
      id: 'memory-001',
      userId: 'user-001',
      type: MemoryType.USER_REPORTED_FATIGUE,
      exercise: 'Bench Press',
      muscleGroup: 'Chest',
      content: 'Mệt, không nổi',
      value: {'weight': 50.0, 'reps': 8},
      confidence: 0.9,
      source: MemorySource.SET_FEEDBACK,
      status: MemoryStatus.ACTIVE,
      expiresAt: DateTime(2026, 10, 24),
      createdAt: DateTime(2026, 10, 10),
      updatedAt: DateTime(2026, 10, 10),
    );

    await repository.save(memory);

    final result = await repository.activeForExercise(
      userId: 'user-001',
      exercise: 'Bench Press',
      now: DateTime(2026, 10, 11),
    );

    expect(result, hasLength(1));
    expect(result.single.id, 'memory-001');
    expect(result.single.content, 'Mệt, không nổi');
  });

  test('does not return memories for another exercise', () async {
    final repository = FakeMemoryRepository();

    await repository.save(
      Memory(
        id: 'memory-001',
        userId: 'user-001',
        type: MemoryType.USER_REPORTED_FATIGUE,
        exercise: 'Bench Press',
        content: 'Mệt',
        value: const {},
        confidence: 0.9,
        source: MemorySource.SET_FEEDBACK,
        status: MemoryStatus.ACTIVE,
        expiresAt: DateTime(2026, 10, 24),
        createdAt: DateTime(2026, 10, 10),
        updatedAt: DateTime(2026, 10, 10),
      ),
    );

    final result = await repository.activeForExercise(
      userId: 'user-001',
      exercise: 'Squat',
      now: DateTime(2026, 10, 11),
    );

    expect(result, isEmpty);
  });

  test('archives an existing memory', () async {
    final repository = FakeMemoryRepository();

    await repository.save(
      Memory(
        id: 'memory-001',
        userId: 'user-001',
        type: MemoryType.USER_REPORTED_FATIGUE,
        exercise: 'Bench Press',
        content: 'Mệt',
        value: const {},
        confidence: 0.9,
        source: MemorySource.SET_FEEDBACK,
        status: MemoryStatus.ACTIVE,
        expiresAt: DateTime(2026, 10, 24),
        createdAt: DateTime(2026, 10, 10),
        updatedAt: DateTime(2026, 10, 10),
      ),
    );

    final archived = await repository.archive('memory-001');

    final result = await repository.activeForExercise(
      userId: 'user-001',
      exercise: 'Bench Press',
      now: DateTime(2026, 10, 11),
    );

    expect(archived, true);
    expect(result, isEmpty);
  });

  test('returns false when archiving an unknown memory', () async {
    final repository = FakeMemoryRepository();

    final archived = await repository.archive('missing-memory');

    expect(archived, false);
  });
}
