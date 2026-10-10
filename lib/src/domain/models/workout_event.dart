class SetFeedbackEvent {
  const SetFeedbackEvent({
    required this.userId,
    required this.exercise,
    this.muscleGroup,
    required this.setIndex,
    required this.weight,
    required this.reps,
    required this.targetReps,
    required this.feedbackText,
    required this.timestamp,
  });

  final String userId;
  final String exercise;
  final String? muscleGroup;
  final int setIndex;
  final double weight;
  final int reps;
  final int targetReps;
  final String feedbackText;
  final DateTime timestamp;
}
