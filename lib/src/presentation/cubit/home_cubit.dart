import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/daily_suggestion_service.dart';
import '../../services/workout_service.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final WorkoutService workoutService;
  final DailySuggestionService suggestionService;
  final String userId;

  HomeCubit({
    required this.workoutService,
    required this.suggestionService,
    required this.userId,
  }) : super(HomeInitial());

  Future<void> loadHomeData(DateTime today) async {
    emit(HomeLoading());
    try {
      final workout = await workoutService.loadTodayWorkout(
        userId: userId,
        dayOfWeek: today.weekday,
        today: today,
      );

      final suggestion = await suggestionService.suggest(
        userId: userId,
        now: today,
      );

      emit(HomeLoaded(workout: workout, suggestion: suggestion));
    } catch (e) {
      emit(HomeError('Không tải được dữ liệu: $e'));
    }
  }

  Future<void> refreshSuggestion(DateTime today) async {
    final currentState = state;
    if (currentState is HomeLoaded) {
      emit(currentState.copyWith(isSuggestionLoading: true));
      try {
        final suggestion = await suggestionService.suggest(
          userId: userId,
          now: today,
          forceRefresh: true,
        );
        emit(
          currentState.copyWith(
            suggestion: suggestion,
            isSuggestionLoading: false,
          ),
        );
      } catch (e) {
        emit(HomeError('Lỗi làm mới gợi ý: $e'));
      }
    }
  }

  Future<void> applySuggestionToToday(DateTime today) async {
    final currentState = state;
    if (currentState is HomeLoaded && currentState.suggestion != null) {
      emit(currentState.copyWith(isApplying: true));
      try {
        await workoutService.applySuggestionToToday(
          userId: userId,
          exercises: currentState.suggestion!.exercises,
          today: today,
        );

        final workout = await workoutService.loadTodayWorkout(
          userId: userId,
          dayOfWeek: today.weekday,
          today: today,
        );

        emit(currentState.copyWith(workout: workout, isApplying: false));
      } catch (e) {
        emit(HomeError('Không áp dụng được: $e'));
      }
    }
  }
}
