import 'package:fitness_recommendation/src/domain/models/recommendation.dart';

class RecommendationValidator {
  static void validate(Recommendation recommendation) {
    if (recommendation.exercise.trim().isEmpty) {
      throw const FormatException('Exercise name must not be empty');
    }

    // 0 = bài tập bằng trọng lượng cơ thể.
    if (recommendation.currentWeight < 0) {
      throw const FormatException('Current weight must not be negative');
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

    if (recommendation.currentWeight == 0) {
      // Không tính % được: chỉ cho phép thêm tạ nhẹ.
      if (recommendation.suggestedWeight >
          Recommendation.maxBodyweightAddedKg) {
        throw const FormatException(
          'Bodyweight exercise cannot jump above 10 kg',
        );
      }
    } else {
      final weightChangePercent =
          (recommendation.suggestedWeight - recommendation.currentWeight)
              .abs() /
          recommendation.currentWeight;

      if (weightChangePercent > 0.20) {
        throw const FormatException(
          'Suggested weight cannot change by more than 20 percent',
        );
      }
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
