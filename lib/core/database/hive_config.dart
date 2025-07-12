import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/task_model.dart';

class HiveConfig {
  static const String taskBoxName = 'tasks';

  /// Initialize Hive database
  static Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskModelAdapter());
    }

    // Open boxes
    await Hive.openBox<TaskModel>(taskBoxName);
  }

  /// Get tasks box
  static Box<TaskModel> get taskBox => Hive.box<TaskModel>(taskBoxName);

  /// Close all boxes
  static Future<void> close() async {
    await Hive.close();
  }

  /// Clear all data (for testing purposes)
  static Future<void> clearAllData() async {
    await taskBox.clear();
  }
}
