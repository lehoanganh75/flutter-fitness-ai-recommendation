import 'package:fitness_recommendation/src/domain/models/recommendation.dart';
import 'package:fitness_recommendation/src/domain/models/workout_event.dart';
import 'package:fitness_recommendation/src/services/memory/memory_pipeline.dart';
import 'package:fitness_recommendation/src/services/memory/memory_retrieval.dart';
import 'package:fitness_recommendation/src/services/recommendation/ai_recommendation.dart';
import 'package:fitness_recommendation/src/services/recommendation/recommendation_context.dart';
import 'package:fitness_recommendation/src/services/recommendation/recommendation_provider.dart';

/// Container: Memory Service. Điều phối luồng ghi và luồng đọc.
class MemoryService implements RecommendationProvider {
  MemoryService({
    required this._pipeline,
    required this._retrieval,
    required this._ai,
  });

  final MemoryPipeline _pipeline;
  final MemoryRetrieval _retrieval;
  final AiRecommendation _ai;

  /// Luồng ghi: gọi sau mỗi lần người dùng gửi feedback cho set.
  Future<void> onSetFeedback(SetFeedbackEvent event) async {
    await _pipeline.ingest(event);
  }

  /// Luồng đọc: Retrieval -> Context -> AI/Recommendation.
  @override
  Future<Recommendation> recommend({
    required RecommendationContext context,
  }) async {
    final memories = await _retrieval.retrieve(
      userId: context.userId,
      exercise: context.exercise,
    );
    return _ai.generate(
      context: context,
      memoryContext: MemoryRetrieval.describe(memories),
    );
  }
}
