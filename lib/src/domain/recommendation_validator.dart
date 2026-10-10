import 'recommendation.dart';

class RecommendationValidator {
  static void validate(Recommendation recommendation) {
    if (recommendation.exercise.trim().isEmpty) {
      throw const FormatException('Exercise name must not be empty');
    }

    if (recommendation.currentWeight <= 0) {
      throw const FormatException('Current weight must be greater than zero');
    }

    if (recommendation.suggestedWeight < 0) {
      throw const FormatException('Suggested weight must not be negative');
    }

    if (recommendation.targetReps < 1 || recommendation.targetReps > 30) {
      throw const FormatException('Target reps must be between 1 and 30');
    }

    if (recommendation.confidence < 0 || recommendation.confidence > 1) {
      throw const FormatException('Confidence must be between 0 and 1');
    }

    final weightChangePercent =
        (recommendation.suggestedWeight - recommendation.currentWeight).abs() /
        recommendation.currentWeight;

    if (weightChangePercent > 0.20) {
      throw const FormatException(
        'Suggested weight cannot change by more than 20 percent',
      );
    }
    switch (recommendation.action) {
      case RecommendationAction.DECREASE_WEIGHT:
        if (recommendation.suggestedWeight >= recommendation.currentWeight) {
          throw const FormatException(
            'Decrease weight must be lower than current weight',
          );
        }
        break;

      case RecommendationAction.INCREASE_WEIGHT:
        if (recommendation.suggestedWeight <= recommendation.currentWeight) {
          throw const FormatException(
            'Increase weight must be higher than current weight',
          );
        }
        break;

      case RecommendationAction.KEEP_WEIGHT:
        if (recommendation.suggestedWeight != recommendation.currentWeight) {
          throw const FormatException('Keep weight must equal current weight');
        }
        break;

      case RecommendationAction.REST:
        break;
    }
  }
}
