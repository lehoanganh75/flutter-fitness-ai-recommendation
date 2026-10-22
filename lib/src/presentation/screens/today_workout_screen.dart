import 'package:fitness_recommendation/src/services/weight_advice_service.dart';
import 'package:flutter/material.dart';

import '../../app/app_dependencies.dart' show kLocalUserId;
import '../../domain/models/recommendation.dart';
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
    this.weightAdviceService,
    this.userId = kLocalUserId,
    this.dayOfWeek,
    this.isLoading = false,
    this.errorMessage,
    this.idGenerator,
    this.onSetLogged,
  });

  final TodayWorkout? workout;
  final WorkoutService? workoutService;
  final LogSetService? logSetService;
  final WeightAdviceService? weightAdviceService;
  final String userId;
  final int? dayOfWeek;
  final bool isLoading;
  final String? errorMessage;
  final String Function()? idGenerator;

  /// Gọi sau mỗi lần lưu set thành công (để shell biết cần làm mới dữ liệu).
  final VoidCallback? onSetLogged;

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

  /// Trọng lượng của set gần nhất ở các buổi trước (để gợi ý mức tạ ban đầu).
  Map<String, double> _lastKnownWeight = {};

  /// AI gợi ý cân nặng cho set tiếp theo (sau khi lưu set hiện tại).
  Recommendation? _advice;
  bool _adviceLoading = false;

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
      _loading = true;
      _loadWorkout();
    }
    // Không có workout lẫn service → giữ _workout = null để màn hình
    // hiển thị trạng thái "Không có kế hoạch tập luyện".
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
        title: 'Tập luyện hôm nay',
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError != null) {
      return _StateScaffold(
        title: 'Tập luyện hôm nay',
        child: _MessageState(
          icon: Icons.cloud_off_outlined,
          title: 'Không thể tải tập luyện',
          message: _loadError!,
        ),
      );
    }
    final workout = _workout;
    if (workout == null || workout.exercises.isEmpty) {
      return const _StateScaffold(
        title: 'Tập luyện hôm nay',
        child: _MessageState(
          icon: Icons.fitness_center,
          title: 'Không có kế hoạch tập luyện',
          message: 'Hôm nay chưa có giáo án. Hãy tạo giáo án ở tab Giáo án rồi quay lại.',
        ),
      );
    }

    final progress = _activeExercise.targetSets == 0
        ? 0.0
        : _completedSets / _activeExercise.targetSets;
    final activeDone = _completedSets >= _activeExercise.targetSets;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tập luyện hôm nay'),
        actions: [
          IconButton(
            tooltip: 'Lịch sử tập luyện',
            onPressed: _showHistory,
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
                  '${workout.exercises.length} bài · ${workout.muscleGroups.join(' · ')}',
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: const Color(0xFF475569)),
                ),
                const SizedBox(height: 24),
                _ProgressCard(
                  completedSets: _completedSets,
                  totalSets: _activeExercise.targetSets,
                  progress: progress.clamp(0.0, 1.0),
                ),
                const SizedBox(height: 20),
                // 🆕 Recommendation Card (hiện nếu có advice)
                if (_advice != null)
                  _RecommendationCard(
                    recommendation: _advice!,
                    isLoading: _adviceLoading,
                    onApply: _applyAdvice,
                    onDismiss: _dismissAdvice,
                  ),
                if (_advice != null) const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tiếp theo',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (_currentExerciseIndex >= 0)
                      Text(
                        'Bài ${_currentExerciseIndex + 1} / ${_orderedExercises.length}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                _ExerciseCard(exercise: _activeExercise),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _hasPreviousExercise
                            ? _handlePreviousTap
                            : null,
                        icon: const Icon(Icons.skip_previous),
                        label: const Text('Bài trước'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: _hasNextExercise ? _handleNextTap : null,
                        icon: const Icon(Icons.skip_next),
                        label: const Text('Bài kế tiếp'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_isWorkoutCompleted)
                  const _CompletionBanner()
                else if (activeDone)
                  _ExerciseDoneCard(totalSets: _activeExercise.targetSets)
                else
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
      final loaded = await widget.workoutService!.loadTodayWorkout(
        userId: widget.userId,
        dayOfWeek: widget.dayOfWeek ?? DateTime.now().weekday,
      );
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = null;
        _setWorkout(loaded == null ? null : _onlyToday(loaded));
      });
    } catch (error) {
      debugPrint('Load today workout failed: $error');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'Không tải được buổi tập. Vui lòng thử lại.';
      });
    }
  }

  /// Chỉ giữ các set của hôm nay. Nếu không lọc, bài đã tập đủ set ở tuần
  /// trước sẽ bị coi là "đã xong" và không tập lại được.
  /// Trọng lượng gần nhất của các buổi trước vẫn được giữ để gợi ý mức tạ.
  TodayWorkout _onlyToday(TodayWorkout source) {
    final now = DateTime.now();
    bool isToday(LoggedSet s) =>
        s.loggedAt.year == now.year &&
        s.loggedAt.month == now.month &&
        s.loggedAt.day == now.day;

    final today = <String, List<LoggedSet>>{};
    final lastWeights = <String, double>{};

    for (final exercise in source.exercises) {
      final all =
          source.loggedSetsByExercise[exercise.id] ?? const <LoggedSet>[];
      if (all.isNotEmpty) {
        final latest = all.reduce(
          (a, b) => b.loggedAt.isAfter(a.loggedAt) ? b : a,
        );
        lastWeights[exercise.id] = latest.weight;
      }
      today[exercise.id] = all.where(isToday).toList();
    }

    _lastKnownWeight = lastWeights;
    return TodayWorkout(
      plan: source.plan,
      exercises: source.exercises,
      loggedSetsByExercise: today,
    );
  }

  double _weightFor(TodayWorkout workout, PlannedExercise exercise) {
    final todays =
        workout.loggedSetsByExercise[exercise.id] ?? const <LoggedSet>[];
    if (todays.isNotEmpty) {
      return workout.currentWeightFor(
        exercise: exercise,
        loggedSetsByExercise: workout.loggedSetsByExercise,
      );
    }
    return _lastKnownWeight[exercise.id] ?? exercise.initialWeight;
  }

  void _setWorkout(TodayWorkout? workout) {
    _workout = workout;
    if (workout == null || workout.exercises.isEmpty) return;
    final sortedExercises = [...workout.exercises]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _activeExercise =
        workout.activeExercise(
          loggedSetsByExercise: workout.loggedSetsByExercise,
        ) ??
        sortedExercises.last;
    _completedSets =
        (workout.loggedSetsByExercise[_activeExercise.id] ?? const []).length;
    _weightController.text = _weightFor(
      workout,
      _activeExercise,
    ).toStringAsFixed(1);
    _repsController.text = _activeExercise.targetReps.toString();
  }

  /// Danh sách bài tập đã sắp theo thứ tự trong giáo án.
  List<PlannedExercise> get _orderedExercises {
    final workout = _workout;
    if (workout == null) return const [];
    return [...workout.exercises]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// Chỉ số của bài tập đang tập trong [_orderedExercises] (bắt đầu từ 0).
  int get _currentExerciseIndex =>
      _orderedExercises.indexWhere((e) => e.id == _activeExercise.id);

  bool get _hasPreviousExercise => _currentExerciseIndex > 0;

  bool get _hasNextExercise {
    final index = _currentExerciseIndex;
    return index >= 0 && index + 1 < _orderedExercises.length;
  }

  /// True khi mọi bài tập đã đủ số set (hiển thị realtime).
  bool get _isWorkoutCompleted {
    final workout = _workout;
    if (workout == null || workout.exercises.isEmpty) return false;
    for (final e in workout.exercises) {
      final done = (workout.loggedSetsByExercise[e.id] ?? const []).length;
      if (done < e.targetSets) return false;
    }
    return true;
  }

  /// Bài chưa đủ set gần nhất sau bài hiện tại (quay vòng về đầu danh sách).
  PlannedExercise? _nextIncompleteExercise() {
    final workout = _workout;
    if (workout == null) return null;
    final list = _orderedExercises;
    final start = _currentExerciseIndex;
    if (start < 0) return null;
    for (var step = 1; step < list.length; step++) {
      final exercise = list[(start + step) % list.length];
      final done =
          (workout.loggedSetsByExercise[exercise.id] ?? const []).length;
      if (done < exercise.targetSets) return exercise;
    }
    return null;
  }

  void _handleNextTap() {
    if (!_goToNextExercise()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã chuyển sang: ${_activeExercise.exercise}'),
        backgroundColor: const Color(0xFF16A34A),
      ),
    );
  }

  void _handlePreviousTap() {
    if (!_goToPreviousExercise()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Quay lại: ${_activeExercise.exercise}'),
        backgroundColor: const Color(0xFF16A34A),
      ),
    );
  }

  bool _goToNextExercise() {
    final index = _currentExerciseIndex;
    final exercises = _orderedExercises;
    if (index < 0 || index + 1 >= exercises.length) return false;
    _switchToExercise(exercises[index + 1]);
    return true;
  }

  bool _goToPreviousExercise() {
    final index = _currentExerciseIndex;
    final exercises = _orderedExercises;
    if (index <= 0) return false;
    _switchToExercise(exercises[index - 1]);
    return true;
  }

  /// Chuyển bài tập đang active sang [exercise] và đồng bộ lại form.
  void _switchToExercise(PlannedExercise exercise) {
    final workout = _workout;
    if (workout == null) return;
    setState(() {
      _activeExercise = exercise;
      _completedSets =
          (workout.loggedSetsByExercise[exercise.id] ?? const []).length;
      _weightController.text = _weightFor(workout, exercise).toStringAsFixed(1);
      _repsController.text = exercise.targetReps.toString();
      _feedbackController.clear();
      _advice = null; // 🆕 Xoá card gợi ý khi chuyển bài
      _adviceLoading = false;
    });
  }

  String _formatWeight(double weight) => weight == weight.roundToDouble()
      ? weight.toInt().toString()
      : weight.toStringAsFixed(1);

  void _showHistory() {
    final workout = _workout;
    if (workout == null) return;

    final entries = <Widget>[];
    for (final exercise in _orderedExercises) {
      final sets = [
        ...(workout.loggedSetsByExercise[exercise.id] ?? const <LoggedSet>[]),
      ]..sort((a, b) => a.setIndex.compareTo(b.setIndex));
      if (sets.isEmpty) continue;
      entries.add(
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 4),
          child: Text(
            exercise.exercise,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
      );
      for (final set in sets) {
        final feedback = (set.feedbackText ?? '').isEmpty
            ? ''
            : ' · "${set.feedbackText}"';
        entries.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              'Set ${set.setIndex}: ${_formatWeight(set.weight)} kg × ${set.reps}$feedback',
            ),
          ),
        );
      }
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Lịch sử buổi tập hôm nay',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Chưa có set nào được ghi hôm nay.'),
              )
            else
              ...entries,
          ],
        ),
      ),
    );
  }

  Future<void> _saveSet() async {
    final workout = _workout;
    if (workout == null) return;
    if (_completedSets >= _activeExercise.targetSets) return;

    final weight = double.tryParse(_weightController.text.replaceAll(',', '.'));
    final reps = int.tryParse(_repsController.text);
    if (weight == null || reps == null || weight < 0 || reps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập trọng lượng và số lần hợp lệ.')),
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
      debugPrint('Save set failed: $error');
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể lưu set. Vui lòng thử lại.')),
      );
      return;
    }

    // Tạo list mới thay vì .add() để không lỗi khi list gốc là const.
    final exerciseId = _activeExercise.id;
    workout.loggedSetsByExercise[exerciseId] = [
      ...(workout.loggedSetsByExercise[exerciseId] ?? const <LoggedSet>[]),
      loggedSet,
    ];
    widget.onSetLogged?.call();

    final finishedName = _activeExercise.exercise;
    final finishedExercise = _completedSets + 1 >= _activeExercise.targetSets;
    setState(() {
      _saving = false;
      _completedSets = (_completedSets + 1).clamp(
        0,
        _activeExercise.targetSets,
      );
    });
    FocusScope.of(context).unfocus();

    // 🆕 Nếu có feedback và chưa đủ targetSets → gọi AI để lấy gợi ý
    final feedback = _feedbackController.text.trim();
    if (feedback.isNotEmpty && !finishedExercise) {
      _requestWeightAdvice(weight, feedback);
    }

    if (!finishedExercise) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã lưu set $_completedSets'),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
      return;
    }

    // Đủ set của bài hiện tại → chuyển sang bài chưa xong kế tiếp (nếu có).
    final next = _nextIncompleteExercise();
    if (next != null) {
      _switchToExercise(next);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          next != null
              ? 'Hoàn thành $finishedName — chuyển sang ${next.exercise}'
              : 'Hoàn thành $finishedName — đã xong tất cả bài tập!',
        ),
        backgroundColor: const Color(0xFF16A34A),
      ),
    );
  }

  Future<void> _requestWeightAdvice(
    double currentWeight,
    String feedback,
  ) async {
    if (_adviceLoading) return;

    final service = widget.weightAdviceService;
    if (service == null) return;

    setState(() {
      _adviceLoading = true;
      _advice = null;
    });

    try {
      final recommendation = await service.recommendFor(
        userId: widget.userId,
        exerciseId: _activeExercise.id,
        exercise: _activeExercise.exercise,
        muscleGroup: _activeExercise.muscleGroup,
        currentWeight: currentWeight,
        targetReps: _activeExercise.targetReps,
        feedback: feedback,
      );

      if (!mounted) return;

      setState(() {
        _advice = recommendation;
      });
    } catch (error, stackTrace) {
      debugPrint('[WeightAdvice] Request failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (mounted) {
        setState(() {
          _adviceLoading = false;
        });
      }
    }
  }

  void _applyAdvice() {
    final advice = _advice;
    if (advice == null) return;

    setState(() {
      _weightController.text = advice.suggestedWeight.toStringAsFixed(1);
      _advice = null;
    });
  }

  /// 🆕 Bỏ qua gợi ý: ẩn card
  void _dismissAdvice() {
    setState(() {
      _advice = null;
    });
  }
}

