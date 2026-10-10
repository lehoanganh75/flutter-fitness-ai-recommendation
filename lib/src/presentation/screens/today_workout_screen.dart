import 'package:flutter/material.dart';

import '../../domain/models/today_workout.dart';
import '../../domain/models/workout.dart';
import '../../services/log_set_service.dart';
import '../../services/workout_service.dart';

class TodayWorkoutScreen extends StatefulWidget {
  const TodayWorkoutScreen({
    super.key,
    this.workout,
    this.workoutService,
    this.logSetService,
    this.userId = 'sample-user',
    this.dayOfWeek,
    this.isLoading = false,
    this.errorMessage,
    this.idGenerator,
  });

  final TodayWorkout? workout;
  final WorkoutService? workoutService;
  final LogSetService? logSetService;
  final String userId;
  final int? dayOfWeek;
  final bool isLoading;
  final String? errorMessage;
  final String Function()? idGenerator;

  @override
  State<TodayWorkoutScreen> createState() => _TodayWorkoutScreenState();
}

class _TodayWorkoutScreenState extends State<TodayWorkoutScreen> {
  TodayWorkout? _workout;
  late PlannedExercise _activeExercise;
  late int _completedSets;
  late bool _loading;
  String? _loadError;
  bool _saving = false;
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  final _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loading = widget.isLoading;
    _loadError = widget.errorMessage;
    if (widget.workout != null) {
      _setWorkout(widget.workout!);
    } else if (widget.workoutService != null) {
      _loadWorkout();
    } else {
      _setWorkout(sampleTodayWorkout());
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const _StateScaffold(
        title: "Today's workout",
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError != null) {
      return _StateScaffold(
        title: "Today's workout",
        child: _MessageState(
          icon: Icons.cloud_off_outlined,
          title: 'Unable to load workout',
          message: _loadError!,
        ),
      );
    }
    final workout = _workout;
    if (workout == null || workout.exercises.isEmpty) {
      return const _StateScaffold(
        title: "Today's workout",
        child: _MessageState(
          icon: Icons.fitness_center,
          title: 'No workout planned',
          message: 'Your next workout will appear here when it is ready.',
        ),
      );
    }

    final progress = _completedSets / _activeExercise.targetSets;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's workout"),
        actions: [
          IconButton(
            tooltip: 'Workout history',
            onPressed: () {},
            icon: const Icon(Icons.history),
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth > 700 ? 48.0 : 20.0;
            return ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                32,
              ),
              children: [
                Text(
                  workout.plan.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${workout.exercises.length} exercises · ${workout.muscleGroups.join(' · ')}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 24),
                _ProgressCard(
                  completedSets: _completedSets,
                  totalSets: _activeExercise.targetSets,
                  progress: progress.clamp(0.0, 1.0),
                ),
                const SizedBox(height: 20),
                Text(
                  'Next up',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                _ExerciseCard(exercise: _activeExercise),
                const SizedBox(height: 20),
                _SetForm(
                  weightController: _weightController,
                  repsController: _repsController,
                  feedbackController: _feedbackController,
                  onSave: _saving ? null : _saveSet,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _loadWorkout() async {
    try {
      final workout = await widget.workoutService!.loadTodayWorkout(
        userId: widget.userId,
        dayOfWeek: widget.dayOfWeek ?? DateTime.now().weekday,
      );
      if (!mounted) return;
      setState(() {
        _loading = false;
        _setWorkout(workout);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = error.toString();
      });
    }
  }

  void _setWorkout(TodayWorkout? workout) {
    _workout = workout;
    if (workout == null || workout.exercises.isEmpty) return;
    _activeExercise =
        workout.activeExercise(
          loggedSetsByExercise: workout.loggedSetsByExercise,
        ) ??
        workout.exercises.first;
    _completedSets =
        (workout.loggedSetsByExercise[_activeExercise.id] ?? const []).length;
    _weightController.text = workout
        .currentWeightFor(
          exercise: _activeExercise,
          loggedSetsByExercise: workout.loggedSetsByExercise,
        )
        .toStringAsFixed(1);
    _repsController.text = _activeExercise.targetReps.toString();
  }

  Future<void> _saveSet() async {
    final workout = _workout;
    if (workout == null) return;
    final weight = double.tryParse(_weightController.text);
    final reps = int.tryParse(_repsController.text);
    if (weight == null || reps == null || weight < 0 || reps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid weight and rep count.')),
      );
      return;
    }
    final loggedSet = LoggedSet(
      id:
          widget.idGenerator?.call() ??
          'set-${DateTime.now().microsecondsSinceEpoch}',
      exerciseId: _activeExercise.id,
      setIndex: _completedSets + 1,
      weight: weight,
      reps: reps,
      feedbackText: _feedbackController.text.trim().isEmpty
          ? null
          : _feedbackController.text.trim(),
      loggedAt: DateTime.now(),
    );
    setState(() => _saving = true);
    try {
      await widget.logSetService?.logSet(
        userId: widget.userId,
        exercise: _activeExercise.exercise,
        muscleGroup: _activeExercise.muscleGroup,
        targetReps: _activeExercise.targetReps,
        loggedSet: loggedSet,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save set: $error')),
      );
      return;
    }
    workout.loggedSetsByExercise[_activeExercise.id]!.add(loggedSet);
    setState(() {
      _saving = false;
      _completedSets = (_completedSets + 1).clamp(
        0,
        _activeExercise.targetSets,
      );
    });
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Set $_completedSets saved'),
        backgroundColor: const Color(0xFF16A34A),
      ),
    );
  }
}

class _StateScaffold extends StatelessWidget {
  const _StateScaffold({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: SafeArea(child: child),
  );
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: const Color(0xFFDC2626)),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.completedSets,
    required this.totalSets,
    required this.progress,
  });
  final int completedSets;
  final int totalSets;
  final double progress;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Session progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text('$completedSets of $totalSets sets'),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFFECACA),
              color: const Color(0xFF16A34A),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise});
  final PlannedExercise exercise;

  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFFEF2F2),
        child: Icon(Icons.fitness_center, color: Color(0xFFDC2626)),
      ),
      title: Text(
        exercise.exercise,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        '${exercise.muscleGroup} · ${exercise.targetSets} sets × ${exercise.targetReps} reps',
      ),
    ),
  );
}

