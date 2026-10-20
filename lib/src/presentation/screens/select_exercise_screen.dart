import 'package:flutter/material.dart';

import 'exercise_catalog.dart';

class SelectExerciseScreen extends StatefulWidget {
  const SelectExerciseScreen({super.key});

  @override
  State<SelectExerciseScreen> createState() => _SelectExerciseScreenState();
}

class _SelectExerciseScreenState extends State<SelectExerciseScreen> {
  /// null = tất cả nhóm cơ.
  String? _selectedGroup;

  // Hiện bài có sẵn ngay, bài tự tạo được nạp thêm sau đó.
  List<ExerciseInfo> _all = ExerciseCatalog.builtIn;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final all = await ExerciseCatalog.loadAll();
      if (mounted) setState(() => _all = all);
    } catch (e) {
      debugPrint('Không tải được bài tập tùy chỉnh: $e');
    }
  }

  List<ExerciseInfo> get _filtered {
    final group = _selectedGroup;
    if (group == null) return _all;
    return _all.where((e) => e.muscleGroup == group).toList();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _filtered;
    final filters = <String?>[null, ...MuscleGroups.keys];

    return Scaffold(
      appBar: AppBar(title: const Text('Chọn bài tập')),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final key = filters[index];
                final isSelected = key == _selectedGroup;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      key == null ? 'Tất cả' : MuscleGroups.label(key),
                    ),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedGroup = key),
                    selectedColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: isSelected ? FontWeight.bold : null,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: exercises.isEmpty
                ? const Center(child: Text('Chưa có bài tập nào ở nhóm này.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: exercise.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(exercise.icon, color: exercise.color),
                          ),
                          title: Text(exercise.name),
                          subtitle: Text(
                            '${MuscleGroups.label(exercise.muscleGroup)} · '
                            '${exercise.equipment}'
                            '${exercise.isCustom ? ' · Tự tạo' : ''}',
                          ),
                          trailing: const Icon(Icons.add_circle_outline),
                          onTap: () {
                            // muscleGroup trả về là khóa chuẩn (Chest, Back...)
                            Navigator.of(context).pop({
                              'name': exercise.name,
                              'muscleGroup': exercise.muscleGroup,
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
