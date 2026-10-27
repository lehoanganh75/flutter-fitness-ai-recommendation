import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/models/workout.dart';
import '../../domain/repositories/workout_repository.dart';
import 'select_exercise_screen.dart';

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

class CreatePlanScreen extends StatefulWidget {
  const CreatePlanScreen({
    super.key,
    required this.repository,
    required this.userId,
    this.initialDayOfWeek,
  });

  final WorkoutRepository repository;
  final String userId;
  final int? initialDayOfWeek;

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final List<_ExerciseFormData> _exercises = [];
  late int _selectedDay;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDayOfWeek ?? DateTime.now().weekday;
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (final exercise in _exercises) {
      exercise.dispose();
    }
    super.dispose();
  }

  void _addExercise() {
    setState(() {
      _exercises.add(_ExerciseFormData());
    });
  }

  Future<void> _addExerciseFromLibrary() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (context) => const SelectExerciseScreen()),
    );

    if (result != null && mounted) {
      setState(() {
        final exercise = _ExerciseFormData();
        exercise.nameController.text = result['name'] ?? '';
        exercise.muscleGroupController.text = result['muscleGroup'] ?? '';
        _exercises.add(exercise);
      });
    }
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises[index].dispose();
      _exercises.removeAt(index);
    });
  }

  Future<void> _savePlan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_exercises.isEmpty) {
      _showSnack('Vui lòng thêm ít nhất 1 bài tập.');
      return;
    }

    setState(() => _saving = true);

    try {
      final planId = DateTime.now().millisecondsSinceEpoch.toString();
      final now = DateTime.now();
      final plan = WorkoutPlan(
        id: planId,
        userId: widget.userId,
        title: _titleController.text.trim(),
        dayOfWeek: _selectedDay,
        createdAt: now,
      );

      await widget.repository.savePlan(plan);

      for (int i = 0; i < _exercises.length; i++) {
        final exerciseData = _exercises[i];
        final exercise = PlannedExercise(
          id: '${planId}_ex_$i',
          planId: planId,
          exercise: exerciseData.nameController.text.trim(),
          muscleGroup: exerciseData.muscleGroupController.text.trim(),
          targetSets: int.parse(exerciseData.setsController.text),
          targetReps: int.parse(exerciseData.repsController.text),
          initialWeight: double.parse(exerciseData.weightController.text),
          sortOrder: i + 1,
        );

        await widget.repository.saveExercise(exercise);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
      _showSnack('Đã tạo giáo án thành công!');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showSnack('Lỗi: ${e.toString()}');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: _AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Hàm tạo InputDecoration đồng bộ
  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.bg,
      appBar: AppBar(
        backgroundColor: _AppColors.bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _AppColors.textPrimary),
        title: const Text(
          'Tạo giáo án mới',
          style: TextStyle(
            color: _AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _AppColors.accent,
                ),
              ),
            )
          else
            TextButton(
              onPressed: _savePlan,
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
            // Tiêu đề giáo án
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: _AppColors.textPrimary),
              decoration: _inputDecoration(
                'Tên giáo án',
                hint: 'VD: Push Day, Leg Day',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên giáo án';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Chọn ngày
            const Text(
              'Ngày tập',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _DaySelector(
              selectedDay: _selectedDay,
              onSelected: (day) => setState(() => _selectedDay = day),
            ),
            const SizedBox(height: 24),

            // Danh sách bài tập
            const Text(
              'Danh sách bài tập',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _addExerciseFromLibrary,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _AppColors.accent,
                    side: const BorderSide(color: _AppColors.accent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.library_add),
                  label: const Text('Từ thư viện'),
                ),
                FilledButton.icon(
                  onPressed: _addExercise,
                  style: FilledButton.styleFrom(
                    backgroundColor: _AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Tự thêm'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Render các card bài tập
            if (_exercises.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: _AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _AppColors.border),
                ),
                child: Column(
                  children: const [
                    Icon(
                      Icons.fitness_center_outlined,
                      size: 48,
                      color: _AppColors.textSecondary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Chưa có bài tập nào',
                      style: TextStyle(
                        fontSize: 16,
                        color: _AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Bấm "Từ thư viện" hoặc "Tự thêm" để bắt đầu',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            else
              ..._exercises.asMap().entries.map((entry) {
                final index = entry.key;
                final exercise = entry.value;
                return _ExerciseCard(
                  key: ObjectKey(exercise),
                  exerciseData: exercise,
                  index: index,
                  onRemove: () => _removeExercise(index),
                  inputDecoration: _inputDecoration,
                );
              }),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGET: Day selector (dạng pill/chip)
// ═══════════════════════════════════════════════════════════════
class _DaySelector extends StatelessWidget {
  const _DaySelector({required this.selectedDay, required this.onSelected});

  final int selectedDay;
  final ValueChanged<int> onSelected;

  static const _labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(7, (index) {
        final day = index + 1;
        final selected = day == selectedDay;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == 6 ? 0 : 6),
            child: GestureDetector(
              onTap: () => onSelected(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? _AppColors.accent : _AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? _AppColors.accent : _AppColors.border,
                  ),
                ),
                child: Text(
                  _labels[index],
                  style: TextStyle(
                    color: selected ? Colors.white : _AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGET: Exercise Card
// ═══════════════════════════════════════════════════════════════
class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    super.key,
    required this.exerciseData,
    required this.index,
    required this.onRemove,
    required this.inputDecoration,
  });

  final _ExerciseFormData exerciseData;
  final int index;
  final VoidCallback onRemove;
  final InputDecoration Function(String, {String? hint}) inputDecoration;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: _AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Bài tập ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
                color: _AppColors.danger,
                tooltip: 'Xoá bài tập',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tên bài tập
          TextFormField(
            controller: exerciseData.nameController,
            style: const TextStyle(color: _AppColors.textPrimary),
            decoration: inputDecoration(
              'Tên bài tập',
              hint: 'VD: Bench Press, Squat',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập tên bài tập';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Nhóm cơ
          TextFormField(
            controller: exerciseData.muscleGroupController,
            style: const TextStyle(color: _AppColors.textPrimary),
            decoration: inputDecoration(
              'Nhóm cơ',
              hint: 'VD: Ngực, Chân, Lưng',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập nhóm cơ';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Sets / Reps / Weight
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: exerciseData.setsController,
                  style: const TextStyle(color: _AppColors.textPrimary),
                  decoration: inputDecoration('Sets'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Bắt buộc';
                    final sets = int.tryParse(value);
                    if (sets == null || sets < 1) return 'Tối thiểu 1';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: exerciseData.repsController,
                  style: const TextStyle(color: _AppColors.textPrimary),
                  decoration: inputDecoration('Reps'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Bắt buộc';
                    final reps = int.tryParse(value);
                    if (reps == null || reps < 1) return 'Tối thiểu 1';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: exerciseData.weightController,
                  style: const TextStyle(color: _AppColors.textPrimary),
                  decoration: inputDecoration('Kg'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Bắt buộc';
                    final weight = double.tryParse(value);
                    if (weight == null || weight < 0) return 'Không hợp lệ';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExerciseFormData {
  _ExerciseFormData() {
    nameController = TextEditingController();
    muscleGroupController = TextEditingController();
    setsController = TextEditingController(text: '3');
    repsController = TextEditingController(text: '10');
    weightController = TextEditingController(text: '20');
  }

  late final TextEditingController nameController;
  late final TextEditingController muscleGroupController;
  late final TextEditingController setsController;
  late final TextEditingController repsController;
  late final TextEditingController weightController;

  void dispose() {
    nameController.dispose();
    muscleGroupController.dispose();
    setsController.dispose();
    repsController.dispose();
    weightController.dispose();
  }
}
