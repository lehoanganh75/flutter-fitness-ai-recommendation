import 'package:fitness_recommendation/src/services/recommendation/recommendation_context.dart';

import '../../domain/models/recommendation.dart';
import '../ai/ai_proxy_client.dart';

/// Component: AI / Recommendation.
class AiRecommendation {
  const AiRecommendation(this._proxy);

  final AiProxyClient _proxy;

  Future<Recommendation> generate({
    required RecommendationContext context,
    required String memoryContext,
  }) async {
    final json = await _proxy.analyze(
      task: 'recommendation',
      input: {
        'exercise': context.exercise,
        'current_weight': context.currentWeight,
        'target_reps': context.targetReps,
        'last_workout_date': context.lastWorkoutDate?.toIso8601String(),
        'recent_workouts': [
          for (final w in context.recentWorkouts)
            {
              'date': w.date.toIso8601String().split('T').first,
              'weight': w.weight,
              'reps': w.reps,
              'target_reps': w.targetReps,
              'feedback': w.feedback,
            },
        ],
        'muscle_group_frequency': context.muscleGroupFrequency,
        'notes': context.notes,
        'feedback': context.feedback,
        'recent_feedback': context.recentFeedback,
        'memory_context': memoryContext,
      },
    );

    // RecommendationService bắt buộc các field này khớp context: lấy từ context, không tin AI.
    json['exercise'] = context.exercise;
    json['current_weight'] = context.currentWeight;
    json['target_reps'] = context.targetReps;
    json['confidence'] ??= 0.5;

    return Recommendation.fromJson(json);
  }
}
