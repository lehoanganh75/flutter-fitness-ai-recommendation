import '../data/drift_workout_repository.dart';
import '../domain/models/daily_suggestion.dart';
import '../domain/models/workout.dart';

class SuggestionDataSource {
  SuggestionDataSource(this._repo, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DriftWorkoutRepository _repo;
  final DateTime Function() _clock;

  /// Mọi bài trong giáo án của user (gộp 7 ngày, bỏ trùng tên).
  Future<List<KnownExercise>> knownExercises(String userId) async {
    final planIds = <String>{};
    final exercises = <PlannedExercise>[];
    for (var day = 1; day <= 7; day++) {
      final plans = await _repo.plansForDay(userId, day);
      for (final plan in plans) {
        if (!planIds.add(plan.id)) continue;
        exercises.addAll(await _repo.exercisesForPlan(plan.id));
      }
    }

    final seen = <String>{};
    final out = <KnownExercise>[];
    for (final e in exercises) {
      if (seen.add(e.exercise.trim().toLowerCase())) {
        out.add(KnownExercise(name: e.exercise, muscleGroup: e.muscleGroup));
      }
    }
    return out;
  }

  /// Các bài đã tập trong [days] ngày gần nhất, ĐỌC TỪ CACHE.
  Future<List<RecentSession>> recentSessions(String userId, int days) async {
    final now = _clock();
    final cutoff = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days));

    // ĐỌC TỪ CACHE THAY VÌ QUERY TOÀN BỘ LỊCH SỬ
    final caches = await _repo.getAllProgressCache(userId);

    // Map muscleGroup từ KnownExercises
    final known = await knownExercises(userId);
    final muscleMap = {
      for (final e in known) e.name.toLowerCase(): e.muscleGroup,
    };

    final out = <RecentSession>[];
    for (final cache in caches) {
      if (cache.lastTrainedDate.isBefore(cutoff)) continue;

      out.add(
        RecentSession(
          date: cache.lastTrainedDate,
          exercise: cache.exerciseName,
          muscleGroup: muscleMap[cache.exerciseName.toLowerCase()] ?? 'Unknown',
          topWeight: cache.topWeight,
          reps: cache.topReps,
        ),
      );
    }

    out.sort((a, b) => b.date.compareTo(a.date));
    return out;
  }
}
