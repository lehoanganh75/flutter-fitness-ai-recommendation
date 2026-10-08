// ignore_for_file: constant_identifier_names

import 'dart:convert';

enum RecommendationAction { DECREASE_WEIGHT, INCREASE_WEIGHT, KEEP_WEIGHT, REST }
enum RecommendationReason { USER_REPORTED_FATIGUE, PROGRESSION, USER_PREFERENCE, NO_DATA }
enum UserResponse { PENDING, ACCEPTED, REJECTED, IGNORED }

class Recommendation {
  const Recommendation({
    required this.action,
    required this.exercise,
    required this.currentWeight,
    required this.suggestedWeight,
    required this.targetReps,
    required this.reason,
  });

  final RecommendationAction action;
  final String exercise;
  final double currentWeight;
  final double suggestedWeight;
  final int targetReps;
  final RecommendationReason reason;

  Map<String, dynamic> toJson() => {
        'action': action.name,
        'exercise': exercise,
        'current_weight': currentWeight,
        'suggested_weight': suggestedWeight,
        'target_reps': targetReps,
        'reason': reason.name,
      };

  factory Recommendation.fromJson(Map<String, dynamic> json) => Recommendation(
        action: RecommendationAction.values.byName(json['action'] as String),
        exercise: json['exercise'] as String,
        currentWeight: (json['current_weight'] as num).toDouble(),
        suggestedWeight: (json['suggested_weight'] as num).toDouble(),
        targetReps: json['target_reps'] as int,
        reason: RecommendationReason.values.byName(json['reason'] as String),
      );

  String encode() => jsonEncode(toJson());
}
