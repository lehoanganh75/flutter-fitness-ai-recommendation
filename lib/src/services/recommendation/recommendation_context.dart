import 'package:fitness_recommendation/src/domain/models/workout_history.dart';

/// Ngữ cảnh truyền cho `RecommendationService` khi tạo yêu cầu gợi ý.
class RecommendationContext {
  const RecommendationContext({
    required this.exercise,
    required this.currentWeight,
    // Phải trùng với kLocalUserId (app_dependencies.dart) để lấy đúng memory.
    this.userId = 'sample-user',
    this.targetReps = 10,
    this.recentWorkouts = const [],
    this.muscleGroupFrequency = const {},
    this.lastWorkoutDate,
    this.notes = const [],
    this.feedback,
    this.recentFeedback = const [],
  });

  final String userId;
  final String exercise;
  final double currentWeight;
  final int targetReps;
  final List<WorkoutHistory> recentWorkouts;
  final Map<String, int> muscleGroupFrequency;
  final DateTime? lastWorkoutDate;
  final List<String> notes;
  final Map<String, String>? feedback;
  final List<String> recentFeedback;
}
