import 'dart:convert';

import 'package:flutter/foundation.dart';
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

    debugPrint('[DriftMemoryRepository] userId=$userId, exercise=$exercise');
    debugPrint('[DriftMemoryRepository] Matched rows: ${rows.length}');

    final memories = rows.map(_toDomain).toList();

    for (final memory in memories) {
      debugPrint(
        '[DriftMemoryRepository] id=${memory.id}, '
        'exercise=${memory.exercise}, '
        'status=${memory.status.name}, '
        'expiresAt=${memory.expiresAt}, '
        'usable=${memory.isUsable(now)}',
      );
    }

    return memories.where((memory) => memory.isUsable(now)).toList();
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

  Future<void> debugPrintAllMemories() async {
    final rows = await database.select(database.memories).get();

    debugPrint('========== ALL STORED MEMORIES ==========');
    debugPrint('TOTAL ROWS: ${rows.length}');

    for (final row in rows) {
      debugPrint(
        'id=${row.id}, '
        'userId=${row.userId}, '
        'exercise="${row.exercise}", '
        'type=${row.type}, '
        'status=${row.status}, '
        'expiresAt=${row.expiresAt}, '
        'content="${row.content}"',
      );
    }

    debugPrint('=========================================');
  }
}
