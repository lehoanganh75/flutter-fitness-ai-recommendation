import '../domain/models/daily_suggestion.dart';
import '../domain/models/workout.dart';
import '../domain/repositories/workout_repository.dart';

class SuggestionDataSource {
  SuggestionDataSource(this._repo, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final WorkoutRepository _repo;
  final DateTime Function() _clock;

  /// Mọi bài trong giáo án của user (gộp 7 ngày, bỏ trùng tên).
  Future<List<KnownExercise>> knownExercises(String userId) async {
    final exercises = await _allExercises(userId);
    final seen = <String>{};
    final out = <KnownExercise>[];
    for (final e in exercises) {
      if (seen.add(e.exercise.trim().toLowerCase())) {
        out.add(KnownExercise(name: e.exercise, muscleGroup: e.muscleGroup));
      }
    }
    return out;
  }

  /// Các bài đã tập trong [days] ngày gần nhất, mỗi (bài, ngày) một dòng,
  /// mới nhất đứng trước.
  Future<List<RecentSession>> recentSessions(String userId, int days) async {
    final now = _clock();
    final cutoff = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days));

    final exercises = await _allExercises(userId);
    final out = <RecentSession>[];

    for (final ex in exercises) {
      final sets = await _repo.exerciseHistory(ex.id);

      // Gom set theo ngày.
      final byDay = <DateTime, List<LoggedSet>>{};
      for (final s in sets) {
        if (s.loggedAt.isBefore(cutoff)) continue;
        final day = DateTime(s.loggedAt.year, s.loggedAt.month, s.loggedAt.day);
        byDay.putIfAbsent(day, () => []).add(s);
      }

      for (final entry in byDay.entries) {
        final top = entry.value.reduce((a, b) => b.weight > a.weight ? b : a);
        out.add(
          RecentSession(
            date: entry.key,
            exercise: ex.exercise,
            muscleGroup: ex.muscleGroup,
            topWeight: top.weight,
            reps: top.reps,
          ),
        );
      }
    }

    out.sort((a, b) => b.date.compareTo(a.date));
    return out;
  }

  Future<List<PlannedExercise>> _allExercises(String userId) async {
    final planIds = <String>{};
    final exercises = <PlannedExercise>[];
    for (var day = 1; day <= 7; day++) {
      final plans = await _repo.plansForDay(userId, day);
      for (final plan in plans) {
        if (!planIds.add(plan.id)) continue;
        exercises.addAll(await _repo.exercisesForPlan(plan.id));
      }
    }
    return exercises;
  }
}
