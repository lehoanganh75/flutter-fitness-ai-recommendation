import 'package:flutter/material.dart';

import '../../domain/repositories/workout_repository.dart';
import '../../services/workout_service.dart';
import 'create_plan_screen.dart';

typedef PlanLoader = Future<List<WorkoutPlanDetails>> Function(
  String userId,
  int dayOfWeek,
);

class PlanScreen extends StatefulWidget {
  const PlanScreen({
    super.key,
    this.workoutService,
    this.planLoader,
    this.userId = 'sample-user',
    this.initialDayOfWeek,
    this.repository,
  });

  final WorkoutService? workoutService;
  final WorkoutRepository? repository;
  final PlanLoader? planLoader;
  final String userId;
  final int? initialDayOfWeek;

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  late int _selectedDay;
  List<WorkoutPlanDetails> _plans = const [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDayOfWeek ?? DateTime.now().weekday;
    if (widget.planLoader != null || widget.workoutService != null) {
      _loadPlans();
    }
  }

  Future<void> _loadPlans() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final loader =
          widget.planLoader ??
          (String userId, int day) => widget.workoutService!.loadPlansForDay(
            userId: userId,
            dayOfWeek: day,
          );
      final plans = await loader(widget.userId, _selectedDay);
      if (!mounted) return;
      setState(() {
        _plans = plans;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _plans = const [];
        _loading = false;
        _error = error.toString();
      });
    }
  }

  void _selectDay(int day) {
    if (day == _selectedDay) return;
    setState(() => _selectedDay = day);
    if (widget.planLoader != null || widget.workoutService != null) {
      _loadPlans();
    }
  }

  Future<void> _navigateToCreatePlan() async {
    if (widget.repository == null) return;
    
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => CreatePlanScreen(
          repository: widget.repository!,
          userId: widget.userId,
          initialDayOfWeek: _selectedDay,
        ),
      ),
    );

    if (result == true && mounted) {
      _loadPlans(); // Reload plans after creating new one
    }
  }

  Future<void> _deletePlan(WorkoutPlanDetails details) async {
    final repository = widget.repository;
    if (repository == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa kế hoạch?'),
        content: Text(
          'Bạn có chắc muốn xóa "${details.plan.title}"? '
          '${details.exercises.length} bài tập sẽ bị xóa theo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await repository.deletePlan(details.plan.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xóa "${details.plan.title}"')),
      );
      await _loadPlans();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa thất bại: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giáo án')),
      body: RefreshIndicator(
        onRefresh: (widget.planLoader != null || widget.workoutService != null)
            ? _loadPlans
            : () async {},
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            _DaySelector(selectedDay: _selectedDay, onSelected: _selectDay),
            const SizedBox(height: 20),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _StateMessage(
                icon: Icons.cloud_off_outlined,
                title: 'Không thể tải kế hoạch',
                message: _error!,
                action: _loadPlans,
              )
            else if (_plans.isEmpty)
              const _StateMessage(
                icon: Icons.calendar_month_outlined,
                title: 'Không có kế hoạch cho ngày này',
                message: 'Xây dựng và quản lý kế hoạch tập luyện hàng tuần.',
              )
            else
              ..._plans.map(
                (details) => _PlanCard(
                  details: details,
                  onDelete: widget.repository != null
                      ? () => _deletePlan(details)
                      : null,
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: widget.repository != null
          ? FloatingActionButton.extended(
              onPressed: _navigateToCreatePlan,
              icon: const Icon(Icons.add),
              label: const Text('Kế hoạch mới'),
            )
          : null,
    );
  }
}

class _DaySelector extends StatelessWidget {
  const _DaySelector({required this.selectedDay, required this.onSelected});

  final int selectedDay;
  final ValueChanged<int> onSelected;

  static const _labels = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(7, (index) {
        final day = index + 1;
        final selected = day == selectedDay;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == 6 ? 0 : 6),
            child: Semantics(
              button: true,
              selected: selected,
              label: '${_labels[index]}${selected ? ', selected' : ''}',
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
          ),
        );
      }),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.details, this.onDelete});

  final WorkoutPlanDetails details;
  final VoidCallback? onDelete;

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
                Expanded(
                  child: Text(
                    details.plan.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Theme.of(context).colorScheme.error,
                    tooltip: 'Xóa kế hoạch',
                    onPressed: onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (details.exercises.isEmpty)
              const Text('Không có bài tập trong kế hoạch này.')
            else
              ...details.exercises.map(
                (exercise) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(exercise.exercise),
                  subtitle: Text(
                    '${exercise.muscleGroup} · ${exercise.targetSets} tập ×'
                    '${exercise.targetReps} lần · '
                    '${_weightLabel(exercise.initialWeight)} kg',
                  ),
                  leading: CircleAvatar(child: Text('${exercise.sortOrder}')),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _weightLabel(double weight) {
    return weight == weight.roundToDouble()
        ? weight.toInt().toString()
        : weight.toString();
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, semanticLabel: title),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: action,
                  child: const Text('Thử lại'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
