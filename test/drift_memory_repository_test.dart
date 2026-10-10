import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_recommendation/src/data/database.dart' as data;
import 'package:fitness_recommendation/src/data/drift_memory_repository.dart';
import 'package:fitness_recommendation/src/domain/memory.dart' as domain;

void main() {
  late data.AppDatabase database;
  late DriftMemoryRepository repository;

  setUp(() {
    database = data.AppDatabase(NativeDatabase.memory());
    repository = DriftMemoryRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('saves and retrieves active memory for an exercise', () async {
    final memory = domain.Memory(
      id: 'memory-001',
      userId: 'user-001',
      type: domain.MemoryType.USER_REPORTED_FATIGUE,
      exercise: 'Bench Press',
      muscleGroup: 'Chest',
      content: 'Mệt, không nổi',
      value: {'weight': 50.0, 'reps': 8},
      confidence: 0.9,
      source: domain.MemorySource.SET_FEEDBACK,
      status: domain.MemoryStatus.ACTIVE,
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
    expect(result.single.value['weight'], 50.0);
  });

  test('does not return expired memory', () async {
    await repository.save(
      domain.Memory(
        id: 'memory-001',
        userId: 'user-001',
        type: domain.MemoryType.USER_REPORTED_FATIGUE,
        exercise: 'Bench Press',
        content: 'Mệt',
        value: const {},
        confidence: 0.9,
        source: domain.MemorySource.SET_FEEDBACK,
        status: domain.MemoryStatus.ACTIVE,
        expiresAt: DateTime(2026, 10, 10),
        createdAt: DateTime(2026, 9, 26),
        updatedAt: DateTime(2026, 9, 26),
      ),
    );

    final result = await repository.activeForExercise(
      userId: 'user-001',
      exercise: 'Bench Press',
      now: DateTime(2026, 10, 11),
    );

    expect(result, isEmpty);
  });

  test('archives memory', () async {
    await repository.save(
      domain.Memory(
        id: 'memory-001',
        userId: 'user-001',
        type: domain.MemoryType.USER_REPORTED_FATIGUE,
        exercise: 'Bench Press',
        content: 'Mệt',
        value: const {},
        confidence: 0.9,
        source: domain.MemorySource.SET_FEEDBACK,
        status: domain.MemoryStatus.ACTIVE,
        expiresAt: DateTime(2026, 10, 24),
        createdAt: DateTime(2026, 10, 10),
        updatedAt: DateTime(2026, 10, 10),
      ),
    );

    final archived = await repository.archive('memory-001');

    expect(archived, true);

    final result = await repository.activeForExercise(
      userId: 'user-001',
      exercise: 'Bench Press',
      now: DateTime(2026, 10, 11),
    );

    expect(result, isEmpty);
  });
  test('updates an existing memory with the same id', () async {
    final original = domain.Memory(
      id: 'memory-001',
      userId: 'user-001',
      type: domain.MemoryType.USER_REPORTED_FATIGUE,
      exercise: 'Bench Press',
      content: 'Mệt',
      value: {'weight': 50.0},
      confidence: 0.8,
      source: domain.MemorySource.SET_FEEDBACK,
      status: domain.MemoryStatus.ACTIVE,
      expiresAt: DateTime(2026, 10, 24),
      createdAt: DateTime(2026, 10, 10),
      updatedAt: DateTime(2026, 10, 10),
    );

    final updated = domain.Memory(
      id: 'memory-001',
      userId: 'user-001',
      type: domain.MemoryType.USER_REPORTED_FATIGUE,
      exercise: 'Bench Press',
      content: 'Mệt hơn',
      value: {'weight': 55.0},
      confidence: 0.95,
      source: domain.MemorySource.SET_FEEDBACK,
      status: domain.MemoryStatus.ACTIVE,
      expiresAt: DateTime(2026, 10, 25),
      createdAt: DateTime(2026, 10, 10),
      updatedAt: DateTime(2026, 10, 11),
    );

    await repository.save(original);
    await repository.save(updated);

    final result = await repository.activeForExercise(
      userId: 'user-001',
      exercise: 'Bench Press',
      now: DateTime(2026, 10, 11),
    );

    expect(result, hasLength(1));
    expect(result.single.content, 'Mệt hơn');
    expect(result.single.value['weight'], 55.0);
    expect(result.single.confidence, 0.95);
  });
}
