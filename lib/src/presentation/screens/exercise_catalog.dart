import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'create_exercise_screen.dart';

/// Nhóm cơ chuẩn. Khóa tiếng Anh dùng để lưu DB và gửi cho AI,
/// nhãn tiếng Việt chỉ dùng để hiển thị.
class MuscleGroups {
  const MuscleGroups._();

  static const keys = ['Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core'];

  static const _labels = {
    'Chest': 'Ngực',
    'Back': 'Lưng',
    'Legs': 'Chân',
    'Shoulders': 'Vai',
    'Arms': 'Tay',
    'Core': 'Bụng',
  };

  static const _aliases = {
    'quads': 'Legs',
    'hamstrings': 'Legs',
    'calves': 'Legs',
    'glutes': 'Legs',
    'triceps': 'Arms',
    'biceps': 'Arms',
    'forearms': 'Arms',
    'rear delts': 'Shoulders',
    'abs': 'Core',
  };

  /// Đưa mọi cách viết (Quads, Triceps, "Ngực"...) về một khóa chuẩn.
  static String normalize(String raw) {
    final value = raw.trim().toLowerCase();
    for (final key in keys) {
      if (key.toLowerCase() == value) return key;
    }
    for (final entry in _labels.entries) {
      if (entry.value.toLowerCase() == value) return entry.key;
    }
    return _aliases[value] ?? raw.trim();
  }

  static String label(String raw) => _labels[normalize(raw)] ?? raw;

