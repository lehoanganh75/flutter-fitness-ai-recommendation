import '../models/memory.dart';

abstract interface class MemoryRepository {
  Future<void> save(Memory memory);

  Future<List<Memory>> activeForExercise({
    required String userId,
    required String exercise,
    required DateTime now,
  });

  Future<bool> archive(String id);
}
