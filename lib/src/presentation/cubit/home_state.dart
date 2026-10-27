import 'package:equatable/equatable.dart';

import '../../domain/models/daily_suggestion.dart';
import '../../domain/models/today_workout.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final TodayWorkout? workout;
  final DailySuggestion? suggestion;
  final bool isApplying;
  final bool isSuggestionLoading;

  const HomeLoaded({
    this.workout,
    this.suggestion,
    this.isApplying = false,
    this.isSuggestionLoading = false,
  });

  HomeLoaded copyWith({
    TodayWorkout? workout,
    DailySuggestion? suggestion,
    bool? isApplying,
    bool? isSuggestionLoading,
  }) {
    return HomeLoaded(
      workout: workout ?? this.workout,
      suggestion: suggestion ?? this.suggestion,
      isApplying: isApplying ?? this.isApplying,
      isSuggestionLoading: isSuggestionLoading ?? this.isSuggestionLoading,
    );
  }

  @override
  List<Object?> get props => [
    workout,
    suggestion,
    isApplying,
    isSuggestionLoading,
  ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
