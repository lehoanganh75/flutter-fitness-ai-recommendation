import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_recommendation/src/domain/recommendation.dart';
import 'package:fitness_recommendation/src/services/recommendation_service.dart';

class FakeRecommendationProvider implements RecommendationProvider {
  FakeRecommendationProvider(this.recommendation);

  final Recommendation recommendation;

  @override
  Future<Recommendation> recommend({
    required RecommendationContext context,
  }) async {
    return recommendation;
  }
}

class FailingRecommendationProvider implements RecommendationProvider {
  @override
  Future<Recommendation> recommend({
    required RecommendationContext context,
  }) async {
    throw StateError('Provider unavailable');
  }
}

class CountingRecommendationProvider implements RecommendationProvider {
  CountingRecommendationProvider(this.recommendation);

  final Recommendation recommendation;
  int callCount = 0;

  @override
  Future<Recommendation> recommend({
    required RecommendationContext context,
  }) async {
    callCount++;
    return recommendation;
  }
}

void main() {
  test('returns validated recommendation from provider', () async {
    final recommendation = Recommendation(
      action: RecommendationAction.DECREASE_WEIGHT,
      exercise: 'Bench Press',
      currentWeight: 50,
      suggestedWeight: 40,
      targetReps: 10,
      reason: RecommendationReason.USER_REPORTED_FATIGUE,
      confidence: 0.92,
    );

    final service = RecommendationService(
      provider: FakeRecommendationProvider(recommendation),
    );

    final result = await service.recommend(
      context: RecommendationContext(
        exercise: 'Bench Press',
        currentWeight: 50,
        targetReps: 10,
        recentFeedback: ['Mệt, không nổi'],
      ),
    );

    expect(result.suggestedWeight, 40);
    expect(result.action, RecommendationAction.DECREASE_WEIGHT);
  });
  test('rejects invalid recommendation from provider', () async {
    final recommendation = Recommendation(
      action: RecommendationAction.DECREASE_WEIGHT,
      exercise: 'Bench Press',
      currentWeight: 50,
      suggestedWeight: 60,
      targetReps: 10,
      reason: RecommendationReason.USER_REPORTED_FATIGUE,
      confidence: 0.92,
    );

    final service = RecommendationService(
      provider: FakeRecommendationProvider(recommendation),
    );

    expect(
      () => service.recommend(
        context: RecommendationContext(
          exercise: 'Bench Press',
          currentWeight: 50,
          targetReps: 10,
          recentFeedback: ['Mệt, không nổi'],
        ),
      ),
      throwsA(isA<FormatException>()),
    );
  });
  test('rejects recommendation for a different exercise', () async {
    final recommendation = Recommendation(
      action: RecommendationAction.DECREASE_WEIGHT,
      exercise: 'Squat',
      currentWeight: 50,
      suggestedWeight: 40,
      targetReps: 10,
      reason: RecommendationReason.USER_REPORTED_FATIGUE,
      confidence: 0.92,
    );

    final service = RecommendationService(
      provider: FakeRecommendationProvider(recommendation),
    );

    expect(
      () => service.recommend(
        context: RecommendationContext(
          exercise: 'Bench Press',
          currentWeight: 50,
          targetReps: 10,
          recentFeedback: ['Mệt, không nổi'],
        ),
      ),
      throwsA(isA<FormatException>()),
    );
  });
  test('propagates provider errors without creating fallback', () async {
    final service = RecommendationService(
      provider: FailingRecommendationProvider(),
    );

    expect(
      () => service.recommend(
        context: RecommendationContext(
          exercise: 'Bench Press',
          currentWeight: 50,
          targetReps: 10,
          recentFeedback: ['Mệt, không nổi'],
        ),
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('rejects empty exercise context before calling provider', () async {
    final provider = CountingRecommendationProvider(
      Recommendation(
        action: RecommendationAction.KEEP_WEIGHT,
        exercise: 'Bench Press',
        currentWeight: 50,
        suggestedWeight: 50,
        targetReps: 10,
        reason: RecommendationReason.NO_DATA,
        confidence: 0.5,
      ),
    );

    final service = RecommendationService(provider: provider);

    expect(
      () => service.recommend(
        context: RecommendationContext(
          exercise: '   ',
          currentWeight: 50,
          targetReps: 10,
          recentFeedback: const [],
        ),
      ),
      throwsA(isA<FormatException>()),
    );

    expect(provider.callCount, 0);
  });

  test('rejects non-positive context weight before calling provider', () async {
    final provider = CountingRecommendationProvider(
      Recommendation(
        action: RecommendationAction.KEEP_WEIGHT,
        exercise: 'Bench Press',
        currentWeight: 50,
        suggestedWeight: 50,
        targetReps: 10,
        reason: RecommendationReason.NO_DATA,
        confidence: 0.5,
      ),
    );

    final service = RecommendationService(provider: provider);

    expect(
      () => service.recommend(
        context: RecommendationContext(
          exercise: 'Bench Press',
          currentWeight: 0,
          targetReps: 10,
          recentFeedback: const [],
        ),
      ),
      throwsA(isA<FormatException>()),
    );

    expect(provider.callCount, 0);
  });

  test('rejects invalid context target reps before calling provider', () async {
    final provider = CountingRecommendationProvider(
      Recommendation(
        action: RecommendationAction.KEEP_WEIGHT,
        exercise: 'Bench Press',
        currentWeight: 50,
        suggestedWeight: 50,
        targetReps: 10,
        reason: RecommendationReason.NO_DATA,
        confidence: 0.5,
      ),
    );

    final service = RecommendationService(provider: provider);

    expect(
      () => service.recommend(
        context: RecommendationContext(
          exercise: 'Bench Press',
          currentWeight: 50,
          targetReps: 31,
          recentFeedback: const [],
        ),
      ),
      throwsA(isA<FormatException>()),
    );

    expect(provider.callCount, 0);
  });
}
