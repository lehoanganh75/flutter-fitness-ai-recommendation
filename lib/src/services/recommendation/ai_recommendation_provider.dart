import 'package:fitness_recommendation/src/domain/models/recommendation.dart';
import 'package:fitness_recommendation/src/services/memory/memory_retrieval.dart';
import 'package:fitness_recommendation/src/services/recommendation/ai_recommendation.dart';
import 'package:fitness_recommendation/src/services/recommendation/recommendation_context.dart';
import 'package:fitness_recommendation/src/services/recommendation/recommendation_provider.dart';

/// Adapter: nối AiRecommendation (cần memoryContext) với RecommendationProvider.
///
/// Trách nhiệm:
/// - Nhận context từ RecommendationService
/// - Tự động lấy & describe memory từ MemoryRetrieval
/// - Gọi AiRecommendation.generate() với đủ 2 tham số
class AiRecommendationProvider implements RecommendationProvider {
  const AiRecommendationProvider({required this._ai, required this._retrieval});

  final AiRecommendation _ai;
  final MemoryRetrieval _retrieval;

  /// Thực hiện gợi ý: lấy memory → gọi AI.
  ///
  /// Flow:
  /// 1. Retrieve memory từ userId + exercise
  /// 2. Describe memory thành text context
  /// 3. Gọi AI generate với context + memory context
  /// 4. Trả Recommendation về
  @override
  Future<Recommendation> recommend({
    required RecommendationContext context,
  }) async {
    // Bước 1: Lấy memory liên quan đến bài tập này cho user
    final memories = await _retrieval.retrieve(
      userId: context.userId,
      exercise: context.exercise,
    );

    // Bước 2: Convert memory objects thành text description
    // (MemoryRetrieval.describe là static helper để format memory)
    final memoryContext = MemoryRetrieval.describe(memories);

    // Bước 3: Gọi AI generate với memory context đã chuẩn bị
    final recommendation = await _ai.generate(
      context: context,
      memoryContext: memoryContext,
    );

    return recommendation;
  }
}
