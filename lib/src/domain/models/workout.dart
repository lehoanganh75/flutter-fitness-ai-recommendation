enum SyncStatus { pending, synced }

class WorkoutPlan {
  const WorkoutPlan({
    required this.id,
    required this.userId,
    required this.title,
    required this.dayOfWeek,
    required this.createdAt,
    this.scheduledDate,
    this.syncStatus = SyncStatus.pending,
  });

  final String id;
  final String userId;
  final String title;
  final int dayOfWeek;
  final DateTime createdAt;
  final DateTime? scheduledDate;
  final SyncStatus syncStatus;

  WorkoutPlan copyWith({
    String? id,
    String? userId,
    String? title,
    int? dayOfWeek,
    DateTime? createdAt,
    DateTime? scheduledDate,
    SyncStatus? syncStatus,
  }) => WorkoutPlan(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    dayOfWeek: dayOfWeek ?? this.dayOfWeek,
    createdAt: createdAt ?? this.createdAt,
    scheduledDate: scheduledDate ?? this.scheduledDate,
    syncStatus: syncStatus ?? this.syncStatus,
  );
}

class PlannedExercise {
  const PlannedExercise({
    required this.id,
    required this.planId,
    required this.exercise,
    required this.muscleGroup,
    required this.sortOrder,
    required this.targetSets,
    required this.targetReps,
    required this.initialWeight,
    this.syncStatus = SyncStatus.pending,
  });

  final String id;
  final String planId;
  final String exercise;
  final String muscleGroup;
  final int sortOrder;
  final int targetSets;
  final int targetReps;
  final double initialWeight;
  final SyncStatus syncStatus;

  PlannedExercise copyWith({
    String? id,
    String? planId,
    String? exercise,
    String? muscleGroup,
    int? sortOrder,
    int? targetSets,
    int? targetReps,
    double? initialWeight,
    SyncStatus? syncStatus,
  }) => PlannedExercise(
    id: id ?? this.id,
    planId: planId ?? this.planId,
    exercise: exercise ?? this.exercise,
    muscleGroup: muscleGroup ?? this.muscleGroup,
    sortOrder: sortOrder ?? this.sortOrder,
    targetSets: targetSets ?? this.targetSets,
    targetReps: targetReps ?? this.targetReps,
    initialWeight: initialWeight ?? this.initialWeight,
    syncStatus: syncStatus ?? this.syncStatus,
  );
}

class LoggedSet {
  const LoggedSet({
    required this.id,
    required this.exerciseId,
    required this.setIndex,
    required this.weight,
    required this.reps,
    this.feedbackText,
    required this.loggedAt,
    this.syncStatus = SyncStatus.pending,
  });

  final String id;
  final String exerciseId;
  final int setIndex;
  final double weight;
  final int reps;
  final String? feedbackText;
  final DateTime loggedAt;
  final SyncStatus syncStatus;

  LoggedSet copyWith({
    String? id,
    String? exerciseId,
    int? setIndex,
    double? weight,
    int? reps,
    String? feedbackText,
    DateTime? loggedAt,
    SyncStatus? syncStatus,
  }) => LoggedSet(
    id: id ?? this.id,
    exerciseId: exerciseId ?? this.exerciseId,
    setIndex: setIndex ?? this.setIndex,
    weight: weight ?? this.weight,
    reps: reps ?? this.reps,
    feedbackText: feedbackText ?? this.feedbackText,
    loggedAt: loggedAt ?? this.loggedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
}
