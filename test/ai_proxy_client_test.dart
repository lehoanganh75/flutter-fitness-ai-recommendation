import 'dart:convert';

import 'package:fitness_recommendation/src/services/ai/ai_proxy_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('Gemini lỗi thì chuyển sang OpenRouter', () async {
    var geminiCalls = 0;
    var openRouterCalls = 0;

    final mockClient = MockClient((request) async {
      if (request.url.host == 'generativelanguage.googleapis.com') {
        geminiCalls++;

        return http.Response(
          jsonEncode({
            'error': {'message': 'Simulated Gemini failure'},
          }),
          400,
          headers: {'content-type': 'application/json'},
        );
      }

      if (request.url.host == 'openrouter.ai') {
        openRouterCalls++;

        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {
                  'content': jsonEncode({
                    'action': 'keep_weight',
                    'suggested_weight': 40,
                    'reason': 'no_data',
                    'confidence': 0.5,
                  }),
                },
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      return http.Response('Unexpected URL', 500);
    });

    final client = AiProxyClient(
      apiKey: 'test-gemini-key',
      openRouterApiKey: 'test-openrouter-key',
      httpClient: mockClient,
    );

    try {
      final result = await client.analyze(
        task: 'recommendation',
        input: {'current_weight': 40},
      );

      expect(geminiCalls, 1);
      expect(openRouterCalls, 1);
      expect(result['action'], 'keep_weight');
      expect(result['suggested_weight'], 40);

      print('PASS: Gemini lỗi, OpenRouter fallback thành công.');
    } finally {
      client.close();
    }
  });
}
