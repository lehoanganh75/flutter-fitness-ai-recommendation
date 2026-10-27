import 'package:flutter/material.dart';

import '../../services/stats_service.dart';

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

class StatsScreen extends StatefulWidget {
  const StatsScreen({
    super.key,
    this.statsService,
    this.userId = 'sample-user',
  });

  final StatsService? statsService;
  final String userId;

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  WorkoutStats? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (widget.statsService == null) {
      setState(() {
        _stats = WorkoutStats.empty();
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);

    try {
      final stats = await widget.statsService!.getStats(widget.userId);
      if (mounted) {
        setState(() {
          _stats = stats;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _stats = WorkoutStats.empty();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: _AppColors.bg,
        appBar: AppBar(
          backgroundColor: _AppColors.bg,
          elevation: 0,
          title: const Text(
            'Tiến độ',
            style: TextStyle(
              color: _AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: _AppColors.accent),
        ),
      );
    }

    if (_stats == null || _stats!.totalWorkouts == 0) {
      return Scaffold(
        backgroundColor: _AppColors.bg,
        appBar: AppBar(
          backgroundColor: _AppColors.bg,
          elevation: 0,
          title: const Text(
            'Tiến độ',
            style: TextStyle(
              color: _AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: _AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _AppColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.insights_outlined,
                    size: 56,
                    color: _AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có dữ liệu tập luyện',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hoàn thành một số bài tập để xem thống kê tại đây',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final stats = _stats!;

    return Scaffold(
      backgroundColor: _AppColors.bg,
      appBar: AppBar(
        backgroundColor: _AppColors.bg,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Tiến độ',
          style: TextStyle(
            color: _AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_today_outlined,
              color: _AppColors.textPrimary,
            ),
            onPressed: () {
              _showSnack('Bộ chọn khoảng ngày - sắp ra mắt');
            },
            tooltip: 'Chọn khoảng ngày',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.fitness_center,
                  title: 'Tổng tập luyện',
                  value: '${stats.totalWorkouts}',
                  subtitle: 'Tháng này',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department,
                  title: 'Chuỗi tập',
                  value: '${stats.streak}',
                  subtitle: 'Ngày',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.timer_outlined,
                  title: 'Tổng thời gian',
                  value: '${(stats.totalTime / 60).toStringAsFixed(0)}h',
                  subtitle: 'Tháng này',
                  color: _AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.trending_up,
                  title: 'Khối lượng',
                  value: '${(stats.totalVolume / 1000).toStringAsFixed(0)}k',
                  subtitle: 'kg đã nâng',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Weekly Activity Chart
          _SectionCard(
            title: 'Hoạt động hàng tuần',
            child: _WeeklyChart(data: stats.weeklyActivity),
          ),
          const SizedBox(height: 16),

          // Personal Records
          _SectionCard(
            title: 'Kỷ lục cá nhân',
            action: TextButton(
              onPressed: () => _showSnack('Xem tất cả kỷ lục - sắp ra mắt'),
              child: const Text(
                'Xem tất cả',
                style: TextStyle(
                  color: _AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            child: stats.personalRecords.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Hoàn thành tập luyện để đặt kỷ lục cá nhân',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _AppColors.textSecondary),
                    ),
                  )
                : Column(
                    children: stats.personalRecords.asMap().entries.map((
                      entry,
                    ) {
                      final index = entry.key;
                      final pr = entry.value;
                      final icons = [
                        Icons.emoji_events,
                        Icons.star,
                        Icons.military_tech,
                      ];
                      final colors = [
                        Colors.amber,
                        Colors.blue,
                        _AppColors.accent,
                      ];
                      return Column(
                        children: [
                          if (index > 0)
                            const Divider(height: 24, color: _AppColors.border),
                          _PersonalRecordTile(
                            exercise: pr.exercise,
                            weight: '${pr.weight.toStringAsFixed(1)} kg',
                            reps: '${pr.reps} lần',
                            date: _formatDate(pr.date),
                            icon: icons[index % 3],
                            color: colors[index % 3],
                          ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 16),

          // Muscle Group Distribution
          _SectionCard(
            title: 'Nhóm cơ',
            subtitle: '30 ngày qua',
            child: stats.muscleGroupDistribution.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Hoàn thành tập luyện để xem phân phối nhóm cơ',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _AppColors.textSecondary),
                    ),
                  )
                : Column(
                    children: stats.muscleGroupDistribution.entries.map((
                      entry,
                    ) {
                      final colors = {
                        'Chest': Colors.red,
                        'Back': Colors.blue,
                        'Legs': _AppColors.accent,
                        'Quads': _AppColors.accent,
                        'Hamstrings': _AppColors.accent,
                        'Shoulders': Colors.orange,
                        'Arms': Colors.purple,
                        'Triceps': Colors.purple,
                        'Biceps': Colors.purple,
                        'Core': Colors.amber,
                      };
                      return Column(
                        children: [
                          _MuscleGroupBar(
                            label: entry.key,
                            percentage: entry.value,
                            color: colors[entry.key] ?? Colors.grey,
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return 'Hôm nay';
    if (diff == 1) return 'Hôm qua';
    if (diff < 7) return '$diff ngày trước';
    if (diff < 30) return '${(diff / 7).floor()} tuần trước';
    return '${(diff / 30).floor()} tháng trước';
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGET: Stat Card
// ═══════════════════════════════════════════════════════════════
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _AppColors.textPrimary,
            ),
          ),
          Text(
            subtitle,
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

// ═══════════════════════════════════════════════════════════════
// WIDGET: Section Card (Container chuẩn)
// ═══════════════════════════════════════════════════════════════
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.subtitle,
    this.action,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGET: Weekly Chart
// ═══════════════════════════════════════════════════════════════
class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.data});

  final List<double> data;

  @override
  Widget build(BuildContext context) {
    final labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final isToday = index == DateTime.now().weekday - 1;
          // Giới hạn chiều cao tối thiểu 4px để tránh cột bị ẩn
          final height = (140 * data[index]).clamp(4.0, 140.0);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: height,
                    decoration: BoxDecoration(
                      color: isToday
                          ? _AppColors.accent
                          : _AppColors.accent.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: _AppColors.textSecondary,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGET: Personal Record Tile
// ═══════════════════════════════════════════════════════════════
class _PersonalRecordTile extends StatelessWidget {
  const _PersonalRecordTile({
    required this.exercise,
    required this.weight,
    required this.reps,
    required this.date,
    required this.icon,
    required this.color,
  });

  final String exercise;
  final String weight;
  final String reps;
  final String date;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: _AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$weight × $reps',
                style: const TextStyle(
                  color: _AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Text(
          date,
          style: const TextStyle(color: _AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGET: Muscle Group Bar
// ═══════════════════════════════════════════════════════════════
class _MuscleGroupBar extends StatelessWidget {
  const _MuscleGroupBar({
    required this.label,
    required this.percentage,
    required this.color,
  });

  final String label;
  final double percentage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: _AppColors.textPrimary,
              ),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: const TextStyle(
                color: _AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: _AppColors.surfaceHigh,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
