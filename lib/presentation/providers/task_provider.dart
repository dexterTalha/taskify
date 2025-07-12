import 'package:flutter/foundation.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

/// Enum for task filter options
enum TaskFilter { all, active, completed }

/// Provider for managing task state and operations
class TaskProvider extends ChangeNotifier {
  final TaskRepository _taskRepository;

  TaskProvider(this._taskRepository);

  // State variables
  List<Task> _allTasks = [];
  TaskFilter _currentFilter = TaskFilter.all;
  bool _isLoading = false;
  String _searchQuery = '';
  bool _isSearching = false;
  bool _isStatsCollapsed = false;
  bool _isTaskDetailsCollapsed = false;

  // Getters
  List<Task> get allTasks => _allTasks;
  TaskFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;
  bool get isStatsCollapsed => _isStatsCollapsed;
  bool get isTaskDetailsCollapsed => _isTaskDetailsCollapsed;

  /// Get filtered tasks based on current filter and search query
  List<Task> get filteredTasks {
    List<Task> tasks = [];

    // Apply filter
    switch (_currentFilter) {
      case TaskFilter.all:
        tasks = _allTasks;
        break;
      case TaskFilter.active:
        tasks = _allTasks.where((task) => !task.isCompleted).toList();
        break;
      case TaskFilter.completed:
        tasks = _allTasks.where((task) => task.isCompleted).toList();
        break;
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      tasks = tasks.where((task) {
        return task.title.toLowerCase().contains(_searchQuery.toLowerCase()) || task.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return tasks;
  }

  /// Get task statistics
  int get totalTasks => _allTasks.length;
  int get activeTasks => _allTasks.where((task) => !task.isCompleted).length;
  int get completedTasks => _allTasks.where((task) => task.isCompleted).length;

  /// Initialize provider - load tasks from repository
  Future<void> initialize() async {
    await loadTasks();
  }

  /// Load all tasks from repository
  Future<void> loadTasks() async {
    _setLoading(true);
    try {
      _allTasks = await _taskRepository.getAllTasks();
      notifyListeners();
    } catch (e) {
      // Handle error
      debugPrint('Error loading tasks: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new task
  Future<void> addTask(String title, String description, {int priority = 1}) async {
    try {
      final newTask = Task.create(title: title, description: description, priority: priority);

      await _taskRepository.addTask(newTask);
      await loadTasks(); // Refresh tasks
    } catch (e) {
      debugPrint('Error adding task: $e');
      rethrow;
    }
  }

  /// Update an existing task
  Future<void> updateTask(Task task) async {
    try {
      await _taskRepository.updateTask(task);
      await loadTasks(); // Refresh tasks
    } catch (e) {
      debugPrint('Error updating task: $e');
      rethrow;
    }
  }

  /// Delete a task
  Future<void> deleteTask(String id) async {
    try {
      await _taskRepository.deleteTask(id);
      await loadTasks(); // Refresh tasks
    } catch (e) {
      debugPrint('Error deleting task: $e');
      rethrow;
    }
  }

  /// Toggle task completion status
  Future<void> toggleTaskCompletion(String id) async {
    try {
      await _taskRepository.toggleTaskCompletion(id);
      await loadTasks(); // Refresh tasks
    } catch (e) {
      debugPrint('Error toggling task completion: $e');
      rethrow;
    }
  }

  /// Set current filter
  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Clear search query
  void clearSearch() {
    _searchQuery = '';
    _isSearching = false;
    notifyListeners();
  }

  /// Set search state
  void setSearching(bool isSearching) {
    _isSearching = isSearching;
    _isStatsCollapsed = isSearching;
    if (!isSearching) {
      _searchQuery = '';
    }
    notifyListeners();
  }

  /// Toggle search state
  void toggleSearching() {
    _isSearching = !_isSearching;
    if (!_isSearching) {
      _searchQuery = '';
    }
    notifyListeners();
  }

  /// Toggle stats collapsed state
  void toggleStatsCollapsed() {
    _isStatsCollapsed = !_isStatsCollapsed;
    notifyListeners();
  }

  /// Toggle task details collapsed state
  void toggleTaskDetailsCollapsed() {
    _isTaskDetailsCollapsed = !_isTaskDetailsCollapsed;
    notifyListeners();
  }

  /// Delete all tasks
  Future<void> deleteAllTasks() async {
    try {
      await _taskRepository.deleteAllTasks();
      await loadTasks(); // Refresh tasks
    } catch (e) {
      debugPrint('Error deleting all tasks: $e');
      rethrow;
    }
  }

  /// Get task by ID
  Task? getTaskById(String id) {
    try {
      return _allTasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Private method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Get tasks by priority
  List<Task> getTasksByPriority(int priority) {
    return _allTasks.where((task) => task.priority == priority).toList();
  }

  /// Get task completion percentage
  double get completionPercentage {
    if (_allTasks.isEmpty) return 0.0;
    return (completedTasks / totalTasks) * 100;
  }
}
