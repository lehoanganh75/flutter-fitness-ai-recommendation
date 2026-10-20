enum SuggestionSource { ai, history, warmUp }

class SuggestedExercise {
  const SuggestedExercise({required this.name, required this.reason});

  final String name;
  final String reason;
}

class DailySuggestion {
  const DailySuggestion({
    required this.source,
    required this.summary,
    required this.exercises,
  });

  final SuggestionSource source;
  final String summary;
  final List<SuggestedExercise> exercises;
}

/// Một bài đã tập trong buổi gần đây (dùng để AI biết nhóm cơ nào vừa tập).
class RecentSession {
  const RecentSession({
    required this.date,
    required this.exercise,
    required this.muscleGroup,
    this.topWeight,
    this.reps,
  });

  final DateTime date;
  final String exercise;
  final String muscleGroup;
  final double? topWeight;
  final int? reps;
}

/// Một bài mà user có trong thư viện/kế hoạch của họ.
class KnownExercise {
  const KnownExercise({required this.name, required this.muscleGroup});

  final String name;
  final String muscleGroup;
}
