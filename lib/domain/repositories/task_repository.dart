import '../entities/task.dart';

/// Abstract repository interface for task operations
abstract class TaskRepository {
  /// Get all tasks
  Future<List<Task>> getAllTasks();

  /// Get task by ID
  Future<Task?> getTaskById(String id);

  /// Add new task
  Future<void> addTask(Task task);

  /// Update existing task
  Future<void> updateTask(Task task);

  /// Delete task by ID
  Future<void> deleteTask(String id);

  /// Delete all tasks
  Future<void> deleteAllTasks();

  /// Get active tasks (not completed)
  Future<List<Task>> getActiveTasks();

  /// Get completed tasks
  Future<List<Task>> getCompletedTasks();

  /// Get tasks by priority
  Future<List<Task>> getTasksByPriority(int priority);

  /// Toggle task completion status
  Future<void> toggleTaskCompletion(String id);

  /// Get tasks count
  Future<int> getTasksCount();

  /// Get completed tasks count
  Future<int> getCompletedTasksCount();
}
