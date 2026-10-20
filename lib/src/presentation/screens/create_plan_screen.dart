import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/models/workout.dart';
import '../../domain/repositories/workout_repository.dart';
import 'select_exercise_screen.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one exercise')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      // Create plan
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

      // Create exercises
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

      Navigator.of(context).pop(true); // Return true to indicate success
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Workout plan created!')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Workout Plan'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(onPressed: _savePlan, child: const Text('Save')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Plan Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Workout Title',
                hintText: 'e.g., Push Day, Leg Day',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Day Selector
            const Text(
              'Day of Week',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _DaySelector(
              selectedDay: _selectedDay,
              onSelected: (day) => setState(() => _selectedDay = day),
            ),
            const SizedBox(height: 24),

            // Exercises Header: tiêu đề một dòng, hai nút nằm trong Wrap
            // để tự xuống dòng khi màn hình hẹp (tránh tràn ngang).
            const Text(
              'Exercises',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _addExerciseFromLibrary,
                  icon: const Icon(Icons.library_add),
                  label: const Text('From Library'),
                ),
                FilledButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add),
                  label: const Text('Custom'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Exercise List
            if (_exercises.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.fitness_center_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No exercises yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap "From Library" or "Custom" to get started',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
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
                );
              }),

            const SizedBox(height: 100), // Space for bottom padding
          ],
        ),
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  const _DaySelector({required this.selectedDay, required this.onSelected});

  final int selectedDay;
  final ValueChanged<int> onSelected;

  static const _labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(7, (index) {
        final day = index + 1;
        final selected = day == selectedDay;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == 6 ? 0 : 6),
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () => onSelected(day),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: selected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  foregroundColor: selected ? Colors.white : null,
                ),
                child: Text(_labels[index]),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    super.key,
    required this.exerciseData,
    required this.index,
    required this.onRemove,
  });

  final _ExerciseFormData exerciseData;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text('${index + 1}')),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Exercise ${index + 1}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  tooltip: 'Remove exercise',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Exercise Name
            TextFormField(
              controller: exerciseData.nameController,
              decoration: const InputDecoration(
                labelText: 'Exercise Name',
                hintText: 'e.g., Bench Press, Squat',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter exercise name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Muscle Group
            TextFormField(
              controller: exerciseData.muscleGroupController,
              decoration: const InputDecoration(
                labelText: 'Muscle Group',
                hintText: 'e.g., Chest, Legs, Back',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter muscle group';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Sets, Reps, Weight in a row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: exerciseData.setsController,
                    decoration: const InputDecoration(
                      labelText: 'Sets',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final sets = int.tryParse(value);
                      if (sets == null || sets < 1) {
                        return 'Min 1';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: exerciseData.repsController,
                    decoration: const InputDecoration(
                      labelText: 'Reps',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final reps = int.tryParse(value);
                      if (reps == null || reps < 1) {
                        return 'Min 1';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: exerciseData.weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final weight = double.tryParse(value);
                      if (weight == null || weight < 0) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
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
