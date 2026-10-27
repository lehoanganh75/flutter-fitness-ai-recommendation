import 'package:fitness_recommendation/src/services/weight_advice_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

// Đồng bộ màu với HomeScreen & TodayWorkoutScreen
class _AppColors {
  static const bg = Color(0xFFF8F9FA);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF1F2937);
  static const accent = Color(0xFF16A34A);
}

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.workoutService,
    this.logSetService,
    this.workoutRepository,
    this.statsService,
    this.dailySuggestionService,
    this.weightAdviceService,
    this.userId = kLocalUserId,
    this.showTodayWorkoutInitially = false,
  });

  final WorkoutService? workoutService;
  final LogSetService? logSetService;
  final WorkoutRepository? workoutRepository;
  final StatsService? statsService;
  final DailySuggestionService? dailySuggestionService;
  final WeightAdviceService? weightAdviceService;
  final String userId;
  final bool showTodayWorkoutInitially;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  bool _showTodayWorkout = false;

  int _workoutKey = 0;
  int _homeRefresh = 0;
  int _suggestionRefresh = 0;
  int _statsVersion = 0;
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
    // Đảm bảo thanh trạng thái (status bar) và thanh điều hướng (nav bar)
    // có icon màu tối cho hợp nền sáng
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: _AppColors.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: _AppColors.bg,
      // 🆕 Cho phép Scaffold mở rộng xuống dưới đáy (khi ẩn bottom nav)
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Màn hình chính (các Tab)
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

          // Màn hình Tập luyện
          Offstage(
            offstage: !_showTodayWorkout,
            child: TodayWorkoutScreen(
              key: ValueKey('workout-$_workoutKey'),
              workoutService: widget.workoutService,
              logSetService: widget.logSetService,
              weightAdviceService: widget.weightAdviceService,
              userId: widget.userId,
              onSetLogged: () {
                _hasNewLoggedSets = true;
              },
              onClose: () {
                _selectTab(0);
              },
            ),
          ),
        ],
      ),

      // 🆕 Ẩn Bottom Nav khi đang tập
      bottomNavigationBar: _showTodayWorkout
          ? null
          : Container(
              decoration: BoxDecoration(
                color: _AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: NavigationBar(
                backgroundColor: _AppColors.surface,
                elevation: 0,
                selectedIndex: _selectedIndex,
                onDestinationSelected: _selectTab,
                indicatorColor: _AppColors.accent.withValues(alpha: 0.15),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(
                      Icons.home_outlined,
                      color: _AppColors.textPrimary,
                    ),
                    selectedIcon: Icon(Icons.home, color: _AppColors.accent),
                    label: 'Trang chủ',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.calendar_month_outlined,
                      color: _AppColors.textPrimary,
                    ),
                    selectedIcon: Icon(
                      Icons.calendar_month,
                      color: _AppColors.accent,
                    ),
                    label: 'Giáo án',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.insights_outlined,
                      color: _AppColors.textPrimary,
                    ),
                    selectedIcon: Icon(
                      Icons.insights,
                      color: _AppColors.accent,
                    ),
                    label: 'Tiến độ',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.fitness_center_outlined,
                      color: _AppColors.textPrimary,
                    ),
                    selectedIcon: Icon(
                      Icons.fitness_center,
                      color: _AppColors.accent,
                    ),
                    label: 'Bài tập',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.settings_outlined,
                      color: _AppColors.textPrimary,
                    ),
                    selectedIcon: Icon(
                      Icons.settings,
                      color: _AppColors.accent,
                    ),
                    label: 'Cài đặt',
                  ),
                ],
              ),
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
        style: TextStyle(
          color: _AppColors.accent,
          fontWeight: FontWeight.bold,
          fontSize: 14,
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
      leading: Icon(icon, color: _AppColors.textPrimary),
      title: Text(
        title,
        style: const TextStyle(
          color: _AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(subtitle, style: const TextStyle(color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: _AppColors.textPrimary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.bg,
      appBar: AppBar(
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            color: _AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: _AppColors.bg,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        children: [
          _sectionTitle(context, 'Hồ sơ'),
          _soonTile(
            context,
            icon: Icons.person_outline,
            title: 'Hồ sơ',
            subtitle: 'Quản lý thông tin cá nhân',
            message: 'Màn hình hồ sơ — sắp ra mắt',
          ),
          const Divider(color: _AppColors.surface),

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
          const Divider(color: _AppColors.surface),

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
          const Divider(color: _AppColors.surface),

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
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
