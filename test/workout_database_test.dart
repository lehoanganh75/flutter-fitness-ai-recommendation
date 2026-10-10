import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_recommendation/src/data/database.dart';

void main() {
  test('stores workout plan', () async {
    final database = AppDatabase(NativeDatabase.memory());

    await database
        .into(database.workoutPlans)
        .insert(
          WorkoutPlansCompanion.insert(
            id: 'plan-001',
            userId: 'user-001',
            title: 'Push Day',
            dayOfWeek: 1,
            createdAt: DateTime(2026, 10, 10),
            syncStatus: 'pending',
          ),
        );

    final rows = await database.select(database.workoutPlans).get();

    expect(rows, hasLength(1));
    expect(rows.single.id, 'plan-001');
    expect(rows.single.userId, 'user-001');
    expect(rows.single.title, 'Push Day');
    expect(rows.single.dayOfWeek, 1);
    expect(rows.single.syncStatus, 'pending');

    await database.close();
  });
}
