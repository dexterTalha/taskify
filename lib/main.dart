import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/database/hive_config.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/task_repository_impl.dart';
import 'presentation/providers/task_provider.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive database
  await HiveConfig.init();

  // Run the app
  runApp(const TaskifyApp());
}

class TaskifyApp extends StatelessWidget {
  const TaskifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repository provider
        Provider<TaskRepositoryImpl>(create: (_) => TaskRepositoryImpl()),

        // Task provider
        ChangeNotifierProvider<TaskProvider>(
          create: (context) => TaskProvider(context.read<TaskRepositoryImpl>()),
        ),
      ],
      child: MaterialApp(
        title: 'Taskify',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        themeMode: ThemeMode.light,
      ),
    );
  }
}
