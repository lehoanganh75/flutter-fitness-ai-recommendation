import 'package:fitness_recommendation/src/services/ai/ai_proxy_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const proxyUrl = String.fromEnvironment('PROXY_URL');
  const proxyToken = String.fromEnvironment('PROXY_TOKEN');

  final hasConfig = proxyUrl.isNotEmpty && proxyToken.isNotEmpty;

  test(
    'AI thật trả về recommendation hợp lệ',
    () async {
      final client = AiProxyClient(proxyUrl: proxyUrl, proxyToken: proxyToken);

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
        expect((result['confidence'] as num) >= 0, isTrue);
        expect((result['confidence'] as num) <= 1, isTrue);
      } finally {
        client.close();
      }
    },
    skip: hasConfig ? false : 'Thiếu PROXY_URL hoặc PROXY_TOKEN khi build test',
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
