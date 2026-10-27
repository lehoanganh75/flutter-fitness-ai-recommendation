import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/app_dependencies.dart' show kLocalUserId;
import '../../domain/models/daily_suggestion.dart';
import '../../services/daily_suggestion_service.dart';
import '../../services/workout_service.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

// 🆕 Thêm import để mở TodayWorkoutScreen
import 'today_workout_screen.dart';

// ─────────────────────────────────────────────────────────────
// COLORS (Đồng bộ với TodayWorkoutScreen)
// ─────────────────────────────────────────────────────────────
class _AppColors {
  static const bg = Color(0xFFF8F9FA); // Nền xám rất nhạt
  static const surface = Colors.white; // Card trắng
  static const surfaceHigh = Color(0xFFF1F3F5); // Xám nhạt cho icon bg
  static const textPrimary = Color(0xFF1F2937); // Chữ đậm
  static const textSecondary = Color(0xFF6B7280); // Chữ xám
  static const border = Color(0xFFE5E7EB); // Viền
  static const accent = Color(0xFF16A34A); // Xanh lá (chủ đạo)
  static const danger = Color(0xFFDC2626);
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.workoutService,
    this.dailySuggestionService,
    this.userId = kLocalUserId,
    this.now,
    this.onStartWorkout,
    this.onOpenPlan,
    this.refreshToken = 0,
    this.suggestionRefreshToken = 0,
    this.logSetService,
    this.weightAdviceService,
  });

  final WorkoutService? workoutService;
  final DailySuggestionService? dailySuggestionService;
  final String userId;
  final DateTime? now;
  final VoidCallback? onStartWorkout;
  final VoidCallback? onOpenPlan;
  final int refreshToken;
  final int suggestionRefreshToken;

  final dynamic logSetService;
  final dynamic weightAdviceService;

  @override
  Widget build(BuildContext context) {
    final today = now ?? DateTime.now();

    if (workoutService == null || dailySuggestionService == null) {
      return const Scaffold(body: Center(child: Text('Chưa cấu hình dịch vụ')));
    }

    return BlocProvider(
      create: (context) => HomeCubit(
        workoutService: workoutService!,
        suggestionService: dailySuggestionService!,
        userId: userId,
      )..loadHomeData(today),
      child: _HomeView(
        today: today,
        onStartWorkout: onStartWorkout,
        onOpenPlan: onOpenPlan,
        userId: userId,
        workoutService: workoutService!,
        logSetService: logSetService,
        weightAdviceService: weightAdviceService,
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView({
    required this.today,
    this.onStartWorkout,
    this.onOpenPlan,
    required this.userId,
    required this.workoutService,
    this.logSetService,
    this.weightAdviceService,
  });

  final DateTime today;
  final VoidCallback? onStartWorkout;
  final VoidCallback? onOpenPlan;
  final String userId;
  final WorkoutService workoutService;
  final dynamic logSetService;
  final dynamic weightAdviceService;

  void _openWorkout(BuildContext context) {
    if (onStartWorkout != null) {
      onStartWorkout!();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TodayWorkoutScreen(
          workoutService: workoutService,
          logSetService: logSetService,
          weightAdviceService: weightAdviceService,
          userId: userId,
          dayOfWeek: today.weekday,
          onSetLogged: () {
            context.read<HomeCubit>().loadHomeData(today);
          },
        ),
      ),
    );
  }

  void _confirmApply(BuildContext context, DateTime today) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Áp dụng gợi ý AI?',
          style: TextStyle(color: _AppColors.textPrimary),
        ),
        content: const Text(
          'Giáo án hiện tại của hôm nay sẽ bị GHI ĐÈ bằng gợi ý AI. '
          'Các bài tập cũ (kể cả đã tập) sẽ bị xoá khỏi giáo án.',
          style: TextStyle(color: _AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Huỷ',
              style: TextStyle(color: _AppColors.textSecondary),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<HomeCubit>().applySuggestionToToday(today);
            },
            style: FilledButton.styleFrom(backgroundColor: _AppColors.danger),
            child: const Text('Ghi đè ngay'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.bg,
      appBar: AppBar(
        title: const Text(
          'Hôm nay',
          style: TextStyle(
            color: _AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: _AppColors.bg,
        elevation: 0,
        centerTitle: false,
      ),
      body: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state is HomeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: _AppColors.textPrimary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(
              child: CircularProgressIndicator(color: _AppColors.accent),
            );
          }

          if (state is HomeError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.message,
                      style: const TextStyle(color: _AppColors.textPrimary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<HomeCubit>().loadHomeData(today),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _AppColors.accent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          final loadedState = state as HomeLoaded;
          final suggestion = loadedState.suggestion;
          final workout = loadedState.workout;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 🆕 Card Gợi ý AI
              _SuggestionCard(
                suggestion: suggestion,
                loading: loadedState.isSuggestionLoading,
                applying: loadedState.isApplying,
                onRefresh: () =>
                    context.read<HomeCubit>().refreshSuggestion(today),
                onApplyToToday: () => _confirmApply(context, today),
              ),
              const SizedBox(height: 16),

              // 🆕 Card Buổi tập hôm nay / Ngày nghỉ
              if (workout == null)
                _EmptyWorkoutCard(onOpenPlan: onOpenPlan)
              else
                _TodayWorkoutCard(
                  workout: workout,
                  onStartWorkout: () => _openWorkout(context),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGET: Card Buổi tập hôm nay
// ═══════════════════════════════════════════════════════════════
class _TodayWorkoutCard extends StatelessWidget {
  const _TodayWorkoutCard({
    required this.workout,
    required this.onStartWorkout,
  });

  final dynamic workout;
  final VoidCallback onStartWorkout;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: _AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.plan.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${workout.exercises.length} bài · ${workout.muscleGroups.join(", ")}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: _AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: onStartWorkout,
              style: FilledButton.styleFrom(
                backgroundColor: _AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Bắt đầu tập',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGET: Card Ngày nghỉ
// ═══════════════════════════════════════════════════════════════
class _EmptyWorkoutCard extends StatelessWidget {
  const _EmptyWorkoutCard({this.onOpenPlan});
  final VoidCallback? onOpenPlan;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AppColors.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.bedtime_outlined,
                color: _AppColors.textSecondary,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Hôm nay là ngày nghỉ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Không có buổi tập nào được lên kế hoạch cho hôm nay.',
            style: TextStyle(color: _AppColors.textSecondary),
          ),
          if (onOpenPlan != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onOpenPlan,
              style: OutlinedButton.styleFrom(
                foregroundColor: _AppColors.accent,
                side: const BorderSide(color: _AppColors.accent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Tạo hoặc chọn giáo án'),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGET: Card Gợi ý AI
// ═══════════════════════════════════════════════════════════════
class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.suggestion,
    required this.loading,
    required this.applying,
    required this.onRefresh,
    required this.onApplyToToday,
  });

  final DailySuggestion? suggestion;
  final bool loading;
  final bool applying;
  final VoidCallback onRefresh;
  final VoidCallback onApplyToToday;

  String _label(SuggestionSource s) => switch (s) {
    SuggestionSource.ai => 'AI gợi ý',
    SuggestionSource.history => 'Theo lịch sử tập',
    SuggestionSource.warmUp => 'Khởi động',
  };

  @override
  Widget build(BuildContext context) {
    final s = suggestion;

    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 24,
                  color: _AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gợi ý hôm nay',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _AppColors.textPrimary,
                      ),
                    ),
                    if (s != null)
                      Text(
                        _label(s.source),
                        style: const TextStyle(
                          color: _AppColors.accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Làm mới',
                onPressed: loading ? null : onRefresh,
                icon: const Icon(
                  Icons.refresh,
                  color: _AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(color: _AppColors.accent),
              ),
            )
          else if (s == null)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                'Chưa có gợi ý.',
                style: TextStyle(color: _AppColors.textSecondary),
              ),
            )
          else ...[
            const SizedBox(height: 16),
            Text(
              s.summary,
              style: const TextStyle(
                color: _AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 24, color: _AppColors.border),
            for (var i = 0; i < s.exercises.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _AppColors.surfaceHigh,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: _AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${s.exercises[i].sets} hiệp x ${s.exercises[i].reps} lần · ${s.exercises[i].weight.toStringAsFixed(0)} kg',
                            style: const TextStyle(
                              color: _AppColors.accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          if (s.exercises[i].reason.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              s.exercises[i].reason,
                              style: const TextStyle(
                                color: _AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Cảnh báo Ghi đè
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Áp dụng gợi ý này sẽ thay thế toàn bộ bài tập hôm nay.',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Nút Áp dụng
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: (loading || applying) ? null : onApplyToToday,
                style: FilledButton.styleFrom(
                  backgroundColor: _AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: applying
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.today),
                label: Text(
                  applying ? 'Đang áp dụng...' : 'Áp dụng và Ghi đè',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
