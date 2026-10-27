import 'package:flutter/material.dart';

import 'exercise_catalog.dart';

// ─────────────────────────────────────────────────────────────
// COLORS (Đồng bộ toàn app)
// ─────────────────────────────────────────────────────────────
class _AppColors {
  static const bg = Color(0xFFF8F9FA);
  static const surface = Colors.white;
  static const surfaceHigh = Color(0xFFF1F3F5);
  static const textPrimary = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const accent = Color(0xFF16A34A);
  static const danger = Color(0xFFDC2626);
}

class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  final String equipment;
  final String category;
  final String instructions;
  final bool isCustom;

  Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    required this.category,
    required this.instructions,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'muscleGroup': muscleGroup,
    'equipment': equipment,
    'category': category,
    'instructions': instructions,
    'isCustom': isCustom,
  };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    id: json['id'] as String,
    name: json['name'] as String,
    muscleGroup: json['muscleGroup'] as String,
    equipment: json['equipment'] as String,
    category: json['category'] as String,
    instructions: json['instructions'] as String,
    isCustom: json['isCustom'] as bool? ?? false,
  );
}

class CreateExerciseScreen extends StatefulWidget {
  const CreateExerciseScreen({super.key});

  @override
  State<CreateExerciseScreen> createState() => _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends State<CreateExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'Sức mạnh';
  String _selectedMuscleGroup = MuscleGroups.keys.first;
  String _selectedEquipment = 'Đòn tạ';

  final List<String> _categories = const [
    'Sức mạnh',
    'Cardio',
    'Linh hoạt',
    'Thăng bằng',
  ];

  final List<String> _equipment = const [
    'Đòn tạ',
    'Tạ tay',
    'Máy',
    'Cáp',
    'Trọng cơ thể',
    'Tạ ấm',
    'Dây kháng lực',
    'Khác',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveExercise() {
    if (_formKey.currentState?.validate() ?? false) {
      final exercise = Exercise(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        muscleGroup: _selectedMuscleGroup,
        equipment: _selectedEquipment,
        category: _selectedCategory,
        instructions: _notesController.text.trim(),
        isCustom: true,
      );

      Navigator.of(context).pop(exercise);
    }
  }

  // Hàm tạo InputDecoration đồng bộ
  InputDecoration _inputDecoration(
    String label, {
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null
          ? Icon(icon, color: _AppColors.textSecondary)
          : null,
      labelStyle: const TextStyle(color: _AppColors.textSecondary),
      hintStyle: const TextStyle(color: _AppColors.textSecondary),
      filled: true,
      fillColor: _AppColors.surfaceHigh,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _AppColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _AppColors.danger, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _AppColors.danger, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.bg,
      appBar: AppBar(
        backgroundColor: _AppColors.bg,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: _AppColors.textPrimary),
        title: const Text(
          'Tạo bài tập',
          style: TextStyle(
            color: _AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveExercise,
            child: const Text(
              'Lưu',
              style: TextStyle(
                color: _AppColors.accent,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: _AppColors.textPrimary),
              decoration: _inputDecoration(
                'Tên bài tập',
                hint: 'VD: Bench Press, Squat',
                icon: Icons.fitness_center,
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên bài tập';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Category dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: _inputDecoration('Loại', icon: Icons.category),
              dropdownColor: _AppColors.surface,
              style: const TextStyle(color: _AppColors.textPrimary),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: _AppColors.textSecondary,
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedCategory = value);
              },
            ),
            const SizedBox(height: 16),

            // Muscle Group dropdown
            DropdownButtonFormField<String>(
              value: _selectedMuscleGroup,
              decoration: _inputDecoration(
                'Nhóm cơ',
                icon: Icons.accessibility_new,
              ),
              dropdownColor: _AppColors.surface,
              style: const TextStyle(color: _AppColors.textPrimary),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: _AppColors.textSecondary,
              ),
              items: MuscleGroups.keys
                  .map(
                    (key) => DropdownMenuItem(
                      value: key,
                      child: Text(MuscleGroups.label(key)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedMuscleGroup = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Equipment dropdown
            DropdownButtonFormField<String>(
              value: _selectedEquipment,
              decoration: _inputDecoration(
                'Dụng cụ',
                icon: Icons.sports_gymnastics,
              ),
              dropdownColor: _AppColors.surface,
              style: const TextStyle(color: _AppColors.textPrimary),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: _AppColors.textSecondary,
              ),
              items: _equipment
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedEquipment = value);
              },
            ),
            const SizedBox(height: 20),

            // Notes
            TextFormField(
              controller: _notesController,
              style: const TextStyle(color: _AppColors.textPrimary),
              decoration: _inputDecoration(
                'Hướng dẫn (tùy chọn)',
                hint: 'Thêm ghi chú hoặc mẹo kỹ thuật',
                icon: Icons.notes,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),

            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: _AppColors.textSecondary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bài tập tự tạo sẽ được lưu vào thư viện và có thể '
                      'chọn khi tạo giáo án.',
                      style: TextStyle(
                        color: _AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
