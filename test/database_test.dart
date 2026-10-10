import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_recommendation/src/data/database.dart';

void main() {
  test('creates memories table', () async {
    final database = AppDatabase(NativeDatabase.memory());

    final inserted = await database
        .into(database.memories)
        .insert(
          MemoriesCompanion.insert(
            id: 'memory-001',
            userId: 'user-001',
            type: 'USER_REPORTED_FATIGUE',
            exercise: 'Bench Press',
            muscleGroup: const Value('Chest'),
            content: 'Mệt, không nổi',
            valueJson: '{"weight":50.0,"reps":8}',
            confidence: 0.9,
            source: 'SET_FEEDBACK',
            status: 'ACTIVE',
            expiresAt: Value(DateTime(2026, 10, 24)),
            createdAt: DateTime(2026, 10, 10),
            updatedAt: DateTime(2026, 10, 10),
          ),
        );

    expect(inserted, 1);

    final rows = await database.select(database.memories).get();

    expect(rows, hasLength(1));
    expect(rows.single.id, 'memory-001');
    expect(rows.single.exercise, 'Bench Press');
    expect(rows.single.status, 'ACTIVE');

    await database.close();
  });
}
