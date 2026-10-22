import 'dart:convert';

import 'package:fitness_recommendation/src/services/ai/ai_proxy_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('trả về result khi Worker trả Gemini thành công', () async {
    var calls = 0;

    final mockClient = MockClient((request) async {
      calls++;

      if (request.url.path != '/v1/ai') {
        return http.Response('Unexpected path', 500);
      }

      return http.Response(
        jsonEncode({
          'provider': 'gemini',
          'result': {
            'action': 'keep_weight',
            'suggested_weight': 40,
            'reason': 'no_data',
            'confidence': 0.5,
          },
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final client = AiProxyClient(
      proxyUrl: 'http://test.local',
      proxyToken: 'test-token',
      httpClient: mockClient,
    );

    try {
      final result = await client.analyze(
        task: 'recommendation',
        input: {'current_weight': 40},
      );

      expect(calls, 1);
      expect(result['action'], 'keep_weight');
      expect(result['suggested_weight'], 40);
    } finally {
      client.close();
    }
  });

  test('trả về result khi Worker fallback OpenRouter thành công', () async {
    final mockClient = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'provider': 'openrouter',
          'result': {
            'action': 'decrease_weight',
            'suggested_weight': 45,
            'reason': 'user_reported_fatigue',
            'confidence': 0.9,
          },
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final client = AiProxyClient(
      proxyUrl: 'http://test.local',
      proxyToken: 'test-token',
      httpClient: mockClient,
    );

    try {
      final result = await client.analyze(
        task: 'recommendation',
        input: {'current_weight': 50},
      );

      expect(result['action'], 'decrease_weight');
      expect(result['suggested_weight'], 45);
    } finally {
      client.close();
    }
  });

  test('ném AiProxyException khi Worker trả 429', () async {
    final mockClient = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'error': {'code': 'RATE_LIMITED', 'message': 'quota exceeded'},
        }),
        429,
        headers: {'content-type': 'application/json'},
      );
    });

    final client = AiProxyClient(
      proxyUrl: 'http://test.local',
      proxyToken: 'test-token',
      httpClient: mockClient,
    );

    try {
      expect(
        () => client.analyze(
          task: 'recommendation',
          input: {'current_weight': 50},
        ),
        throwsA(isA<AiProxyException>()),
      );
    } finally {
      client.close();
    }
  });

  test('ném AiProxyException khi Worker trả 502', () async {
    final mockClient = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'error': {'code': 'UPSTREAM_FAILED', 'message': 'provider down'},
        }),
        502,
        headers: {'content-type': 'application/json'},
      );
    });

    final client = AiProxyClient(
      proxyUrl: 'http://test.local',
      proxyToken: 'test-token',
      httpClient: mockClient,
    );

    try {
      expect(
        () => client.analyze(
          task: 'recommendation',
          input: {'current_weight': 50},
        ),
        throwsA(isA<AiProxyException>()),
      );
    } finally {
      client.close();
    }
  });

  test('ném AiProxyException khi result vi phạm schema', () async {
    final mockClient = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'provider': 'gemini',
          'result': {
            'action': 'unknown_action',
            'suggested_weight': 40,
            'reason': 'no_data',
            'confidence': 0.5,
          },
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final client = AiProxyClient(
      proxyUrl: 'http://test.local',
      proxyToken: 'test-token',
      httpClient: mockClient,
    );

    try {
      expect(
        () => client.analyze(
          task: 'recommendation',
          input: {'current_weight': 50},
        ),
        throwsA(isA<AiProxyException>()),
      );
    } finally {
      client.close();
    }
  });

  test('ném AiProxyException khi Worker trả 401', () async {
    final mockClient = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'error': {'code': 'UNAUTHORIZED', 'message': 'bad token'},
        }),
        401,
        headers: {'content-type': 'application/json'},
      );
    });

    final client = AiProxyClient(
      proxyUrl: 'http://test.local',
      proxyToken: 'wrong-token',
      httpClient: mockClient,
    );

    try {
      expect(
        () => client.analyze(
          task: 'recommendation',
          input: {'current_weight': 50},
        ),
        throwsA(isA<AiProxyException>()),
      );
    } finally {
      client.close();
    }
  });
}
