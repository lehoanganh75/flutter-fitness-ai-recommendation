import 'package:flutter/material.dart';

import '../../app/app_dependencies.dart' show kLocalUserId;
import '../../domain/repositories/workout_repository.dart';
import '../../services/daily_suggestion_service.dart';
import '../../services/log_set_service.dart';
import '../../services/workout_service.dart';
import '../../services/stats_service.dart';
import 'home_screen.dart';
import 'today_workout_screen.dart';
import 'plan_screen.dart';
import 'stats_screen.dart';
import 'exercises_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.workoutService,
    this.logSetService,
    this.workoutRepository,
    this.statsService,
    this.dailySuggestionService,
    this.userId = kLocalUserId,
    this.showTodayWorkoutInitially = false,
  });

  final WorkoutService? workoutService;
  final LogSetService? logSetService;
  final WorkoutRepository? workoutRepository;
  final StatsService? statsService;
  final DailySuggestionService? dailySuggestionService;
  final String userId;
  final bool showTodayWorkoutInitially;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  bool _showTodayWorkout = false;

  /// Đổi key để màn tập được dựng lại và tải dữ liệu mới mỗi lần bấm "Bắt đầu tập"
  /// (vd: vừa tạo giáo án xong thì màn tập phải thấy giáo án đó).
  int _workoutKey = 0;

  /// Tăng để Trang chủ tải lại buổi tập hôm nay (rẻ, chỉ đọc DB cục bộ).
  int _homeRefresh = 0;

  /// Tăng để AI tạo lại gợi ý. Chỉ tăng khi có set mới, để không tốn request.
  int _suggestionRefresh = 0;

  /// Đổi key để tab Tiến độ tính lại số liệu.
  int _statsVersion = 0;

  /// True nếu người dùng vừa ghi set mới kể từ lần làm mới trước.
  bool _hasNewLoggedSets = false;

  @override
  void initState() {
    super.initState();
    _showTodayWorkout = widget.showTodayWorkoutInitially;
  }

  void _openWorkout() {
    setState(() {
      _workoutKey++;
      _showTodayWorkout = true;
    });
  }

  void _selectTab(int index) {
    setState(() {
      final leavingWorkout = _showTodayWorkout;
      if (index == 0 || leavingWorkout) _homeRefresh++;
      if (_hasNewLoggedSets) {
        _suggestionRefresh++;
        _statsVersion++;
        _hasNewLoggedSets = false;
      }
      _selectedIndex = index;
      _showTodayWorkout = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Offstage(
            offstage: _showTodayWorkout,
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                HomeScreen(
                  workoutService: widget.workoutService,
                  dailySuggestionService: widget.dailySuggestionService,
                  userId: widget.userId,
                  refreshToken: _homeRefresh,
                  suggestionRefreshToken: _suggestionRefresh,
                  onStartWorkout: _openWorkout,
                  onOpenPlan: () => _selectTab(1),
                ),
                PlanScreen(
                  workoutService: widget.workoutService,
                  repository: widget.workoutRepository,
                  userId: widget.userId,
                ),
                StatsScreen(
                  key: ValueKey('stats-$_statsVersion'),
                  statsService: widget.statsService,
                  userId: widget.userId,
                ),
                const ExercisesScreen(),
                const _SettingsScreen(),
              ],
            ),
          ),
          Offstage(
            offstage: !_showTodayWorkout,
            child: TodayWorkoutScreen(
              key: ValueKey('workout-$_workoutKey'),
              workoutService: widget.workoutService,
              logSetService: widget.logSetService,
              userId: widget.userId,
              onSetLogged: () => _hasNewLoggedSets = true,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Giáo án',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Tiến độ',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Bài tập',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }
}

class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen();

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _soonTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required String message,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: [
          // Profile Section
          _sectionTitle(context, 'Hồ sơ'),
          _soonTile(
            context,
            icon: Icons.person_outline,
            title: 'Hồ sơ',
            subtitle: 'Quản lý thông tin cá nhân',
            message: 'Màn hình hồ sơ — sắp ra mắt',
          ),
          const Divider(),

          // Preferences Section
          _sectionTitle(context, 'Tùy chọn'),
          _soonTile(
            context,
            icon: Icons.timer_outlined,
            title: 'Thời gian nghỉ mặc định',
            subtitle: '90 giây',
            message: 'Cài đặt thời gian nghỉ — sắp ra mắt',
          ),
          _soonTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Thông báo',
            subtitle: 'Quản lý nhắc lịch tập',
            message: 'Cài đặt thông báo — sắp ra mắt',
          ),
          _soonTile(
            context,
            icon: Icons.dark_mode_outlined,
            title: 'Giao diện',
            subtitle: 'Chế độ sáng',
            message: 'Cài đặt giao diện — sắp ra mắt',
          ),
          const Divider(),

          // Data Section
          _sectionTitle(context, 'Dữ liệu'),
          _soonTile(
            context,
            icon: Icons.backup_outlined,
            title: 'Sao lưu & Khôi phục',
            subtitle: 'Sao lưu dữ liệu tập luyện',
            message: 'Sao lưu — sắp ra mắt',
          ),
          _soonTile(
            context,
            icon: Icons.file_download_outlined,
            title: 'Xuất dữ liệu',
            subtitle: 'Tải lịch sử tập luyện',
            message: 'Xuất dữ liệu — sắp ra mắt',
          ),
          const Divider(),

          // About Section
          _sectionTitle(context, 'Giới thiệu'),
          _soonTile(
            context,
            icon: Icons.info_outline,
            title: 'Giới thiệu',
            subtitle: 'Phiên bản 1.0.0',
            message: 'Màn hình giới thiệu — sắp ra mắt',
          ),
          _soonTile(
            context,
            icon: Icons.help_outline,
            title: 'Trợ giúp & Hỗ trợ',
            subtitle: 'Nhận trợ giúp và liên hệ hỗ trợ',
            message: 'Trợ giúp — sắp ra mắt',
          ),
          _soonTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Chính sách riêng tư',
            message: 'Chính sách riêng tư — sắp ra mắt',
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
