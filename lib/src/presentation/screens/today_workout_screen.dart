import 'package:fitness_recommendation/src/services/weight_advice_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_dependencies.dart' show kLocalUserId;
import '../../domain/models/recommendation.dart';
import '../../domain/models/today_workout.dart';
import '../../domain/models/workout.dart';
import '../../services/log_set_service.dart';
import '../../services/workout_service.dart';

// ─────────────────────────────────────────────────────────────
// COLORS (Light theme palette)
// ─────────────────────────────────────────────────────────────
class _AppColors {
  static const bg = Color(0xFFF8F9FA); // Nền xám rất nhạt
  static const surface = Colors.white; // Card trắng
  static const surfaceHigh = Color(0xFFF1F3F5); // Xám nhạt cho active
  static const stepperBg = Color(0xFFE9ECEF); // Nền nút +/-
  static const textPrimary = Color(0xFF1F2937); // Chữ đậm
  static const textSecondary = Color(0xFF6B7280); // Chữ xám
  static const border = Color(0xFFE5E7EB); // Viền
  static const accent = Color(0xFF16A34A); // Xanh lá
  static const success = Color(0xFF16A34A);
  static const danger = Color(0xFFDC2626);
  static const purple = Color(0xFF8B5CF6);
}

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
    this.onClose, // Callback xử lý khi bấm nút X
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
  final VoidCallback? onSetLogged;

  /// Callback gọi khi bấm nút X (dùng khi màn hình nằm trong Tab).
  /// Nếu không truyền, sẽ mặc định dùng Navigator.pop hoặc về Home.
  final VoidCallback? onClose;

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

  Map<String, double> _lastKnownWeight = {};

  Recommendation? _advice;
  bool _adviceLoading = false;

  // Dùng List thay vì TextEditingController để render Set Rows
  List<double> _setWeights = [];
  List<int> _setReps = [];

  // Feedback
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
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const _StateScaffold(
        title: 'Tập luyện hôm nay',
        child: Center(
          child: CircularProgressIndicator(color: _AppColors.accent),
        ),
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

    final totalSets = workout.exercises
        .map((e) => e.targetSets)
        .fold<int>(0, (sum, s) => sum + s);
    final totalDone = workout.exercises
        .map((e) => (workout.loggedSetsByExercise[e.id] ?? const []).length)
        .fold<int>(0, (sum, s) => sum + s);
    final overallProgress = totalSets == 0 ? 0.0 : totalDone / totalSets;

    return Scaffold(
      backgroundColor: _AppColors.bg,
      appBar: _buildAppBar(workout, totalDone, totalSets, overallProgress),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            // Chips danh sách bài tập
            _ExerciseChipsRow(
              exercises: _orderedExercises,
              activeId: _activeExercise.id,
              loggedSetsByExercise: workout.loggedSetsByExercise,
              onTap: _switchToExercise,
            ),
            const SizedBox(height: 16),

            // Exercise header
            Text(
              _activeExercise.exercise,
              style: const TextStyle(
                color: _AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _InfoPill(text: _activeExercise.muscleGroup),
                _InfoPill(
                  text:
                      '${_activeExercise.targetSets} × ${_activeExercise.targetReps}',
                ),
                if (_lastKnownWeight[_activeExercise.id] != null)
                  _InfoPill(
                    text:
                        'Best: ${_formatWeight(_lastKnownWeight[_activeExercise.id]!)} kg',
                    color: _AppColors.accent,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Gợi ý AI
            if (_adviceLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _AppColors.success,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Đang phân tích để gợi ý...',
                      style: TextStyle(
                        color: _AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )
            else if (_advice != null)
              _AdviceInlineBar(
                advice: _advice!,
                onApply: _applyAdvice,
                onDismiss: _dismissAdvice,
              ),

            const SizedBox(height: 20),

            // Table header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  SizedBox(width: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'KG',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'REPS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  SizedBox(width: 52),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Danh sách Set Rows
            ...List.generate(_activeExercise.targetSets, (index) {
              final isDone = index < _completedSets;
              final isActive = index == _completedSets && !_saving;
              return _SetRow(
                setIndex: index + 1,
                weight: _setWeights.length > index ? _setWeights[index] : 0,
                reps: _setReps.length > index ? _setReps[index] : 0,
                isDone: isDone,
                isActive: isActive,
                saving: _saving,
                onMinusWeight: () => setState(
                  () => _setWeights[index] = (_setWeights[index] - 2.5).clamp(
                    0,
                    999,
                  ),
                ),
                onPlusWeight: () => setState(
                  () => _setWeights[index] = (_setWeights[index] + 2.5).clamp(
                    0,
                    999,
                  ),
                ),
                onMinusReps: () => setState(
                  () => _setReps[index] = (_setReps[index] - 1).clamp(1, 999),
                ),
                onPlusReps: () => setState(
                  () => _setReps[index] = (_setReps[index] + 1).clamp(1, 999),
                ),
                onComplete: () => _saveSetFromRow(index),
              );
            }),

            const SizedBox(height: 16),

            // Ô Feedback (hiển thị sau khi đã tập ít nhất 1 set)
            if (_completedSets > 0 &&
                _completedSets < _activeExercise.targetSets)
              _FeedbackInput(
                controller: _feedbackController,
                onSubmit: () {
                  final text = _feedbackController.text.trim();
                  if (text.isNotEmpty) {
                    final lastWeight = _setWeights[_completedSets - 1];
                    _requestWeightAdvice(lastWeight, text);
                    FocusScope.of(context).unfocus();
                  }
                },
              ),

            if (_isWorkoutCompleted) ...[
              const SizedBox(height: 24),
              const _CompletionBanner(),
            ],
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    TodayWorkout workout,
    int totalDone,
    int totalSets,
    double progress,
  ) {
    return AppBar(
      backgroundColor: _AppColors.surface,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.close, color: _AppColors.textPrimary),
        onPressed: _handleClose,
      ),
      title: Column(
        children: [
          Text(
            workout.plan.title,
            style: const TextStyle(
              color: _AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$totalDone/$totalSets sets',
            style: const TextStyle(
              color: _AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Lịch sử',
          icon: const Icon(Icons.history, color: _AppColors.textPrimary),
          onPressed: _showHistory,
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(6),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: _AppColors.surfaceHigh,
              color: _AppColors.accent,
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  XỬ LÝ NÚT ĐÓNG (X)
  // ══════════════════════════════════════════════════════════════
  void _handleClose() {
    // 1. Nếu có callback từ bên ngoài (ví dụ Shell truyền vào để chuyển Tab)
    if (widget.onClose != null) {
      widget.onClose!();
      return;
    }

    // 2. Nếu có thể pop (màn hình được push)
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    // 3. Fallback: Nếu đang ở root (không thể pop) và không có callback
    //    -> Cố gắng chuyển về route mặc định của app.
    //    Em có thể thay '/' bằng route thực tế của Home trong app em.
    try {
      navigator.pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      // Nếu app chưa cấu hình route '/', thử pop về màn hình gốc
      debugPrint('Could not navigate to home: $e');
      if (navigator.canPop()) navigator.popUntil((route) => route.isFirst);
    }
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
    _rebuildSetState(workout, _activeExercise);
  }

  void _rebuildSetState(TodayWorkout workout, PlannedExercise exercise) {
    final logged =
        workout.loggedSetsByExercise[exercise.id] ?? const <LoggedSet>[];
    final suggested = _weightFor(workout, exercise);

    _setWeights = List<double>.generate(exercise.targetSets, (index) {
      if (index < logged.length) return logged[index].weight;
      return suggested;
    });
    _setReps = List<int>.generate(exercise.targetSets, (index) {
      if (index < logged.length) return logged[index].reps;
      return exercise.targetReps;
    });
    _feedbackController.clear();
  }

  List<PlannedExercise> get _orderedExercises {
    final workout = _workout;
    if (workout == null) return const [];
    return [...workout.exercises]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  int get _currentExerciseIndex =>
      _orderedExercises.indexWhere((e) => e.id == _activeExercise.id);

  bool get _isWorkoutCompleted {
    final workout = _workout;
    if (workout == null || workout.exercises.isEmpty) return false;
    for (final e in workout.exercises) {
      final done = (workout.loggedSetsByExercise[e.id] ?? const []).length;
      if (done < e.targetSets) return false;
    }
    return true;
  }

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

  void _switchToExercise(PlannedExercise exercise) {
    final workout = _workout;
    if (workout == null) return;
    if (exercise.id == _activeExercise.id) return;
    setState(() {
      _activeExercise = exercise;
      _completedSets =
          (workout.loggedSetsByExercise[exercise.id] ?? const []).length;
      _rebuildSetState(workout, exercise);
      _advice = null;
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
            style: const TextStyle(
              color: _AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
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
              style: const TextStyle(color: _AppColors.textSecondary),
            ),
          ),
        );
      }
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _AppColors.surface,
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
              style: TextStyle(
                color: _AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'Chưa có set nào được ghi hôm nay.',
                  style: TextStyle(color: _AppColors.textSecondary),
                ),
              )
            else
              ...entries,
          ],
        ),
      ),
    );
  }

  // LOGIC LƯU SET (từ Set Row)
  Future<void> _saveSetFromRow(int index) async {
    final workout = _workout;
    if (workout == null) return;
    if (index != _completedSets) return;
    if (_saving) return;

    HapticFeedback.mediumImpact();

    final weight = _setWeights[index];
    final reps = _setReps[index];
    if (weight < 0 || reps <= 0) {
      _showSnack('Trọng lượng và số lần phải hợp lệ.');
      return;
    }

    // Lấy feedback hiện tại (nếu có)
    final feedbackText = _feedbackController.text.trim();

    final loggedSet = LoggedSet(
      id:
          widget.idGenerator?.call() ??
          'set-${DateTime.now().microsecondsSinceEpoch}',
      exerciseId: _activeExercise.id,
      setIndex: index + 1,
      weight: weight,
      reps: reps,
      feedbackText: feedbackText.isEmpty ? null : feedbackText,
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
      _showSnack('Không thể lưu set. Vui lòng thử lại.');
      return;
    }

    final exerciseId = _activeExercise.id;
    workout.loggedSetsByExercise[exerciseId] = [
      ...(workout.loggedSetsByExercise[exerciseId] ?? const <LoggedSet>[]),
      loggedSet,
    ];
    widget.onSetLogged?.call();

    // Nếu có feedback thì gọi AI gợi ý cho set tiếp theo
    if (feedbackText.isNotEmpty) {
      _feedbackController.clear();
      _requestWeightAdvice(weight, feedbackText);
    }

    final finishedName = _activeExercise.exercise;
    final finishedExercise = _completedSets + 1 >= _activeExercise.targetSets;

    setState(() {
      _saving = false;
      _completedSets = (_completedSets + 1).clamp(
        0,
        _activeExercise.targetSets,
      );
      if (index + 1 < _activeExercise.targetSets) {
        _setWeights[index + 1] = weight;
        _setReps[index + 1] = reps;
      }
    });

    if (!finishedExercise) {
      _showSnack('Đã lưu set $_completedSets');
      return;
    }

    final next = _nextIncompleteExercise();
    if (next != null) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      setState(() {
        _activeExercise = next;
        _completedSets =
            (workout.loggedSetsByExercise[next.id] ?? const []).length;
        _rebuildSetState(workout, next);
        _advice = null;
        _adviceLoading = false;
      });
    }
    _showSnack(
      next != null
          ? 'Hoàn thành $finishedName — chuyển sang ${next.exercise}'
          : 'Hoàn thành $finishedName — đã xong tất cả bài tập!',
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
      setState(() => _advice = recommendation);
    } catch (error, stackTrace) {
      debugPrint('[WeightAdvice] Request failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (mounted) setState(() => _adviceLoading = false);
    }
  }

  void _applyAdvice() {
    final advice = _advice;
    if (advice == null) return;
    setState(() {
      for (var i = _completedSets; i < _activeExercise.targetSets; i++) {
        _setWeights[i] = advice.suggestedWeight;
      }
      _advice = null;
    });
  }

  void _dismissAdvice() => setState(() => _advice = null);

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: _AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGET: Set Row
// ═══════════════════════════════════════════════════════════════
class _SetRow extends StatelessWidget {
  const _SetRow({
    required this.setIndex,
    required this.weight,
    required this.reps,
    required this.isDone,
    required this.isActive,
    required this.saving,
    required this.onMinusWeight,
    required this.onPlusWeight,
    required this.onMinusReps,
    required this.onPlusReps,
    required this.onComplete,
  });

  final int setIndex;
  final double weight;
  final int reps;
  final bool isDone;
  final bool isActive;
  final bool saving;
  final VoidCallback onMinusWeight;
  final VoidCallback onPlusWeight;
  final VoidCallback onMinusReps;
  final VoidCallback onPlusReps;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final bg = isActive ? _AppColors.surfaceHigh : _AppColors.surface;
    final contentOpacity = isDone ? 0.5 : 1.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: isActive
            ? Border.all(color: _AppColors.accent, width: 1.5)
            : Border.all(color: _AppColors.border, width: 1),
      ),
      child: Opacity(
        opacity: contentOpacity,
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Text(
                '$setIndex',
                style: const TextStyle(
                  color: _AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Stepper(
                display: weight.toStringAsFixed(1),
                isLocked: isDone || saving,
                onMinus: onMinusWeight,
                onPlus: onPlusWeight,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _Stepper(
                display: reps.toString(),
                isLocked: isDone || saving,
                onMinus: onMinusReps,
                onPlus: onPlusReps,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 44,
              height: 44,
              child: isDone
                  ? const Icon(
                      Icons.check_circle,
                      color: _AppColors.success,
                      size: 30,
                    )
                  : isActive
                  ? IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: saving ? null : onComplete,
                      icon: saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _AppColors.accent,
                              ),
                            )
                          : const Icon(
                              Icons.radio_button_unchecked,
                              color: _AppColors.textSecondary,
                              size: 30,
                            ),
                    )
                  : const Icon(
                      Icons.circle_outlined,
                      color: _AppColors.border,
                      size: 30,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGET: Stepper +/-
// ═══════════════════════════════════════════════════════════════
class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.display,
    required this.isLocked,
    required this.onMinus,
    required this.onPlus,
  });

  final String display;
  final bool isLocked;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StepButton(icon: Icons.remove, onTap: isLocked ? null : onMinus),
        Expanded(
          child: Center(
            child: Text(
              display,
              style: const TextStyle(
                color: _AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        _StepButton(icon: Icons.add, onTap: isLocked ? null : onPlus),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: onTap == null ? Colors.transparent : _AppColors.stepperBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null ? _AppColors.border : _AppColors.textPrimary,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGET: Exercise chips row
// ═══════════════════════════════════════════════════════════════
class _ExerciseChipsRow extends StatelessWidget {
  const _ExerciseChipsRow({
    required this.exercises,
    required this.activeId,
    required this.loggedSetsByExercise,
    required this.onTap,
  });

  final List<PlannedExercise> exercises;
  final String activeId;
  final Map<String, List<LoggedSet>> loggedSetsByExercise;
  final ValueChanged<PlannedExercise> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: exercises.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final e = exercises[i];
          final done = (loggedSetsByExercise[e.id] ?? const []).length;
          final completed = done >= e.targetSets;
          final isActive = e.id == activeId;
          return GestureDetector(
            onTap: () => onTap(e),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? _AppColors.accent : _AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? _AppColors.accent : _AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  if (completed) ...[
                    Icon(
                      Icons.check,
                      size: 14,
                      color: isActive ? Colors.white : _AppColors.success,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    e.exercise,
                    style: TextStyle(
                      color: isActive ? Colors.white : _AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$done/${e.targetSets}',
                    style: TextStyle(
                      color: isActive
                          ? Colors.white70
                          : _AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGET: Info pill
// ═══════════════════════════════════════════════════════════════
class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.text, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color ?? _AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGET: Advice inline bar
// ═══════════════════════════════════════════════════════════════
class _AdviceInlineBar extends StatelessWidget {
  const _AdviceInlineBar({
    required this.advice,
    required this.onApply,
    required this.onDismiss,
  });

  final Recommendation advice;
  final VoidCallback onApply;
  final VoidCallback onDismiss;

  Color _color(RecommendationAction action) {
    return switch (action) {
      RecommendationAction.INCREASE_WEIGHT => _AppColors.success,
      RecommendationAction.DECREASE_WEIGHT => _AppColors.danger,
      RecommendationAction.REST => const Color(0xFF2563EB),
      RecommendationAction.KEEP_WEIGHT => _AppColors.purple,
    };
  }

  String _label(RecommendationAction action) {
    return switch (action) {
      RecommendationAction.INCREASE_WEIGHT => '↑ Tăng',
      RecommendationAction.DECREASE_WEIGHT => '↓ Giảm',
      RecommendationAction.REST => '⏸ Nghỉ',
      RecommendationAction.KEEP_WEIGHT => '✓ Giữ',
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(advice.action);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${_label(advice.action)} → ${advice.suggestedWeight.toStringAsFixed(1)} kg',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: onApply,
            style: TextButton.styleFrom(
              foregroundColor: color,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 30),
            ),
            child: const Text('Áp dụng', style: TextStyle(fontSize: 12)),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: Icon(Icons.close, size: 16, color: color),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGET: Feedback Input
// ═══════════════════════════════════════════════════════════════
class _FeedbackInput extends StatelessWidget {
  const _FeedbackInput({required this.controller, required this.onSubmit});
  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cảm giác thế nào?',
            style: TextStyle(
              color: _AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: _AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Ví dụ: Nặng quá, hụt hơi...',
                    hintStyle: const TextStyle(color: _AppColors.textSecondary),
                    filled: true,
                    fillColor: _AppColors.bg,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => onSubmit(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onSubmit,
                icon: const Icon(Icons.send, color: _AppColors.accent),
                style: IconButton.styleFrom(
                  backgroundColor: _AppColors.accent.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Gửi phản hồi để AI gợi ý mức tạ cho set tiếp theo.',
            style: TextStyle(color: _AppColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGET: Completion banner
// ═══════════════════════════════════════════════════════════════
class _CompletionBanner extends StatelessWidget {
  const _CompletionBanner();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: _AppColors.success.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _AppColors.success.withValues(alpha: 0.3)),
    ),
    child: Row(
      children: const [
        Icon(Icons.check_circle, color: _AppColors.success, size: 32),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hoàn thành tất cả!',
                style: TextStyle(
                  color: _AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Bạn đã xong tất cả bài tập hôm nay.',
                style: TextStyle(color: _AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
// STATE WIDGETS
// ═══════════════════════════════════════════════════════════════
class _StateScaffold extends StatelessWidget {
  const _StateScaffold({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _AppColors.bg,
    appBar: AppBar(
      backgroundColor: _AppColors.surface,
      elevation: 0,
      title: Text(
        title,
        style: const TextStyle(
          color: _AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      iconTheme: const IconThemeData(color: _AppColors.textPrimary),
    ),
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
          Icon(icon, size: 44, color: _AppColors.danger),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: _AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _AppColors.textSecondary),
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
