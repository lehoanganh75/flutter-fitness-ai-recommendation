import '../data/database.dart';
import '../data/drift_memory_repository.dart';
import '../data/drift_workout_repository.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_service.dart';
import '../services/log_set_service.dart';
import '../services/workout_service.dart';

class AppDependencies {
  AppDependencies._({
    required this.database,
    required this.workoutService,
    required this.logSetService,
    required this.authController,
  });

  final AppDatabase database;
  final WorkoutService workoutService;
  final LogSetService logSetService;
  final AuthController authController;

  static Future<AppDependencies> create() async {
    final database = await openAppDatabase();
    final workoutRepository = DriftWorkoutRepository(database);
    final memoryRepository = DriftMemoryRepository(database);
    final authService = FakeAuthService();
    return AppDependencies._(
      database: database,
      workoutService: WorkoutService(workoutRepository),
      logSetService: LogSetService(
        workoutRepository: workoutRepository,
        memoryRepository: memoryRepository,
      ),
      authController: AuthController(authService: authService),
    );
  }

  Future<void> dispose() => database.close();
}
