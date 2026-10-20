import 'package:flutter/material.dart';
import '../../services/stats_service.dart';

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
        appBar: AppBar(
          title: const Text('Tiến độ'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_stats == null || _stats!.totalWorkouts == 0) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tiến độ'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.insights_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có dữ liệu tập luyện',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Hoàn thành một số bài tập để xem thống kê tại đây',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final stats = _stats!;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiến độ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bộ chọn khoảng ngày - sắp ra mắt')),
              );
            },
            tooltip: 'Chọn khoảng ngày',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
                  title: 'Total Time',
                  value: '${(stats.totalTime / 60).toStringAsFixed(0)}h',
                  subtitle: 'Tháng này',
                  color: Colors.green,
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
          const SizedBox(height: 24),

          // Weekly Activity Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoạt động hàng tuần',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _WeeklyChart(data: stats.weeklyActivity),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Personal Records
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kỷ lục cá nhân',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Xem tất cả kỷ lục - sắp ra mắt')),
                          );
                        },
                        child: const Text('Xem tất cả'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (stats.personalRecords.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Hoàn thành tập luyện để đặt kỷ lục cá nhân',
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ...stats.personalRecords.asMap().entries.map((entry) {
                      final index = entry.key;
                      final pr = entry.value;
                      final icons = [
                        Icons.emoji_events,
                        Icons.star,
                        Icons.military_tech
                      ];
                      final colors = [Colors.amber, Colors.blue, Colors.green];
                      
                      return Column(
                        children: [
                          if (index > 0) const Divider(height: 24),
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
                    }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Muscle Group Distribution
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nhóm cơ',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '30 ngày qua',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 16),
                  if (stats.muscleGroupDistribution.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Hoàn thành tập luyện để xem phân phối nhóm cơ',
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ...stats.muscleGroupDistribution.entries.map((entry) {
                      final colors = {
                        'Chest': Colors.red,
                        'Back': Colors.blue,
                        'Legs': Colors.green,
                        'Quads': Colors.green,
                        'Hamstrings': Colors.green,
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
                    }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.data});

  final List<double> data;
  
  @override
  Widget build(BuildContext context) {
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final isToday = index == DateTime.now().weekday - 1;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 150 * data[index],
                    decoration: BoxDecoration(
                      color: isToday
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
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
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$weight × $reps',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Text(
          date,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

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
                fontSize: 14,
              ),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
