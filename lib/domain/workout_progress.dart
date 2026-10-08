import 'workout.dart';

class WorkoutProgress {
  const WorkoutProgress({
    required this.completedSets,
    required this.totalSets,
    required this.currentSet,
    required this.isCompleted,
  });

  final int completedSets;
  final int totalSets;
  final int? currentSet;
  final bool isCompleted;

  factory WorkoutProgress.fromExercise({
    required int targetSets,
    required List<LoggedSet> loggedSets,
  }) {
    final completedSets = loggedSets.length;
    final isCompleted = completedSets >= targetSets;

    return WorkoutProgress(
      completedSets: completedSets,
      totalSets: targetSets,
      currentSet: isCompleted ? null : completedSets + 1,
      isCompleted: isCompleted,
    );
  }
}
