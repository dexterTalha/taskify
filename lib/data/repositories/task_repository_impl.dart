import 'package:hive/hive.dart';
import '../../core/database/hive_config.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';

/// Concrete implementation of TaskRepository using Hive for local storage
class TaskRepositoryImpl implements TaskRepository {
  Box<TaskModel> get _taskBox => HiveConfig.taskBox;

  @override
  Future<List<Task>> getAllTasks() async {
    final taskModels = _taskBox.values.toList();
    // Sort by created date, newest first
    taskModels.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return taskModels.map((model) => model.toTask()).toList();
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final taskModel = _taskBox.values.firstWhere(
      (task) => task.id == id,
      orElse: () => throw StateError('Task not found'),
    );
    return taskModel.toTask();
  }

  @override
  Future<void> addTask(Task task) async {
    final taskModel = TaskModel.fromTask(task);
    await _taskBox.add(taskModel);
  }

  @override
  Future<void> updateTask(Task task) async {
    final taskModel = TaskModel.fromTask(task);
    final index = _taskBox.values.toList().indexWhere((t) => t.id == task.id);
    if (index != -1) {
      final key = _taskBox.keyAt(index);
      await _taskBox.put(key, taskModel);
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    final taskToDelete = _taskBox.values.toList().indexWhere(
      (task) => task.id == id,
    );
    if (taskToDelete != -1) {
      final key = _taskBox.keyAt(taskToDelete);
      await _taskBox.delete(key);
    }
  }

  @override
  Future<void> deleteAllTasks() async {
    await _taskBox.clear();
  }

  @override
  Future<List<Task>> getActiveTasks() async {
    final allTasks = await getAllTasks();
    return allTasks.where((task) => !task.isCompleted).toList();
  }

  @override
  Future<List<Task>> getCompletedTasks() async {
    final allTasks = await getAllTasks();
    return allTasks.where((task) => task.isCompleted).toList();
  }

  @override
  Future<List<Task>> getTasksByPriority(int priority) async {
    final allTasks = await getAllTasks();
    return allTasks.where((task) => task.priority == priority).toList();
  }

  @override
  Future<void> toggleTaskCompletion(String id) async {
    final taskIndex = _taskBox.values.toList().indexWhere((t) => t.id == id);
    if (taskIndex != -1) {
      final task = _taskBox.values.toList()[taskIndex];
      final updatedTask = task.toggleCompleted();
      final key = _taskBox.keyAt(taskIndex);
      await _taskBox.put(key, updatedTask);
    }
  }

  @override
  Future<int> getTasksCount() async {
    return _taskBox.length;
  }

  @override
  Future<int> getCompletedTasksCount() async {
    final completedTasks = await getCompletedTasks();
    return completedTasks.length;
  }
}
