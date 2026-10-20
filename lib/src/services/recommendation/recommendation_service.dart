import 'package:fitness_recommendation/src/domain/models/recommendation.dart';

import 'recommendation_context.dart';
import 'recommendation_provider.dart';
import 'recommendation_validator.dart';

// Re-export để nơi chỉ import `recommendation_service.dart` (ví dụ test và
// `home_screen.dart`) vẫn thấy `RecommendationContext` và
// `RecommendationProvider` — chúng từng được định nghĩa ngay tại đây.
export 'recommendation_context.dart' show RecommendationContext;
export 'recommendation_provider.dart' show RecommendationProvider;

class RecommendationService {
  const RecommendationService({required this.provider});

  final RecommendationProvider provider;

  Future<Recommendation> recommend({
    required RecommendationContext context,
  }) async {
    _validateContext(context);
    final recommendation = await provider.recommend(context: context);

    RecommendationValidator.validate(recommendation);

    if (recommendation.exercise != context.exercise) {
      throw const FormatException(
        'Recommendation exercise does not match context',
      );
    }

    if (recommendation.currentWeight != context.currentWeight) {
      throw const FormatException(
        'Recommendation current weight does not match context',
      );
    }

    if (recommendation.targetReps != context.targetReps) {
      throw const FormatException(
        'Recommendation target reps do not match context',
      );
    }

    return recommendation;
  }

  static void _validateContext(RecommendationContext context) {
    if (context.exercise.trim().isEmpty) {
      throw const FormatException('Exercise name must not be empty');
    }

    // 0 = bài tập bằng trọng lượng cơ thể.
    if (context.currentWeight < 0) {
      throw const FormatException('Current weight must not be negative');
    }

    if (context.targetReps < 1 || context.targetReps > 30) {
      throw const FormatException('Target reps must be between 1 and 30');
    }
  }
}
