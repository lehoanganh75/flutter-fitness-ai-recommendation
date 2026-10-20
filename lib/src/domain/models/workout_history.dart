class WorkoutHistory {
  const WorkoutHistory({
    required this.date,
    required this.weight,
    required this.reps,
    this.targetReps,
    this.feedback,
  });

  final DateTime date;
  final double weight;
  final int reps;
  final int? targetReps;
  final String? feedback;
}
