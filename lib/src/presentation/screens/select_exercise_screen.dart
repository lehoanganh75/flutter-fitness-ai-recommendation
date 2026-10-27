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
}

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
      backgroundColor: _AppColors.bg,
      appBar: AppBar(
        backgroundColor: _AppColors.bg,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Chọn bài tập',
          style: TextStyle(
            color: _AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: _AppColors.textPrimary),
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 56,
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
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : _AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedGroup = key),
                    selectedColor: _AppColors.accent,
                    backgroundColor: _AppColors.surface,
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? _AppColors.accent : _AppColors.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),

          // Danh sách bài tập
          Expanded(
            child: exercises.isEmpty
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _AppColors.border),
                      ),
                      child: const Text(
                        'Chưa có bài tập nào ở nhóm này.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _AppColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: _AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop({
                              'name': exercise.name,
                              'muscleGroup': exercise.muscleGroup,
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: exercise.color.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    exercise.icon,
                                    color: exercise.color,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exercise.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: _AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${MuscleGroups.label(exercise.muscleGroup)} · '
                                        '${exercise.equipment}'
                                        '${exercise.isCustom ? ' · Tự tạo' : ''}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: _AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.add_circle_outline,
                                  color: _AppColors.accent,
                                ),
                              ],
                            ),
                          ),
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
