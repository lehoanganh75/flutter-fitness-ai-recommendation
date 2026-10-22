import 'package:flutter/foundation.dart';
import 'package:fitness_recommendation/src/services/weight_advice_service.dart';

import '../data/database.dart';
import '../data/drift_memory_repository.dart';
import '../data/drift_workout_repository.dart';
import '../data/sample_data_seeder.dart';
import '../services/ai/ai_proxy_client.dart';
import '../services/daily_suggestion_service.dart';
import '../services/log_set_service.dart';
import '../services/memory/memory_pipeline.dart';
import '../services/memory/memory_retrieval.dart';
import '../services/recommendation/ai_recommendation.dart';
import '../services/recommendation/ai_recommendation_provider.dart';
import '../services/recommendation/recommendation_service.dart';
import '../services/stats_service.dart';
import '../services/suggestion_data_source.dart';
import '../services/workout_service.dart';

const kLocalUserId = 'sample-user';

class AppDependencies {
  AppDependencies._({
    required this.database,
    required this.workoutRepository,
    required this.workoutService,
    required this.logSetService,
    required this.statsService,
    required this.dailySuggestionService,
    required this.recommendationService,
    required this.weightAdviceService,
  });

  final AppDatabase database;
  final DriftWorkoutRepository workoutRepository;
  final WorkoutService workoutService;
  final LogSetService logSetService;
  final StatsService statsService;
  final DailySuggestionService dailySuggestionService;
  final RecommendationService? recommendationService;
  final WeightAdviceService? weightAdviceService;

  static const _proxyUrl = String.fromEnvironment('PROXY_URL');
  static const _proxyToken = String.fromEnvironment('PROXY_TOKEN');

  static Future<AppDependencies> create() async {
    final stopwatch = Stopwatch()..start();
    var previousLap = 0;

    void logStep(String name) {
      final elapsed = stopwatch.elapsedMilliseconds;
      final stepDuration = elapsed - previousLap;
      previousLap = elapsed;

      debugPrint(
        '[Startup] $name: ${stepDuration}ms '
        '(total: ${elapsed}ms)',
      );
    }

    debugPrint('[Startup] Bắt đầu khởi tạo dependencies');

    final database = await openAppDatabase();
    logStep('openAppDatabase');

    final workoutRepository = DriftWorkoutRepository(database);
    final memoryRepository = DriftMemoryRepository(database);
    logStep('create repositories');

    final seeder = SampleDataSeeder(workoutRepository);
    await seeder.seedIfEmpty(kLocalUserId);
    logStep('seedIfEmpty');

    final hasAiConfig =
        _proxyUrl.trim().isNotEmpty && _proxyToken.trim().isNotEmpty;

    final proxy = hasAiConfig
        ? AiProxyClient(proxyUrl: _proxyUrl, proxyToken: _proxyToken)
        : null;

    final memoryRetrieval = MemoryRetrieval(memoryRepository);

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
      workoutRepository: workoutRepository, // THÊM DÒNG NÀY
    );

    final aiRecommendation = proxy != null ? AiRecommendation(proxy) : null;

    final aiRecommendationProvider = aiRecommendation != null
        ? AiRecommendationProvider(
            ai: aiRecommendation,
            retrieval: memoryRetrieval,
          )
        : null;

    final recommendationService = aiRecommendationProvider != null
        ? RecommendationService(provider: aiRecommendationProvider)
        : null;

    final weightAdviceService = recommendationService != null
        ? WeightAdviceService(workoutRepository, recommendationService)
        : null;

    logStep('create services');

    final dependencies = AppDependencies._(
      database: database,
      workoutRepository: workoutRepository,
      workoutService: WorkoutService(workoutRepository),
      logSetService: LogSetService(
        workoutRepository: workoutRepository,
        memoryPipeline: memoryPipeline,
      ),
      statsService: StatsService(workoutRepository),
      dailySuggestionService: dailySuggestionService,
      recommendationService: recommendationService,
      weightAdviceService: weightAdviceService,
    );

    logStep('complete');
    stopwatch.stop();

    return dependencies;
  }

  Future<void> dispose() async {
    await database.close();
  }
}
