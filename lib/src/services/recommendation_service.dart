import 'package:fitness_recommendation/src/domain/recommendation_validator.dart';

import '../domain/recommendation.dart';

class RecommendationContext {
  const RecommendationContext({
    required this.exercise,
    required this.currentWeight,
    required this.targetReps,
    required this.recentFeedback,
  });

  final String exercise;
  final double currentWeight;
  final int targetReps;
  final List<String> recentFeedback;
}

abstract interface class RecommendationProvider {
  Future<Recommendation> recommend({required RecommendationContext context});
}

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

    if (context.currentWeight <= 0) {
      throw const FormatException('Current weight must be greater than zero');
    }

    if (context.targetReps < 1 || context.targetReps > 30) {
      throw const FormatException('Target reps must be between 1 and 30');
    }
  }
}
