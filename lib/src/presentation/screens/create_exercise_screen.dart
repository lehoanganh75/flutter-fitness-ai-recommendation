import 'package:flutter/material.dart';

import 'exercise_catalog.dart';

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
        muscleGroup: _selectedMuscleGroup, // khóa chuẩn (Chest, Back...)
        equipment: _selectedEquipment,
        category: _selectedCategory,
        instructions: _notesController.text.trim(),
        isCustom: true,
      );

      Navigator.of(context).pop(exercise);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo bài tập'),
        actions: [
          TextButton(
            onPressed: _saveExercise,
            child: const Text(
              'Lưu',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
              decoration: const InputDecoration(
                labelText: 'Tên bài tập',
                hintText: 'VD: Bench Press, Squat',
                prefixIcon: Icon(Icons.fitness_center),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên bài tập';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Loại',
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedCategory = value);
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _selectedMuscleGroup,
              decoration: const InputDecoration(
                labelText: 'Nhóm cơ',
                prefixIcon: Icon(Icons.accessibility_new),
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
                if (value != null) setState(() => _selectedMuscleGroup = value);
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _selectedEquipment,
              decoration: const InputDecoration(
                labelText: 'Dụng cụ',
                prefixIcon: Icon(Icons.sports_gymnastics),
              ),
              items: _equipment
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedEquipment = value);
              },
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Hướng dẫn (tùy chọn)',
                hintText: 'Thêm ghi chú hoặc mẹo kỹ thuật',
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),

            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bài tập tự tạo sẽ được lưu vào thư viện và có thể '
                        'chọn khi tạo giáo án.',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
