import 'package:flutter/material.dart';

import 'src/app/app_dependencies.dart';
import 'src/presentation/screens/today_workout_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await AppDependencies.create();
  runApp(FitnessRecommendationApp(dependencies: dependencies));
}

class FitnessRecommendationApp extends StatelessWidget {
  const FitnessRecommendationApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFDC2626);

    return MaterialApp(
      title: 'Fitness Recommendation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: primary,
              brightness: Brightness.light,
            ).copyWith(
              primary: primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF1F2937),
            ),
        scaffoldBackgroundColor: const Color(0xFFFEF2F2),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: TodayWorkoutScreen(
        workoutService: dependencies.workoutService,
        logSetService: dependencies.logSetService,
        userId: 'sample-user',
      ),
    );
  }
}
