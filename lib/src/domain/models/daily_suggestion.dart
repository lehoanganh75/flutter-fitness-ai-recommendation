enum SuggestionSource { ai, history, warmUp }

class SuggestedExercise {
  const SuggestedExercise({
    required this.name,
    required this.reason,
    this.sets = 3,
    this.reps = 10,
    this.weight = 20.0,
  });

  final String name;
  final String reason;
  final int sets;
  final int reps;
  final double weight;
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

class KnownExercise {
  const KnownExercise({required this.name, required this.muscleGroup});

  final String name;
  final String muscleGroup;
}
