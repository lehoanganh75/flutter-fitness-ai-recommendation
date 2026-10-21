import 'package:fitness_recommendation/src/domain/models/recommendation.dart';
import 'package:fitness_recommendation/src/domain/models/workout_history.dart';
import 'package:fitness_recommendation/src/domain/repositories/workout_repository.dart';
import 'package:fitness_recommendation/src/services/recommendation/recommendation_service.dart';

/// Service điều phối: hỗ trợ màn hình ghi set lấy gợi ý cân nặng từ AI.
///
/// Trách nhiệm:
/// - Tập hợp dữ liệu nguồn (lịch sử, tần suất cơ...) từ repository
/// - Dựng RecommendationContext đầy đủ
/// - Gọi RecommendationService.recommend()
/// - Xử lý lỗi gracefully (trả null nếu không có service)
class WeightAdviceService {
  WeightAdviceService(this._repo, this._service);

  final WorkoutRepository _repo;
  final RecommendationService? _service;

  /// Lấy gợi ý cân nặng cho bài tập hiện tại.
  ///
  /// Tham số:
  /// - userId: ID user (để lấy lịch sử)
  /// - exerciseId: ID bài tập (để lấy lịch sử chi tiết)
  /// - exercise: tên bài tập (để gửi đến AI)
  /// - muscleGroup: nhóm cơ bị tác động
  /// - currentWeight: cân nặng hiện tại (user vừa nhập)
  /// - targetReps: target reps cho bài tập này
  /// - feedback: phản hồi (easy/good/hard/failed)
  ///
  /// Trả về:
  /// - Recommendation từ AI nếu có service và thành công
  /// - null nếu không có service hoặc có lỗi
  Future<Recommendation?> recommendFor({
    required String userId,
    required String exerciseId,
    required String exercise,
    required String muscleGroup,
    required double currentWeight,
    required int targetReps,
    required String feedback,
  }) async {
    // Nếu không có service, thoát ngay (feature tắt).
    final service = _service;
    if (service == null) {
      return null;
    }

    try {
      // Bước 1: Lấy lịch sử 10 set gần nhất cho bài tập này.
      final loggedSets = await _repo.exerciseHistory(exerciseId, limit: 10);

      // Bước 2: Map LoggedSet sang WorkoutHistory.
      final recentWorkouts = [
        for (final set in loggedSets)
          WorkoutHistory(
            date: set.loggedAt,
            weight: set.weight,
            reps: set.reps,
            targetReps: targetReps,
            feedback: set.feedbackText,
          ),
      ];

      // Bước 3: Tính tần suất nhóm cơ trong 7 ngày gần nhất.
      final muscleGroupFrequency = await _calculateMuscleGroupFrequency(
        userId: userId,
        daysBack: 7,
      );

      // Bước 4: Lấy ngày tập cuối cùng nếu có lịch sử.
      final lastWorkoutDate = recentWorkouts.isNotEmpty
          ? recentWorkouts.first.date
          : null;

      // Bước 5: Dựng RecommendationContext.
      final context = RecommendationContext(
        userId: userId,
        exercise: exercise,
        currentWeight: currentWeight,
        targetReps: targetReps,
        recentWorkouts: recentWorkouts,
        muscleGroupFrequency: muscleGroupFrequency,
        lastWorkoutDate: lastWorkoutDate,
        notes: [],
        feedback: {'userFeedback': feedback},
        recentFeedback: _extractRecentFeedback(recentWorkouts),
      );

      // Bước 6: Gọi dịch vụ gợi ý.
      return await service.recommend(context: context);
    } catch (e) {
      // Lỗi không được làm gián đoạn việc ghi set.
      print('WeightAdviceService.recommendFor error: $e');
      return null;
    }
  }

  /// Tính tần suất nhóm cơ trong N ngày gần nhất.
  ///
  /// Flow:
  /// 1. Lấy plans của user trong daysBack ngày.
  /// 2. Lấy exercises của từng plan.
  /// 3. Đếm theo muscleGroup.
  /// 4. Trả về map nhóm cơ và số lần xuất hiện.
  Future<Map<String, int>> _calculateMuscleGroupFrequency({
    required String userId,
    required int daysBack,
  }) async {
    final frequency = <String, int>{};

    // Quét N ngày gần nhất.
    for (var i = 0; i < daysBack; i++) {
      final dayOfWeek = (DateTime.now().weekday - i) % 7;

      final plans = await _repo.plansForDay(userId, dayOfWeek);

      for (final plan in plans) {
        final exercises = await _repo.exercisesForPlan(plan.id);

        for (final exercise in exercises) {
          final group = exercise.muscleGroup;
          frequency[group] = (frequency[group] ?? 0) + 1;
        }
      }
    }

    return frequency;
  }

  /// Trích xuất tối đa 3 feedback gần nhất từ lịch sử.
  ///
  /// Dùng để cung cấp xu hướng phản hồi cho AI.
  List<String> _extractRecentFeedback(List<WorkoutHistory> workouts) {
    return workouts
        .take(3)
        .map((workout) => workout.feedback ?? '')
        .where((feedback) => feedback.isNotEmpty)
        .toList();
  }
}
