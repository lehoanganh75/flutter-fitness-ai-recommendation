import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_recommendation/src/domain/models/recommendation.dart';
import 'package:fitness_recommendation/src/services/recommendation_validator.dart';

void main() {
  test('accepts decrease weight when suggested weight is lower', () {
    final recommendation = Recommendation(
      action: RecommendationAction.DECREASE_WEIGHT,
      exercise: 'Bench Press',
      currentWeight: 50,
      suggestedWeight: 40,
      targetReps: 10,
      reason: RecommendationReason.USER_REPORTED_FATIGUE,
      confidence: 0.92,
    );

    expect(
      () => RecommendationValidator.validate(recommendation),
      returnsNormally,
    );
  });

  test('rejects decrease weight when suggested weight is higher', () {
    final recommendation = Recommendation(
      action: RecommendationAction.DECREASE_WEIGHT,
      exercise: 'Bench Press',
      currentWeight: 50,
      suggestedWeight: 60,
      targetReps: 10,
      reason: RecommendationReason.USER_REPORTED_FATIGUE,
      confidence: 0.92,
    );

    expect(
      () => RecommendationValidator.validate(recommendation),
      throwsA(isA<FormatException>()),
    );
  });
  test('accepts increase weight when suggested weight is higher', () {
    final recommendation = Recommendation(
      action: RecommendationAction.INCREASE_WEIGHT,
      exercise: 'Bench Press',
      currentWeight: 50,
      suggestedWeight: 60,
      targetReps: 10,
      reason: RecommendationReason.PROGRESSION,
      confidence: 0.9,
    );

    expect(
      () => RecommendationValidator.validate(recommendation),
      returnsNormally,
    );
  });

  test('rejects increase weight when suggested weight is lower', () {
    final recommendation = Recommendation(
      action: RecommendationAction.INCREASE_WEIGHT,
      exercise: 'Bench Press',
      currentWeight: 50,
      suggestedWeight: 40,
      targetReps: 10,
      reason: RecommendationReason.PROGRESSION,
      confidence: 0.9,
    );

    expect(
      () => RecommendationValidator.validate(recommendation),
      throwsA(isA<FormatException>()),
    );
  });

  test('accepts keep weight when suggested weight is unchanged', () {
    final recommendation = Recommendation(
      action: RecommendationAction.KEEP_WEIGHT,
      exercise: 'Bench Press',
      currentWeight: 50,
      suggestedWeight: 50,
      targetReps: 10,
      reason: RecommendationReason.NO_DATA,
      confidence: 0.5,
    );

    expect(
      () => RecommendationValidator.validate(recommendation),
      returnsNormally,
    );
  });

  test('rejects keep weight when suggested weight changes', () {
    final recommendation = Recommendation(
      action: RecommendationAction.KEEP_WEIGHT,
      exercise: 'Bench Press',
      currentWeight: 50,
      suggestedWeight: 45,
      targetReps: 10,
      reason: RecommendationReason.NO_DATA,
      confidence: 0.5,
    );

    expect(
      () => RecommendationValidator.validate(recommendation),
      throwsA(isA<FormatException>()),
    );
  });

  test('accepts rest recommendation', () {
    final recommendation = Recommendation(
      action: RecommendationAction.REST,
      exercise: 'Bench Press',
      currentWeight: 50,
      suggestedWeight: 50,
      targetReps: 10,
      reason: RecommendationReason.USER_REPORTED_FATIGUE,
      confidence: 0.95,
    );

    expect(
      () => RecommendationValidator.validate(recommendation),
      returnsNormally,
    );
  });
  test('rejects non-positive current weight', () {
    final recommendation = Recommendation(
      action: RecommendationAction.KEEP_WEIGHT,
      exercise: 'Bench Press',
      currentWeight: 0,
      suggestedWeight: 0,
      targetReps: 10,
      reason: RecommendationReason.NO_DATA,
      confidence: 0.5,
    );

    expect(
      () => RecommendationValidator.validate(recommendation),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects negative suggested weight', () {
    final recommendation = Recommendation(
      action: RecommendationAction.DECREASE_WEIGHT,
      exercise: 'Bench Press',
      currentWeight: 50,
      suggestedWeight: -1,
      targetReps: 10,
      reason: RecommendationReason.USER_REPORTED_FATIGUE,
      confidence: 0.9,
    );

    expect(
      () => RecommendationValidator.validate(recommendation),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects target reps outside valid range', () {
    final recommendation = Recommendation(
      action: RecommendationAction.KEEP_WEIGHT,
      exercise: 'Bench Press',
      currentWeight: 50,
      suggestedWeight: 50,
      targetReps: 31,
      reason: RecommendationReason.NO_DATA,
      confidence: 0.5,
    );

    expect(
      () => RecommendationValidator.validate(recommendation),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects confidence outside valid range', () {
    final recommendation = Recommendation(
      action: RecommendationAction.KEEP_WEIGHT,
      exercise: 'Bench Press',
      currentWeight: 50,
      suggestedWeight: 50,
      targetReps: 10,
      reason: RecommendationReason.NO_DATA,
      confidence: 1.1,
    );

    expect(
      () => RecommendationValidator.validate(recommendation),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects empty exercise name', () {
    final recommendation = Recommendation(
      action: RecommendationAction.KEEP_WEIGHT,
      exercise: '   ',
      currentWeight: 50,
      suggestedWeight: 50,
      targetReps: 10,
      reason: RecommendationReason.NO_DATA,
      confidence: 0.5,
    );

    expect(
      () => RecommendationValidator.validate(recommendation),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects weight change above twenty percent', () {
    final recommendation = Recommendation(
      action: RecommendationAction.DECREASE_WEIGHT,
      exercise: 'Bench Press',
      currentWeight: 50,
      suggestedWeight: 35,
      targetReps: 10,
      reason: RecommendationReason.USER_REPORTED_FATIGUE,
      confidence: 0.9,
    );

    expect(
      () => RecommendationValidator.validate(recommendation),
      throwsA(isA<FormatException>()),
    );
  });
}
