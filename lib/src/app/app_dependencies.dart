import '../data/database.dart';
import '../data/drift_memory_repository.dart';
import '../data/drift_workout_repository.dart';
import '../data/sample_data_seeder.dart';
import '../services/ai/ai_proxy_client.dart';
import '../services/daily_suggestion_service.dart';
import '../services/log_set_service.dart';
import '../services/memory/memory_pipeline.dart';
import '../services/memory/memory_retrieval.dart';
import '../services/stats_service.dart';
import '../services/suggestion_data_source.dart';
import '../services/workout_service.dart';

/// Người dùng cục bộ duy nhất.
const kLocalUserId = 'sample-user';

class AppDependencies {
  AppDependencies._({
    required this.database,
    required this.workoutRepository,
    required this.workoutService,
    required this.logSetService,
    required this.statsService,
    required this.dailySuggestionService,
  });

  final AppDatabase database;
  final DriftWorkoutRepository workoutRepository;
  final WorkoutService workoutService;
  final LogSetService logSetService;
  final StatsService statsService;
  final DailySuggestionService dailySuggestionService;

  // Truyền bằng --dart-define=GEMINI_API_KEY=...
  static const _geminiKey = String.fromEnvironment('GEMINI_API_KEY');

  static Future<AppDependencies> create() async {
    final database = await openAppDatabase();

    final workoutRepository = DriftWorkoutRepository(database);
    final memoryRepository = DriftMemoryRepository(database);

    await memoryRepository.debugPrintAllMemories();

    final seeder = SampleDataSeeder(workoutRepository);
    await seeder.seedIfEmpty(kLocalUserId);

    final proxy = _geminiKey.trim().isEmpty
        ? null
        : AiProxyClient(apiKey: _geminiKey);

    // Khởi tạo bộ đọc memory.
    final memoryRetrieval = MemoryRetrieval(memoryRepository);

    // Khởi tạo pipeline ghi memory.
    final memoryPipeline = MemoryPipeline(
      repo: memoryRepository,
      proxy: proxy,
      maxActivePerType: 5,
    );

    final data = SuggestionDataSource(workoutRepository);

    final dailySuggestionService = DailySuggestionService(
      proxy: proxy,
      retrieval: memoryRetrieval,
      loadRecentSessions: data.recentSessions,
      loadKnownExercises: data.knownExercises,
    );

    return AppDependencies._(
      database: database,
      workoutRepository: workoutRepository,
      workoutService: WorkoutService(workoutRepository),
      logSetService: LogSetService(
        workoutRepository: workoutRepository,
        memoryPipeline: memoryPipeline,
      ),
      statsService: StatsService(workoutRepository),
      dailySuggestionService: dailySuggestionService,
    );
  }

  Future<void> dispose() async {
    await database.close();
  }
}