  static Color color(String raw) {
    switch (normalize(raw)) {
      case 'Chest':
        return Colors.red;
      case 'Back':
        return Colors.blue;
      case 'Legs':
        return Colors.green;
      case 'Shoulders':
        return Colors.orange;
      case 'Arms':
        return Colors.purple;
      case 'Core':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}

class ExerciseInfo {
  final String name;
  final String muscleGroup; // khóa chuẩn, xem MuscleGroups
  final String equipment;
  final String difficulty;
  final String description;
  final IconData icon;
  final Color color;
  final bool isCustom;

  const ExerciseInfo({
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    required this.difficulty,
    required this.description,
    required this.icon,
    required this.color,
    this.isCustom = false,
  });
}

/// Nguồn duy nhất cho thư viện bài tập (có sẵn + tự tạo).
class ExerciseCatalog {
  const ExerciseCatalog._();

  static const _prefsKey = 'custom_exercises';

  static Future<List<Exercise>> loadCustom() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? const <String>[];
    final result = <Exercise>[];
    for (final item in raw) {
      try {
        result.add(Exercise.fromJson(jsonDecode(item) as Map<String, dynamic>));
      } catch (e) {
        debugPrint('Bỏ qua bài tập tùy chỉnh lỗi: $e');
      }
    }
    return result;
  }

  static Future<void> saveCustom(List<Exercise> exercises) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      exercises.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  /// Bài có sẵn + bài tự tạo.
  static Future<List<ExerciseInfo>> loadAll() async {
    final custom = await loadCustom();
    return [...builtIn, ...custom.map(_fromCustom)];
  }

  static ExerciseInfo _fromCustom(Exercise e) => ExerciseInfo(
    name: e.name,
    muscleGroup: MuscleGroups.normalize(e.muscleGroup),
    equipment: e.equipment,
    difficulty: 'Tùy chỉnh',
    description: e.instructions.isEmpty ? 'Bài tập tùy chỉnh' : e.instructions,
    icon: Icons.edit,
    color: Colors.purple,
    isCustom: true,
  );

  static ExerciseInfo _ex(
    String name,
    String group,
    String equipment,
    String difficulty,
    String description,
  ) {
    return ExerciseInfo(
      name: name,
      muscleGroup: group,
      equipment: equipment,
      difficulty: difficulty,
      description: description,
      icon: equipment == 'Trọng cơ thể'
          ? Icons.accessibility_new
          : Icons.fitness_center,
      color: MuscleGroups.color(group),
    );
  }

  // Tên bài khớp với dữ liệu mẫu để AI nhận ra cùng một bài.
  static final List<ExerciseInfo> builtIn = [
    // Ngực
    _ex(
      'Bench Press',
      'Chest',
      'Đòn tạ',
      'Trung cấp',
      'Bài compound chính cho ngực, vai trước và tay sau.',
    ),
    _ex(
      'Incline Dumbbell Press',
      'Chest',
      'Tạ tay',
      'Trung cấp',
      'Đẩy tạ trên ghế dốc, tập trung phần ngực trên.',
    ),
    _ex(
      'Dumbbell Fly',
      'Chest',
      'Tạ tay',
      'Người mới bắt đầu',
      'Bài cô lập giúp kéo giãn và siết cơ ngực.',
    ),
    _ex(
      'Push-ups',
      'Chest',
      'Trọng cơ thể',
      'Người mới bắt đầu',
      'Hít đất cổ điển cho ngực, vai và tay sau.',
    ),

    // Lưng
    _ex(
      'Deadlift',
      'Back',
      'Đòn tạ',
      'Nâng cao',
      'Bài toàn thân, tác động mạnh vào lưng và chân.',
    ),
    _ex(
      'Pull-ups',
      'Back',
      'Trọng cơ thể',
      'Trung cấp',
      'Kéo xà, phát triển lưng xô và tay trước.',
    ),
    _ex(
      'Barbell Row',
      'Back',
      'Đòn tạ',
      'Trung cấp',
      'Kéo tạ đòn cúi người, tập lưng giữa và lưng dưới.',
    ),
    _ex(
      'Lat Pulldown',
      'Back',
      'Máy',
      'Người mới bắt đầu',
      'Kéo cáp xuống trước ngực, thay thế dễ hơn cho kéo xà.',
    ),

    // Chân
    _ex(
      'Squat',
      'Legs',
      'Đòn tạ',
      'Trung cấp',
      'Vua của các bài chân: đùi trước, mông và đùi sau.',
    ),
    _ex(
      'Romanian Deadlift',
      'Legs',
      'Đòn tạ',
      'Trung cấp',
      'Tập đùi sau và mông với biên độ gập hông.',
    ),
    _ex(
      'Leg Press',
      'Legs',
      'Máy',
      'Người mới bắt đầu',
      'Đạp đùi trên máy, tập toàn bộ phần thân dưới.',
    ),
    _ex('Leg Curls', 'Legs', 'Máy', 'Người mới bắt đầu', 'Cô lập cơ đùi sau.'),
    _ex(
      'Lunges',
      'Legs',
      'Trọng cơ thể',
      'Người mới bắt đầu',
      'Bước chân một bên, cải thiện thăng bằng và sức mạnh chân.',
    ),
    _ex(
      'Calf Raises',
      'Legs',
      'Máy',
      'Người mới bắt đầu',
      'Nhón gót để tập bắp chân.',
    ),

    // Vai
    _ex(
      'Overhead Press',
      'Shoulders',
      'Đòn tạ',
      'Trung cấp',
      'Đẩy tạ qua đầu, tập cả ba phần của vai.',
    ),
    _ex(
      'Lateral Raises',
      'Shoulders',
      'Tạ tay',
      'Người mới bắt đầu',
      'Bài cô lập cho vai giữa.',
    ),
    _ex(
      'Face Pulls',
      'Shoulders',
      'Cáp',
      'Người mới bắt đầu',
      'Kéo cáp về phía mặt, tập vai sau và cơ xoay vai.',
    ),

    // Tay
    _ex(
      'Bicep Curls',
      'Arms',
      'Tạ tay',
      'Người mới bắt đầu',
      'Bài cô lập kinh điển cho tay trước.',
    ),
    _ex(
      'Hammer Curls',
      'Arms',
      'Tạ tay',
      'Người mới bắt đầu',
      'Cuốn tạ cầm kiểu búa, tập tay trước và cẳng tay.',
    ),
    _ex(
      'Tricep Dips',
      'Arms',
      'Trọng cơ thể',
      'Trung cấp',
      'Nhún xà kép, tập trung vào tay sau.',
    ),

    // Bụng
    _ex(
      'Plank',
      'Core',
      'Trọng cơ thể',
      'Người mới bắt đầu',
      'Bài giữ tĩnh để tăng sức mạnh vùng core.',
    ),
    _ex(
      'Russian Twists',
      'Core',
      'Trọng cơ thể',
      'Trung cấp',
      'Xoay thân tập cơ liên sườn.',
    ),
    _ex(
      'Ab Wheel',
      'Core',
      'Khác',
      'Nâng cao',
      'Lăn bánh xe tập bụng, tải nặng cho toàn bộ core.',
    ),
  ];
}
