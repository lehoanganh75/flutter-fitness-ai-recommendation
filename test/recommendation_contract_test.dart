import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_recommendation/src/domain/recommendation.dart';

void main() {
  test('encodes recommendation as stable JSON contract', () {
    final recommendation = Recommendation(
      action: RecommendationAction.DECREASE_WEIGHT,
      exercise: 'Bench Press',
      currentWeight: 50,
      suggestedWeight: 40,
      targetReps: 10,
      reason: RecommendationReason.USER_REPORTED_FATIGUE,
      confidence: 0.92,
    );

    expect(recommendation.toJson(), {
      'action': 'decrease_weight',
      'exercise': 'Bench Press',
      'current_weight': 50.0,
      'suggested_weight': 40.0,
      'target_reps': 10,
      'reason': 'user_reported_fatigue',
    });
  });
  test('decodes recommendation from stable JSON contract', () {
    final recommendation = Recommendation.fromJson({
      'action': 'decrease_weight',
      'exercise': 'Bench Press',
      'current_weight': 50.0,
      'suggested_weight': 40.0,
      'target_reps': 10,
      'reason': 'user_reported_fatigue',
      'confidence': 0.92,
    });

    expect(recommendation.action, RecommendationAction.DECREASE_WEIGHT);
    expect(recommendation.exercise, 'Bench Press');
    expect(recommendation.currentWeight, 50.0);
    expect(recommendation.suggestedWeight, 40.0);
    expect(recommendation.targetReps, 10);
    expect(recommendation.reason, RecommendationReason.USER_REPORTED_FATIGUE);
    expect(recommendation.confidence, 0.92);
  });
  test('rejects unknown action from JSON', () {
    expect(
      () => Recommendation.fromJson({
        'action': 'unknown_action',
        'exercise': 'Bench Press',
        'current_weight': 50.0,
        'suggested_weight': 40.0,
        'target_reps': 10,
        'reason': 'user_reported_fatigue',
      }),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects unknown reason from JSON', () {
    expect(
      () => Recommendation.fromJson({
        'action': 'decrease_weight',
        'exercise': 'Bench Press',
        'current_weight': 50.0,
        'suggested_weight': 40.0,
        'target_reps': 10,
        'reason': 'unknown_reason',
      }),
      throwsA(isA<FormatException>()),
    );
  });
  test('rejects confidence below zero', () {
    expect(
      () => Recommendation.fromJson({
        'action': 'decrease_weight',
        'exercise': 'Bench Press',
        'current_weight': 50.0,
        'suggested_weight': 40.0,
        'target_reps': 10,
        'reason': 'user_reported_fatigue',
        'confidence': -0.1,
      }),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects confidence above one', () {
    expect(
      () => Recommendation.fromJson({
        'action': 'decrease_weight',
        'exercise': 'Bench Press',
        'current_weight': 50.0,
        'suggested_weight': 40.0,
        'target_reps': 10,
        'reason': 'user_reported_fatigue',
        'confidence': 1.1,
      }),
      throwsA(isA<FormatException>()),
    );
  });

  test('accepts a recommendation with a twenty percent weight change', () {
    final recommendation = Recommendation.fromJson({
      'action': 'decrease_weight',
      'exercise': 'Bench Press',
      'current_weight': 50.0,
      'suggested_weight': 40.0,
      'target_reps': 10,
      'reason': 'user_reported_fatigue',
      'confidence': 0.92,
    });

    expect(recommendation.currentWeight, 50.0);
    expect(recommendation.suggestedWeight, 40.0);
  });

  test('rejects a weight change above twenty percent', () {
    expect(
      () => Recommendation.fromJson({
        'action': 'decrease_weight',
        'exercise': 'Bench Press',
        'current_weight': 50.0,
        'suggested_weight': 35.0,
        'target_reps': 10,
        'reason': 'user_reported_fatigue',
        'confidence': 0.92,
      }),
      throwsA(isA<FormatException>()),
    );
  });
  test('accepts a recommendation with a twenty percent weight change', () {
    final recommendation = Recommendation.fromJson({
      'action': 'decrease_weight',
      'exercise': 'Bench Press',
      'current_weight': 50.0,
      'suggested_weight': 40.0,
      'target_reps': 10,
      'reason': 'user_reported_fatigue',
      'confidence': 0.92,
    });

    expect(recommendation.currentWeight, 50.0);
    expect(recommendation.suggestedWeight, 40.0);
  });

  test('rejects a weight change above twenty percent', () {
    expect(
      () => Recommendation.fromJson({
        'action': 'decrease_weight',
        'exercise': 'Bench Press',
        'current_weight': 50.0,
        'suggested_weight': 35.0,
        'target_reps': 10,
        'reason': 'user_reported_fatigue',
        'confidence': 0.92,
      }),
      throwsA(isA<FormatException>()),
    );
  });
  test('rejects target reps below one', () {
    expect(
      () => Recommendation.fromJson({
        'action': 'decrease_weight',
        'exercise': 'Bench Press',
        'current_weight': 50.0,
        'suggested_weight': 40.0,
        'target_reps': 0,
        'reason': 'user_reported_fatigue',
        'confidence': 0.92,
      }),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects target reps above thirty', () {
    expect(
      () => Recommendation.fromJson({
        'action': 'decrease_weight',
        'exercise': 'Bench Press',
        'current_weight': 50.0,
        'suggested_weight': 40.0,
        'target_reps': 31,
        'reason': 'user_reported_fatigue',
        'confidence': 0.92,
      }),
      throwsA(isA<FormatException>()),
    );
  });
  test('rejects empty exercise name', () {
    expect(
      () => Recommendation.fromJson({
        'action': 'decrease_weight',
        'exercise': '',
        'current_weight': 50.0,
        'suggested_weight': 40.0,
        'target_reps': 10,
        'reason': 'user_reported_fatigue',
        'confidence': 0.92,
      }),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects blank exercise name', () {
    expect(
      () => Recommendation.fromJson({
        'action': 'decrease_weight',
        'exercise': '   ',
        'current_weight': 50.0,
        'suggested_weight': 40.0,
        'target_reps': 10,
        'reason': 'user_reported_fatigue',
        'confidence': 0.92,
      }),
      throwsA(isA<FormatException>()),
    );
  });
  test('rejects missing confidence', () {
    expect(
      () => Recommendation.fromJson({
        'action': 'decrease_weight',
        'exercise': 'Bench Press',
        'current_weight': 50.0,
        'suggested_weight': 40.0,
        'target_reps': 10,
        'reason': 'user_reported_fatigue',
      }),
      throwsA(isA<FormatException>()),
    );
  });
  test('rejects missing action', () {
    expect(
      () => Recommendation.fromJson({
        'exercise': 'Bench Press',
        'current_weight': 50.0,
        'suggested_weight': 40.0,
        'target_reps': 10,
        'reason': 'user_reported_fatigue',
        'confidence': 0.92,
      }),
      throwsA(isA<FormatException>()),
    );
  });
  test('rejects missing reason', () {
    expect(
      () => Recommendation.fromJson({
        'action': 'decrease_weight',
        'exercise': 'Bench Press',
        'current_weight': 50.0,
        'suggested_weight': 40.0,
        'target_reps': 10,
        'confidence': 0.92,
      }),
      throwsA(isA<FormatException>()),
    );
  });
  test('rejects missing current weight', () {
    expect(
      () => Recommendation.fromJson({
        'action': 'decrease_weight',
        'exercise': 'Bench Press',
        'suggested_weight': 40.0,
        'target_reps': 10,
        'reason': 'user_reported_fatigue',
        'confidence': 0.92,
      }),
      throwsA(isA<FormatException>()),
    );
  });
  test('rejects missing suggested weight', () {
    expect(
      () => Recommendation.fromJson({
        'action': 'decrease_weight',
        'exercise': 'Bench Press',
        'current_weight': 50.0,
        'target_reps': 10,
        'reason': 'user_reported_fatigue',
        'confidence': 0.92,
      }),
      throwsA(isA<FormatException>()),
    );
  });
  test('rejects non numeric suggested weight', () {
    expect(
      () => Recommendation.fromJson({
        'action': 'decrease_weight',
        'exercise': 'Bench Press',
        'current_weight': 50.0,
        'suggested_weight': '40kg',
        'target_reps': 10,
        'reason': 'user_reported_fatigue',
        'confidence': 0.92,
      }),
      throwsA(isA<FormatException>()),
    );
  });
}
