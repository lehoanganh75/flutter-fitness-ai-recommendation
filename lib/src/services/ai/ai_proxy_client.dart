import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class AiProxyException implements Exception {
  const AiProxyException(this.message);

  final String message;

  @override
  String toString() => 'AiProxyException: $message';
}

class AiProxyClient {
  AiProxyClient({
    required this.proxyUrl,
    required this.proxyToken,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String proxyUrl;
  final String proxyToken;
  final http.Client _http;

  static const Duration _proxyTimeout = Duration(seconds: 50);

  Future<Map<String, dynamic>> analyze({
    required String task,
    required Map<String, dynamic> input,
  }) async {
    final uri = Uri.parse('$proxyUrl/v1/ai');

    final http.Response response;

    try {
      response = await _http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'x-proxy-token': proxyToken,
            },
            body: jsonEncode({'task': task, 'input': input}),
          )
          .timeout(_proxyTimeout);
    } on TimeoutException {
      throw const AiProxyException('AI phản hồi quá lâu');
    } catch (e) {
      throw AiProxyException('Không kết nối được AI proxy: $e');
    }

    if (response.statusCode == 401) {
      throw const AiProxyException('Proxy từ chối xác thực');
    }

    if (response.statusCode == 413) {
      throw const AiProxyException('Request quá lớn');
    }

    if (response.statusCode == 429) {
      throw const AiProxyException('AI đang quá tải, thử lại sau');
    }

    if (response.statusCode == 504) {
      throw const AiProxyException('AI phản hồi quá lâu');
    }

    if (response.statusCode != 200) {
      throw AiProxyException(
        'AI proxy HTTP ${response.statusCode}: ${_errorDetail(response)}',
      );
    }

    final Map<String, dynamic> decoded;

    try {
      final raw = jsonDecode(utf8.decode(response.bodyBytes));
      if (raw is! Map<String, dynamic>) {
        throw const AiProxyException('Proxy trả về không phải JSON object');
      }
      decoded = raw;
    } on FormatException {
      throw const AiProxyException('Proxy trả về JSON không hợp lệ');
    }

    final error = decoded['error'];

    if (error is Map) {
      final code = error['code'];
      final message = error['message'];
      final codeText = code is String ? code : 'UNKNOWN';
      final messageText = message is String && message.isNotEmpty
          ? message
          : 'AI request failed';
      throw AiProxyException('$codeText: $messageText');
    }

    final result = decoded['result'];

    if (result is! Map<String, dynamic>) {
      throw const AiProxyException('Proxy không trả về result hợp lệ');
    }

    _validateResult(task, result, input: input);

    return result;
  }

  void _validateResult(
    String task,
    Map<String, dynamic> result, {
    required Map<String, dynamic> input,
  }) {
    switch (task) {
      case 'daily_suggestion':
        final summary = result['summary'];
        final exercises = result['exercises'];

        // 🆕 Chấp nhận 4-6 bài
        if (summary is! String ||
            summary.trim().isEmpty ||
            exercises is! List ||
            exercises.length < 4 ||
            exercises.length > 6) {
          throw const AiProxyException(
            'daily_suggestion phải có summary và 4-6 exercises',
          );
        }

        final names = <String>{};
        final knownSet = _knownExerciseNames(input);

        for (final exercise in exercises) {
          if (exercise is! Map ||
              exercise['name'] is! String ||
              (exercise['name'] as String).trim().isEmpty ||
              exercise['reason'] is! String ||
              (exercise['reason'] as String).trim().isEmpty) {
            throw const AiProxyException(
              'Mỗi exercise phải có name và reason hợp lệ',
            );
          }

          final name = (exercise['name'] as String).trim();
          final lowerName = name.toLowerCase();

          final sets = exercise['sets'];
          final reps = exercise['reps'];
          final weight = exercise['weight'];

          if (sets is! num || sets < 1 || sets > 6) {
            throw AiProxyException('Sets không hợp lệ cho "$name": $sets');
          }
          if (reps is! num || reps < 1 || reps > 30) {
            throw AiProxyException('Reps không hợp lệ cho "$name": $reps');
          }
          if (weight is! num || weight < 0 || weight > 500) {
            throw AiProxyException('Weight không hợp lệ cho "$name": $weight');
          }

          if (knownSet.isNotEmpty && !knownSet.contains(lowerName)) {
            throw AiProxyException(
              'AI bịa bài tập không có trong thư viện: "$name"',
            );
          }

          if (!names.add(lowerName)) {
            throw const AiProxyException(
              'daily_suggestion không được có bài tập trùng tên',
            );
          }
        }
        break;

      case 'recommendation':
        const actions = {
          'decrease_weight',
          'increase_weight',
          'keep_weight',
          'rest',
        };

        const reasons = {
          'user_reported_fatigue',
          'progression',
          'user_preference',
          'no_data',
        };

        final action = result['action'];
        final reason = result['reason'];
        final suggested = result['suggested_weight'];
        final confidence = result['confidence'];

        if (!actions.contains(action) ||
            !reasons.contains(reason) ||
            suggested is! num ||
            !suggested.toDouble().isFinite ||
            suggested < 0 ||
            confidence is! num ||
            !confidence.toDouble().isFinite ||
            confidence < 0 ||
            confidence > 1) {
          throw const AiProxyException(
            'Kết quả recommendation không đúng schema',
          );
        }

        final current = input['current_weight'] ?? input['currentWeight'];

        if (current is! num || !current.toDouble().isFinite || current < 0) {
          throw const AiProxyException(
            'Input recommendation thiếu current_weight hợp lệ',
          );
        }

        final currentWeight = current.toDouble();
        final suggestedWeight = suggested.toDouble();

        if (currentWeight > 0) {
          final changePercent =
              (suggestedWeight - currentWeight).abs() / currentWeight;

          if (changePercent > 0.20) {
            throw const AiProxyException(
              'Suggested weight không được thay đổi quá 20%',
            );
          }
        }

        switch (action) {
          case 'decrease_weight':
            if (suggestedWeight >= currentWeight) {
              throw const AiProxyException(
                'decrease_weight phải thấp hơn current_weight',
              );
            }
            break;

          case 'increase_weight':
            if (suggestedWeight <= currentWeight) {
              throw const AiProxyException(
                'increase_weight phải cao hơn current_weight',
              );
            }
            break;

          case 'keep_weight':
          case 'rest':
            if (suggestedWeight != currentWeight) {
              throw const AiProxyException(
                'keep_weight/rest phải giữ nguyên current_weight',
              );
            }
            break;
        }
        break;

      case 'memory_extraction':
        if (!result.containsKey('memory')) {
          throw const AiProxyException('memory_extraction thiếu field memory');
        }
        break;
    }
  }

  Set<String> _knownExerciseNames(Map<String, dynamic> input) {
    final list = input['known_exercises'];
    if (list is! List) return const {};
    return list
        .whereType<Map>()
        .map((e) => (e['name'] as String?)?.trim().toLowerCase())
        .whereType<String>()
        .toSet();
  }

  String _errorDetail(http.Response response) {
    try {
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      final error = data is Map ? data['error'] : null;

      if (error is Map) {
        final code = error['code'];
        final message = error['message'];

        if (message is String && message.isNotEmpty) {
          final prefix = code is String ? '$code: ' : '';
          final full = '$prefix$message';
          return full.length > 300 ? full.substring(0, 300) : full;
        }
      }
    } catch (_) {}

    return 'Yêu cầu thất bại';
  }

  void close() {
    _http.close();
  }
}
