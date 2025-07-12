import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:taskify/data/models/task_model.dart';

class HiveTestHelper {
  static Future<void> initializeHive() async {
    // Use a test directory
    final testPath = './test/hive_test_db';

    // Clean up any existing test data
    if (await Directory(testPath).exists()) {
      await Directory(testPath).delete(recursive: true);
    }

    // Create test directory
    await Directory(testPath).create(recursive: true);

    Hive.init(testPath);

    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskModelAdapter());
    }
  }

  static Future<void> setupTestDatabase() async {
    await initializeHive();

    // Open the tasks box for testing
    if (!Hive.isBoxOpen('tasks')) {
      await Hive.openBox<TaskModel>('tasks');
    }
  }

  static Future<void> cleanupHive() async {
    // Close all boxes
    await Hive.close();

    // Clean up test files
    final testPath = './test/hive_test_db';
    if (await Directory(testPath).exists()) {
      await Directory(testPath).delete(recursive: true);
    }
  }

  static Future<void> clearDatabase() async {
    if (Hive.isBoxOpen('tasks')) {
      final box = Hive.box<TaskModel>('tasks');
      await box.clear();
    }
  }

  static Box<TaskModel> get taskBox => Hive.box<TaskModel>('tasks');
}
