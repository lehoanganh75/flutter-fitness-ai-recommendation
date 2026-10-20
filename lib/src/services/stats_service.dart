import '../domain/repositories/workout_repository.dart';
import '../domain/models/workout.dart';

class StatsService {
  final WorkoutRepository repository;

  StatsService(this.repository);

  /// Get workout statistics for a user
  Future<WorkoutStats> getStats(String userId) async {
    // Get all plans for the user
    final allPlans = <WorkoutPlan>[];
    for (int day = 1; day <= 7; day++) {
      final plansForDay = await repository.plansForDay(userId, day);
      allPlans.addAll(plansForDay);
    }

    if (allPlans.isEmpty) {
      return WorkoutStats.empty();
    }

    // Get all exercises from all plans
    final allExercises = <PlannedExercise>[];
    for (final plan in allPlans) {
      final exercises = await repository.exercisesForPlan(plan.id);
      allExercises.addAll(exercises);
    }

    // Get all logged sets
    final allLoggedSets = <LoggedSet>[];
    for (final exercise in allExercises) {
      final sets = await repository.loggedSetsForExercise(exercise.id);
      allLoggedSets.addAll(sets);
    }

    // Calculate stats
    final totalWorkouts = _calculateTotalWorkouts(allLoggedSets);
    final totalVolume = _calculateTotalVolume(allLoggedSets);
    final streak = _calculateStreak(allLoggedSets);
    final totalTime = _estimateTotalTime(allLoggedSets);
    final weeklyActivity = _calculateWeeklyActivity(allLoggedSets);
    final personalRecords = _calculatePersonalRecords(allLoggedSets, allExercises);
    final muscleGroupDistribution = _calculateMuscleGroupDistribution(
      allLoggedSets,
      allExercises,
    );

    return WorkoutStats(
      totalWorkouts: totalWorkouts,
      totalVolume: totalVolume,
      streak: streak,
      totalTime: totalTime,
      weeklyActivity: weeklyActivity,
      personalRecords: personalRecords,
      muscleGroupDistribution: muscleGroupDistribution,
    );
  }

  int _calculateTotalWorkouts(List<LoggedSet> sets) {
    if (sets.isEmpty) return 0;
    
    // Count unique workout sessions (by date)
    final uniqueDates = sets.map((s) {
      final date = s.loggedAt;
      return DateTime(date.year, date.month, date.day);
    }).toSet();
    
    return uniqueDates.length;
  }

  double _calculateTotalVolume(List<LoggedSet> sets) {
    return sets.fold(0.0, (sum, set) => sum + (set.weight * set.reps));
  }

  int _calculateStreak(List<LoggedSet> sets) {
    if (sets.isEmpty) return 0;

    // Get unique workout dates, sorted
    final dates = sets.map((s) {
      final date = s.loggedAt;
      return DateTime(date.year, date.month, date.day);
    }).toSet().toList()
      ..sort((a, b) => b.compareTo(a)); // Most recent first

    if (dates.isEmpty) return 0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Check if most recent workout was today or yesterday
    final daysSinceLastWorkout = todayDate.difference(dates.first).inDays;
    if (daysSinceLastWorkout > 1) return 0; // Streak broken

    int streak = 1;
    for (int i = 1; i < dates.length; i++) {
      final diff = dates[i - 1].difference(dates[i]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  int _estimateTotalTime(List<LoggedSet> sets) {
    // Estimate: average 2 minutes per set + rest time
    return (sets.length * 2.5).round();
  }

  List<double> _calculateWeeklyActivity(List<LoggedSet> sets) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    final weeklyData = List<double>.filled(7, 0);

    for (final set in sets) {
      final daysSinceWeekStart = set.loggedAt.difference(weekStart).inDays;
      if (daysSinceWeekStart >= 0 && daysSinceWeekStart < 7) {
        weeklyData[daysSinceWeekStart]++;
      }
    }

    // Normalize to 0-1 range
    final max = weeklyData.reduce((a, b) => a > b ? a : b);
    if (max == 0) return weeklyData;
    return weeklyData.map((v) => v / max).toList();
  }

  List<PersonalRecord> _calculatePersonalRecords(
    List<LoggedSet> sets,
    List<PlannedExercise> exercises,
  ) {
    final recordsMap = <String, PersonalRecord>{};

    for (final set in sets) {
      final exercise = exercises.firstWhere(
        (e) => e.id == set.exerciseId,
        orElse: () => PlannedExercise(
          id: set.exerciseId,
          planId: '',
          exercise: 'Unknown',
          muscleGroup: 'Unknown',
          targetSets: 0,
          targetReps: 0,
          initialWeight: 0,
          sortOrder: 0,
        ),
      );

      final key = exercise.exercise;
      final volume = set.weight * set.reps;

      if (!recordsMap.containsKey(key) ||
          volume > (recordsMap[key]!.weight * recordsMap[key]!.reps)) {
        recordsMap[key] = PersonalRecord(
          exercise: exercise.exercise,
          weight: set.weight,
          reps: set.reps,
          date: set.loggedAt,
        );
      }
    }

    // Return top 3
    final records = recordsMap.values.toList()
      ..sort((a, b) => (b.weight * b.reps).compareTo(a.weight * a.reps));
    
    return records.take(3).toList();
  }

  Map<String, double> _calculateMuscleGroupDistribution(
    List<LoggedSet> sets,
    List<PlannedExercise> exercises,
  ) {
    final distribution = <String, int>{};

    for (final set in sets) {
      final exercise = exercises.firstWhere(
        (e) => e.id == set.exerciseId,
        orElse: () => PlannedExercise(
          id: set.exerciseId,
          planId: '',
          exercise: 'Unknown',
          muscleGroup: 'Other',
          targetSets: 0,
          targetReps: 0,
          initialWeight: 0,
          sortOrder: 0,
        ),
      );

      distribution[exercise.muscleGroup] =
          (distribution[exercise.muscleGroup] ?? 0) + 1;
    }

    // Normalize to percentages
    final total = distribution.values.fold(0, (sum, count) => sum + count);
    if (total == 0) return {};

    return distribution.map(
      (key, value) => MapEntry(key, value / total),
    );
  }
}

class WorkoutStats {
  final int totalWorkouts;
  final double totalVolume;
  final int streak;
  final int totalTime; // in minutes
  final List<double> weeklyActivity;
  final List<PersonalRecord> personalRecords;
  final Map<String, double> muscleGroupDistribution;

  WorkoutStats({
    required this.totalWorkouts,
    required this.totalVolume,
    required this.streak,
    required this.totalTime,
    required this.weeklyActivity,
    required this.personalRecords,
    required this.muscleGroupDistribution,
  });

  factory WorkoutStats.empty() {
    return WorkoutStats(
      totalWorkouts: 0,
      totalVolume: 0,
      streak: 0,
      totalTime: 0,
      weeklyActivity: List.filled(7, 0),
      personalRecords: [],
      muscleGroupDistribution: {},
    );
  }
}

class PersonalRecord {
  final String exercise;
  final double weight;
  final int reps;
  final DateTime date;

  PersonalRecord({
    required this.exercise,
    required this.weight,
    required this.reps,
    required this.date,
  });
}
