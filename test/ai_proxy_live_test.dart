import 'package:fitness_recommendation/src/services/ai/ai_proxy_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const geminiKey = String.fromEnvironment('GEMINI_API_KEY');
  const openRouterKey = String.fromEnvironment('OPENROUTER_API_KEY');

  test('AI thật trả về recommendation hợp lệ', () async {
    final client = AiProxyClient(
      apiKey: geminiKey,
      openRouterApiKey: openRouterKey,
    );

    try {
      final result = await client.analyze(
        task: 'recommendation',
        input: {
          'exercise': 'Bench Press',
          'current_weight': 40,
          'target_reps': 10,
          'completed_sets': 3,
          'feedback': 'Tập ổn, hoàn thành đủ số reps',
          'memory_context': '',
          'recent_workouts': [],
        },
      );

      expect([
        'decrease_weight',
        'increase_weight',
        'keep_weight',
        'rest',
      ], contains(result['action']));

      expect(result['suggested_weight'], isA<num>());
      expect([
        'user_reported_fatigue',
        'progression',
        'user_preference',
        'no_data',
      ], contains(result['reason']));

      expect(result['confidence'], isA<num>());

      expect(
        (result['confidence'] as num) >= 0 &&
            (result['confidence'] as num) <= 1,
        isTrue,
      );

      print('AI REAL RESPONSE: $result');
      print('PASS: AI trả về recommendation hợp lệ.');
    } finally {
      client.close();
    }
  }, timeout: const Timeout(Duration(minutes: 2)));
}