class _SetForm extends StatelessWidget {
  const _SetForm({
    required this.weightController,
    required this.repsController,
    required this.feedbackController,
    required this.onSave,
  });
  final TextEditingController weightController;
  final TextEditingController repsController;
  final TextEditingController feedbackController;
  final Future<void> Function()? onSave;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Log your set',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    prefixIcon: Icon(Icons.monitor_weight_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: repsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Reps',
                    prefixIcon: Icon(Icons.repeat),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: feedbackController,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'How did it feel? (optional)',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.notes_outlined),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.check),
              label: const Text('Save set'),
            ),
          ),
        ],
      ),
    ),
  );
}

TodayWorkout sampleTodayWorkout() {
  final plan = WorkoutPlan(
    id: 'today-plan',
    userId: 'sample-user',
    title: 'Upper body strength',
    dayOfWeek: DateTime.monday,
    createdAt: DateTime(2026, 1, 1),
  );
  final bench = PlannedExercise(
    id: 'bench-press',
    planId: plan.id,
    exercise: 'Bench press',
    muscleGroup: 'Chest',
    sortOrder: 1,
    targetSets: 4,
    targetReps: 8,
    initialWeight: 40,
  );
  final row = PlannedExercise(
    id: 'seated-row',
    planId: plan.id,
    exercise: 'Seated cable row',
    muscleGroup: 'Back',
    sortOrder: 2,
    targetSets: 3,
    targetReps: 10,
    initialWeight: 35,
  );
  return TodayWorkout(
    plan: plan,
    exercises: [bench, row],
    loggedSetsByExercise: {
      bench.id: [
        LoggedSet(
          id: 'set-1',
          exerciseId: bench.id,
          setIndex: 1,
          weight: 40,
          reps: 8,
          loggedAt: DateTime(2026, 1, 1, 8),
        ),
      ],
      row.id: const [],
    },
  );
}
