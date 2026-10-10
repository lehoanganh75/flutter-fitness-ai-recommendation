import 'dart:convert';

import 'package:drift/drift.dart';

import '../domain/models/memory.dart' as domain;
import '../domain/repositories/memory_repository.dart';
import 'database.dart' as data;

class DriftMemoryRepository implements MemoryRepository {
  const DriftMemoryRepository(this.database);

  final data.AppDatabase database;

  @override
  Future<void> save(domain.Memory memory) async {
    await database
        .into(database.memories)
        .insertOnConflictUpdate(
          data.MemoriesCompanion.insert(
            id: memory.id,
            userId: memory.userId,
            type: memory.type.name,
            exercise: memory.exercise,
            muscleGroup: Value(memory.muscleGroup),
            content: memory.content,
            valueJson: jsonEncode(memory.value),
            confidence: memory.confidence,
            source: memory.source.name,
            status: memory.status.name,
            expiresAt: Value(memory.expiresAt),
            createdAt: memory.createdAt,
            updatedAt: memory.updatedAt,
          ),
        );
  }

  @override
  Future<List<domain.Memory>> activeForExercise({
    required String userId,
    required String exercise,
    required DateTime now,
  }) async {
    final rows =
        await (database.select(database.memories)..where(
              (table) =>
                  table.userId.equals(userId) &
                  table.exercise.equals(exercise) &
                  table.status.equals(domain.MemoryStatus.ACTIVE.name),
            ))
            .get();

    return rows.map(_toDomain).where((memory) => memory.isUsable(now)).toList();
  }

  @override
  Future<bool> archive(String id) async {
    final updated =
        await (database.update(
          database.memories,
        )..where((table) => table.id.equals(id))).write(
          data.MemoriesCompanion(
            status: const Value('ARCHIVED'),
            updatedAt: Value(DateTime.now()),
          ),
        );

    return updated > 0;
  }

  domain.Memory _toDomain(data.Memory row) {
    return domain.Memory(
      id: row.id,
      userId: row.userId,
      type: domain.MemoryType.values.byName(row.type),
      exercise: row.exercise,
      muscleGroup: row.muscleGroup,
      content: row.content,
      value: Map<String, dynamic>.from(jsonDecode(row.valueJson) as Map),
      confidence: row.confidence,
      source: domain.MemorySource.values.byName(row.source),
      status: domain.MemoryStatus.values.byName(row.status),
      expiresAt: row.expiresAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
