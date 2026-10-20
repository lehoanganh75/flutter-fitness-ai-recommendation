import 'package:fitness_recommendation/src/domain/models/recommendation.dart';

import 'recommendation_context.dart';

/// Interface cho các provider có thể tạo Recommendation từ ngữ cảnh.
abstract interface class RecommendationProvider {
  Future<Recommendation> recommend({required RecommendationContext context});
}
