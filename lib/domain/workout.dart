enum SyncStatus { pending, synced }

class WorkoutPlan {
  const WorkoutPlan({
    required this.id,
    required this.userId,
    required this.title,
    required this.dayOfWeek,
    required this.createdAt,
    this.syncStatus = SyncStatus.pending,
  });

  final String id;
  final String userId;
  final String title;
  final int dayOfWeek;
  final DateTime createdAt;
  final SyncStatus syncStatus;

  WorkoutPlan copyWith({
    String? id,
    String? userId,
    String? title,
    int? dayOfWeek,
    DateTime? createdAt,
    SyncStatus? syncStatus,
  }) => WorkoutPlan(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    dayOfWeek: dayOfWeek ?? this.dayOfWeek,
    createdAt: createdAt ?? this.createdAt,
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
  final String exercise; // VD: "Bench Press"
  final String muscleGroup; // VD: "Chest", "Back"
  final int sortOrder; // Thứ tự: 1, 2, 3...
  final int targetSets; // VD: 3 sets
  final int targetReps; // VD: 10 reps
  final double initialWeight; // VD: 40.0 kg
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

/// Set đã tập xong với feedback
/// VD: Set 1 - 40kg x 8 reps - "Cảm thấy hơi nặng"
class LoggedSet {
  const LoggedSet({
    required this.id,
    required this.exerciseId, // Foreign key đến PlannedExercise
    required this.setIndex, // Set thứ mấy (1, 2, 3...)
    required this.weight, // Trọng lượng thực tế
    required this.reps, // Số reps thực tế
    this.feedbackText, // Feedback từ user (optional)
    required this.loggedAt, // Thời gian log
    this.syncStatus = SyncStatus.pending,
  });

  final String id;
  final String exerciseId;
  final int setIndex;
  final double weight;
  final int reps;
  final String? feedbackText; // VD: "Mệt", "Dễ", "Quá nặng"
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
