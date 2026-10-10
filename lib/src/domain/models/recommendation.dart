// ignore_for_file: constant_identifier_names

import 'dart:convert';

enum RecommendationAction {
  DECREASE_WEIGHT,
  INCREASE_WEIGHT,
  KEEP_WEIGHT,
  REST,
}

enum RecommendationReason {
  USER_REPORTED_FATIGUE,
  PROGRESSION,
  USER_PREFERENCE,
  NO_DATA,
}

enum UserResponse { PENDING, ACCEPTED, REJECTED, IGNORED }

class Recommendation {
  const Recommendation({
    required this.action,
    required this.exercise,
    required this.currentWeight,
    required this.suggestedWeight,
    required this.targetReps,
    required this.reason,
    required this.confidence,
  });

  final RecommendationAction action;
  final String exercise;
  final double currentWeight;
  final double suggestedWeight;
  final int targetReps;
  final RecommendationReason reason;
  final double confidence;

  String _actionToJson() {
    switch (action) {
      case RecommendationAction.DECREASE_WEIGHT:
        return 'decrease_weight';
      case RecommendationAction.INCREASE_WEIGHT:
        return 'increase_weight';
      case RecommendationAction.KEEP_WEIGHT:
        return 'keep_weight';
      case RecommendationAction.REST:
        return 'rest';
    }
  }

  String _reasonToJson() {
    switch (reason) {
      case RecommendationReason.USER_REPORTED_FATIGUE:
        return 'user_reported_fatigue';
      case RecommendationReason.PROGRESSION:
        return 'progression';
      case RecommendationReason.USER_PREFERENCE:
        return 'user_preference';
      case RecommendationReason.NO_DATA:
        return 'no_data';
    }
  }

  Map<String, dynamic> toJson() => {
    'action': _actionToJson(),
    'exercise': exercise,
    'current_weight': currentWeight,
    'suggested_weight': suggestedWeight,
    'target_reps': targetReps,
    'reason': _reasonToJson(),
  };

  factory Recommendation.fromJson(Map<String, dynamic> json) => Recommendation(
    action: _actionFromJson(json['action']),
    exercise: _exerciseFromJson(json['exercise']),
    currentWeight: _currentWeightFromJson(json['current_weight']),
    suggestedWeight: _weightFromJson(
      currentValue: json['current_weight'],
      suggestedValue: json['suggested_weight'],
    ),
    targetReps: _targetRepsFromJson(json['target_reps']),
    reason: _reasonFromJson(json['reason']),
    confidence: _confidenceFromJson(json['confidence']),
  );

  String encode() => jsonEncode(toJson());

  static double _currentWeightFromJson(dynamic value) {
    if (value is! num) {
      throw const FormatException('Current weight must be a number');
    }

    final weight = value.toDouble();

    if (weight <= 0) {
      throw const FormatException('Current weight must be greater than zero');
    }

    return weight;
  }

  static RecommendationReason _reasonFromJson(dynamic value) {
    if (value is! String || value.trim().isEmpty) {
      throw const FormatException('Reason is required');
    }

    switch (value) {
      case 'user_reported_fatigue':
        return RecommendationReason.USER_REPORTED_FATIGUE;
      case 'progression':
        return RecommendationReason.PROGRESSION;
      case 'user_preference':
        return RecommendationReason.USER_PREFERENCE;
      case 'no_data':
        return RecommendationReason.NO_DATA;
      default:
        throw FormatException('Invalid recommendation reason: $value');
    }
  }

  static RecommendationAction _actionFromJson(dynamic value) {
    if (value is! String || value.trim().isEmpty) {
      throw const FormatException('Action is required');
    }

    switch (value) {
      case 'decrease_weight':
        return RecommendationAction.DECREASE_WEIGHT;
      case 'increase_weight':
        return RecommendationAction.INCREASE_WEIGHT;
      case 'keep_weight':
        return RecommendationAction.KEEP_WEIGHT;
      case 'rest':
        return RecommendationAction.REST;
      default:
        throw FormatException('Invalid recommendation action: $value');
    }
  }

  static double _confidenceFromJson(dynamic value) {
    if (value is! num) {
      throw const FormatException('Confidence must be a number');
    }

    final confidence = value.toDouble();

    if (confidence < 0 || confidence > 1) {
      throw const FormatException('Confidence must be between 0 and 1');
    }

    return confidence;
  }

  static double _weightFromJson({
    required dynamic currentValue,
    required dynamic suggestedValue,
  }) {
    if (currentValue is! num || suggestedValue is! num) {
      throw const FormatException('Weight must be a number');
    }

    final currentWeight = currentValue.toDouble();
    final suggestedWeight = suggestedValue.toDouble();

    if (currentWeight <= 0 || suggestedWeight < 0) {
      throw const FormatException('Weight must be valid');
    }

    final changePercent =
        (suggestedWeight - currentWeight).abs() / currentWeight;

    if (changePercent > 0.20) {
      throw const FormatException(
        'Suggested weight cannot change by more than 20 percent',
      );
    }

    return suggestedWeight;
  }

  static int _targetRepsFromJson(dynamic value) {
    if (value is! num || value % 1 != 0) {
      throw const FormatException('Target reps must be an integer');
    }

    final targetReps = value.toInt();

    if (targetReps < 1 || targetReps > 30) {
      throw const FormatException('Target reps must be between 1 and 30');
    }

    return targetReps;
  }

  static String _exerciseFromJson(dynamic value) {
    if (value is! String || value.trim().isEmpty) {
      throw const FormatException('Exercise name must not be empty');
    }

    return value.trim();
  }
}