class _CompletionBanner extends StatelessWidget {
  const _CompletionBanner();

  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFFDCFCE7),
    child: const Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 32),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hoàn thành tất cả!',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text('Bạn đã xong tất cả bài tập hôm nay.'),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ExerciseDoneCard extends StatelessWidget {
  const _ExerciseDoneCard({required this.totalSets});

  final int totalSets;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Color(0xFF16A34A)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Bài này đã đủ $totalSets set. Chuyển sang bài khác để tiếp tục.',
            ),
          ),
        ],
      ),
    ),
  );
}

/// Widget hiển thị gợi ý từ AI.
class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.recommendation,
    required this.isLoading,
    required this.onApply,
    required this.onDismiss,
  });

  final Recommendation recommendation;
  final bool isLoading;
  final VoidCallback onApply;
  final VoidCallback onDismiss;

  String _reasonLabel(RecommendationReason reason) {
    return switch (reason) {
      RecommendationReason.USER_REPORTED_FATIGUE =>
        'Dựa trên phản hồi về mức độ mệt mỏi của bạn.',
      RecommendationReason.PROGRESSION =>
        'Gợi ý tăng hoặc giảm tạ dựa trên tiến độ tập luyện.',
      RecommendationReason.USER_PREFERENCE =>
        'Gợi ý dựa trên sở thích tập luyện của bạn.',
      RecommendationReason.NO_DATA =>
        'Chưa có đủ dữ liệu lịch sử để đưa ra gợi ý chính xác.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final action = recommendation.action;
    final icon = _actionIcon(action);
    final color = _actionColor(action);

    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _actionLabel(action),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Cân nặng: ${recommendation.suggestedWeight.toStringAsFixed(1)} kg',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${(recommendation.confidence * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _reasonLabel(recommendation.reason),
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: isLoading ? null : onApply,
                    child: const Text('Áp dụng cân nặng'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : onDismiss,
                    child: const Text('Bỏ qua'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _actionIcon(RecommendationAction action) {
    return switch (action) {
      RecommendationAction.INCREASE_WEIGHT => Icons.arrow_upward,
      RecommendationAction.DECREASE_WEIGHT => Icons.arrow_downward,
      RecommendationAction.REST => Icons.pause,
      RecommendationAction.KEEP_WEIGHT => Icons.check,
    };
  }

  Color _actionColor(RecommendationAction action) {
    return switch (action) {
      RecommendationAction.INCREASE_WEIGHT => const Color(0xFF16A34A),
      RecommendationAction.DECREASE_WEIGHT => const Color(0xFFDC2626),
      RecommendationAction.REST => const Color(0xFF2563EB),
      RecommendationAction.KEEP_WEIGHT => const Color(0xFF8B5CF6),
    };
  }

  String _actionLabel(RecommendationAction action) {
    return switch (action) {
      RecommendationAction.INCREASE_WEIGHT => 'Nâng cân nặng',
      RecommendationAction.DECREASE_WEIGHT => 'Hạ cân nặng',
      RecommendationAction.REST => 'Nghỉ ngơi',
      RecommendationAction.KEEP_WEIGHT => 'Giữ nguyên',
    };
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
                'Tiến độ bài tập',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text('$completedSets / $totalSets set'),
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
        '${exercise.muscleGroup} · ${exercise.targetSets} set × ${exercise.targetReps} lần',
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
            'Ghi nhận set',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
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
                    labelText: 'Trọng lượng (kg)',
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
                    labelText: 'Số lần',
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
              labelText: 'Cảm giác thế nào? (tùy chọn)',
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
              label: const Text('Lưu set'),
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
