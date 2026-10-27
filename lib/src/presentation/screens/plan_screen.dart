import 'package:flutter/material.dart';

import '../../domain/repositories/workout_repository.dart';
import '../../services/workout_service.dart';
import 'create_plan_screen.dart';

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
      _loadPlans();
    }
  }

  Future<void> _deletePlan(WorkoutPlanDetails details) async {
    final repository = widget.repository;
    if (repository == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _AppColors.surface,
        title: const Text(
          'Xoá giáo án?',
          style: TextStyle(color: _AppColors.textPrimary),
        ),
        content: Text(
          'Bạn có chắc muốn xoá "${details.plan.title}"? '
          '${details.exercises.length} bài tập sẽ bị xoá theo.',
          style: const TextStyle(color: _AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Huỷ',
              style: TextStyle(color: _AppColors.textSecondary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await repository.deletePlan(details.plan.id);
      if (!mounted) return;
      _showSnack('Đã xoá "${details.plan.title}"');
      await _loadPlans();
    } catch (error) {
      if (!mounted) return;
      _showSnack('Xoá thất bại: $error');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.bg,
      appBar: AppBar(
        backgroundColor: _AppColors.bg,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Giáo án',
          style: TextStyle(
            color: _AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: _AppColors.accent,
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
                child: Center(
                  child: CircularProgressIndicator(color: _AppColors.accent),
                ),
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
              backgroundColor: _AppColors.accent,
              foregroundColor: Colors.white,
              elevation: 2,
              icon: const Icon(Icons.add),
              label: const Text(
                'Kế hoạch mới',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          : null,
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
            child: Semantics(
              button: true,
              selected: selected,
              label: '${_labels[index]}${selected ? ', selected' : ''}',
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
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGET: Plan Card
// ═══════════════════════════════════════════════════════════════
class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.details, this.onDelete});

  final WorkoutPlanDetails details;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  details.plan.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _AppColors.textPrimary,
                  ),
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: _AppColors.danger,
                  tooltip: 'Xoá giáo án',
                  onPressed: onDelete,
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (details.exercises.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Không có bài tập trong kế hoạch này.',
                style: TextStyle(color: _AppColors.textSecondary),
              ),
            )
          else
            ...details.exercises.map(
              (exercise) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _AppColors.accent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${exercise.sortOrder}',
                        style: const TextStyle(
                          color: _AppColors.accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.exercise,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${exercise.muscleGroup} · '
                            '${exercise.targetSets} set × '
                            '${exercise.targetReps} lần · '
                            '${_weightLabel(exercise.initialWeight)} kg',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _weightLabel(double weight) {
    return weight == weight.roundToDouble()
        ? weight.toInt().toString()
        : weight.toString();
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGET: Empty / Error state
// ═══════════════════════════════════════════════════════════════
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
      padding: const EdgeInsets.only(top: 24),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _AppColors.border),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: _AppColors.textSecondary,
              semanticLabel: title,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _AppColors.textSecondary),
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: action,
                style: FilledButton.styleFrom(
                  backgroundColor: _AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
