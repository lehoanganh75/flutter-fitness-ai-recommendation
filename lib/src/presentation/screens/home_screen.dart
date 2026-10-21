import 'package:flutter/material.dart';

import '../../app/app_dependencies.dart' show kLocalUserId;
import '../../domain/models/daily_suggestion.dart';
import '../../domain/models/today_workout.dart';
import '../../services/daily_suggestion_service.dart';
import '../../services/workout_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.workout,
    this.workoutService,
    this.dailySuggestionService,
    this.userId = kLocalUserId,
    this.now,
    this.isLoading = false,
    this.errorMessage,
    this.onStartWorkout,
    this.onOpenPlan,
    this.refreshToken = 0,
    this.suggestionRefreshToken = 0,
  });

  final TodayWorkout? workout;
  final WorkoutService? workoutService;
  final DailySuggestionService? dailySuggestionService;
  final String userId;
  final DateTime? now;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onStartWorkout;

  /// Chuyển sang tab Giáo án khi chưa có buổi tập nào.
  final VoidCallback? onOpenPlan;

  /// Đổi giá trị này để buộc Trang chủ tải lại dữ liệu
  /// (ví dụ sau khi người dùng vừa tập xong).
  final int refreshToken;

  /// Đổi giá trị này để buộc AI tạo lại gợi ý (chỉ nên đổi sau khi tập xong).
  final int suggestionRefreshToken;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TodayWorkout? _workout;
  late bool _loading;
  String? _error;

  DailySuggestion? _suggestion;
  bool _suggestionLoading = false;

  DateTime get _today => widget.now ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _workout = widget.workout;
    _loading = widget.isLoading;
    _error = widget.errorMessage;
    if (_workout == null && widget.workoutService != null && !_loading) {
      _loadWorkout();
    }
    if (widget.dailySuggestionService != null) {
      _loadSuggestion();
    }
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshToken != oldWidget.refreshToken &&
        widget.workoutService != null) {
      _loadWorkout(silent: true);
    }
    if (widget.suggestionRefreshToken != oldWidget.suggestionRefreshToken &&
        widget.dailySuggestionService != null) {
      _loadSuggestion(force: true);
    }
  }

  Future<void> _loadSuggestion({bool force = false}) async {
    final service = widget.dailySuggestionService;
    if (service == null) return;

    setState(() => _suggestionLoading = true);
    try {
      final suggestion = await service.suggest(
        userId: widget.userId,
        now: _today,
        forceRefresh: force,
      );
      if (mounted) {
        setState(() {
          _suggestion = suggestion;
          _suggestionLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Load suggestion failed: $e');
      if (mounted) setState(() => _suggestionLoading = false);
    }
  }

  Future<void> _loadWorkout({bool silent = false}) async {
    final service = widget.workoutService;
    if (service == null) return;

    // silent: tải lại ngầm, không hiện vòng xoay (tránh nháy khi đổi tab).
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final workout = await service.loadTodayWorkout(
        userId: widget.userId,
        dayOfWeek: _today.weekday,
      );
      if (mounted) {
        setState(() {
          _workout = workout;
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      debugPrint('Load workout failed: $e');
      if (mounted) {
        setState(() {
          _error = 'Không tải được buổi tập hôm nay. Vui lòng thử lại.';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hôm nay')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.dailySuggestionService != null) ...[
            _SuggestionCard(
              suggestion: _suggestion,
              loading: _suggestionLoading,
              onRefresh: () => _loadSuggestion(force: true),
            ),
            const SizedBox(height: 12),
          ],
          // Buổi tập hôm nay
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _loadWorkout,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          else if (_workout == null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hôm nay là ngày nghỉ',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Không có buổi tập nào được lên kế hoạch cho hôm nay.',
                    ),
                    if (widget.onOpenPlan != null) ...[
                      const SizedBox(height: 12),
                      FilledButton.tonal(
                        onPressed: widget.onOpenPlan,
                        child: const Text('Tạo hoặc chọn giáo án'),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _workout!.plan.title,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_workout!.exercises.length} bài · '
                      '${_workout!.muscleGroups.join(", ")}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    if (widget.onStartWorkout != null)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: widget.onStartWorkout,
                          icon: const Icon(Icons.fitness_center),
                          label: const Text('Bắt đầu tập'),
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
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.suggestion,
    required this.loading,
    required this.onRefresh,
  });

  final DailySuggestion? suggestion;
  final bool loading;
  final VoidCallback onRefresh;

  String _label(SuggestionSource s) => switch (s) {
    SuggestionSource.ai => 'AI gợi ý',
    SuggestionSource.history => 'Theo lịch sử tập',
    SuggestionSource.warmUp => 'Khởi động',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final tint = primary.withValues(alpha: 0.1);
    final s = suggestion;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hàng tiêu đề: biểu tượng | tiêu đề + nguồn (co giãn) | làm mới
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: tint,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.auto_awesome, size: 20, color: primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gợi ý hôm nay',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (s != null)
                        Text(
                          _label(s.source),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: primary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Làm mới',
                  onPressed: loading ? null : onRefresh,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            if (loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (s == null)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('Chưa có gợi ý.'),
              )
            else ...[
              const SizedBox(height: 12),
              Text(s.summary, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              const Divider(height: 24),
              for (var i = 0; i < s.exercises.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: tint,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${i + 1}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.exercises[i].name,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (s.exercises[i].reason.isNotEmpty)
                              Text(
                                s.exercises[i].reason,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
