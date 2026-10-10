import '../data/database.dart';
import '../data/drift_memory_repository.dart';
import '../data/drift_workout_repository.dart';
import '../services/log_set_service.dart';
import '../services/workout_service.dart';

class AppDependencies {
  AppDependencies._({
    required this.database,
    required this.workoutService,
    required this.logSetService,
  });

  final AppDatabase database;
  final WorkoutService workoutService;
  final LogSetService logSetService;

  static Future<AppDependencies> create() async {
    final database = await openAppDatabase();
    final workoutRepository = DriftWorkoutRepository(database);
    final memoryRepository = DriftMemoryRepository(database);
    return AppDependencies._(
      database: database,
      workoutService: WorkoutService(workoutRepository),
      logSetService: LogSetService(
        workoutRepository: workoutRepository,
        memoryRepository: memoryRepository,
      ),
    );
  }

  Future<void> dispose() => database.close();
}
