import 'package:flutter/material.dart';

import 'create_exercise_screen.dart';
import 'exercise_catalog.dart';

export 'exercise_catalog.dart' show ExerciseInfo;

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

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  String? _selectedGroup;
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
      debugPrint('Không tải được thư viện bài tập: $e');
    }
  }

  Future<void> _createExercise() async {
    final result = await Navigator.of(context).push<Exercise>(
      MaterialPageRoute(builder: (context) => const CreateExerciseScreen()),
    );
    if (result == null) return;

    final custom = await ExerciseCatalog.loadCustom();
    custom.add(result);
    await ExerciseCatalog.saveCustom(custom);
    await _load();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.name} đã được thêm vào bài tập của bạn'),
          backgroundColor: _AppColors.textPrimary,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
          'Bài tập',
          style: TextStyle(
            color: _AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: _AppColors.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tìm kiếm bài tập — sắp ra mắt'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: 'Tìm kiếm',
          ),
        ],
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

          // Exercise list
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
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) =>
                        _ExerciseCard(exercise: exercises[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createExercise,
        backgroundColor: _AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add),
        label: const Text(
          'Bài tập mới',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGET: Exercise Card
// ═══════════════════════════════════════════════════════════════
class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise});

  final ExerciseInfo exercise;

  @override
  Widget build(BuildContext context) {
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
        onTap: () => _showExerciseDetails(context, exercise),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: exercise.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(exercise.icon, color: exercise.color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (exercise.isCustom)
                          const _Chip(
                            label: 'Tự tạo',
                            color: Color(0xFF8B5CF6),
                          ),
                        _Chip(
                          label: MuscleGroups.label(exercise.muscleGroup),
                          color: exercise.color,
                        ),
                        _Chip(
                          label: exercise.equipment,
                          color: _AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: _AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  void _showExerciseDetails(BuildContext context, ExerciseInfo exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: exercise.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(exercise.icon, color: exercise.color, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          MuscleGroups.label(exercise.muscleGroup),
                          style: const TextStyle(
                            fontSize: 15,
                            color: _AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _InfoBox(
                      label: 'Dụng cụ',
                      value: exercise.equipment,
                      icon: Icons.fitness_center,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoBox(
                      label: 'Độ khó',
                      value: exercise.difficulty,
                      icon: Icons.signal_cellular_alt,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Mô tả',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                exercise.description,
                style: const TextStyle(
                  fontSize: 15,
                  color: _AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Cách thực hiện',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. Thiết lập tư thế đúng trước khi bắt đầu\n'
                '2. Bắt đầu với mức tạ bạn kiểm soát được\n'
                '3. Thực hiện chuyển động với biên độ đầy đủ\n'
                '4. Tập trung vào sự co cơ\n'
                '5. Kiểm soát giai đoạn hạ xuống',
                style: TextStyle(
                  fontSize: 15,
                  color: _AppColors.textSecondary,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: _AppColors.textSecondary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Để đưa bài này vào buổi tập: Giáo án → Kế hoạch mới '
                        '→ Từ thư viện.',
                        style: TextStyle(
                          color: _AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGET: Chip nhỏ hiển thị tag
// ═══════════════════════════════════════════════════════════════
class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGET: Info Box
// ═══════════════════════════════════════════════════════════════
class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: _AppColors.textSecondary),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: _AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
