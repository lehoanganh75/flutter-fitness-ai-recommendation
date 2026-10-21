import 'package:flutter/material.dart';

import 'create_exercise_screen.dart';
import 'exercise_catalog.dart';

export 'exercise_catalog.dart' show ExerciseInfo;

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  /// null = tất cả nhóm cơ.
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
      appBar: AppBar(
        title: const Text('Bài tập'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tìm kiếm bài tập — sắp ra mắt')),
              );
            },
            tooltip: 'Tìm kiếm',
          ),
        ],
      ),
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
                    itemBuilder: (context, index) =>
                        _ExerciseCard(exercise: exercises[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createExercise,
        icon: const Icon(Icons.add),
        label: const Text('Bài tập mới'),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise});

  final ExerciseInfo exercise;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showExerciseDetails(context, exercise),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: exercise.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (exercise.isCustom)
                          const _Chip(label: 'Tự tạo', color: Colors.purple),
                        _Chip(
                          label: MuscleGroups.label(exercise.muscleGroup),
                          color: exercise.color,
                        ),
                        _Chip(label: exercise.equipment, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
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
                    color: Colors.grey[300],
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
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          MuscleGroups.label(exercise.muscleGroup),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                exercise.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Cách thực hiện',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '1. Thiết lập tư thế đúng trước khi bắt đầu\n'
                '2. Bắt đầu với mức tạ bạn kiểm soát được\n'
                '3. Thực hiện chuyển động với biên độ đầy đủ\n'
                '4. Tập trung vào sự co cơ\n'
                '5. Kiểm soát giai đoạn hạ xuống',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Để đưa bài này vào buổi tập: Giáo án → Kế hoạch mới '
                          '→ Từ thư viện.',
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
      ),
    );
  }
}

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
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.grey[700]),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
