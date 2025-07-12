import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:taskify/domain/entities/task.dart';
import 'package:taskify/domain/repositories/task_repository.dart';
import 'package:taskify/presentation/providers/task_provider.dart';

import 'task_provider_integration_test.mocks.dart';

@GenerateMocks([TaskRepository])
void main() {
  group('TaskProvider Integration Tests', () {
    late TaskProvider taskProvider;
    late MockTaskRepository mockRepository;
    late List<Task> testTasks;
    late DateTime testDate;

    setUp(() {
      mockRepository = MockTaskRepository();
      taskProvider = TaskProvider(mockRepository);
      testDate = DateTime(2024, 1, 1, 12, 0, 0);

      testTasks = [
        Task(id: 'task-1', title: 'Task 1', description: 'Description 1', isCompleted: false, createdAt: testDate, updatedAt: testDate, priority: 1),
        Task(
          id: 'task-2',
          title: 'Task 2',
          description: 'Description 2',
          isCompleted: true,
          createdAt: testDate.add(const Duration(hours: 1)),
          updatedAt: testDate.add(const Duration(hours: 1)),
          priority: 2,
        ),
        Task(
          id: 'task-3',
          title: 'Task 3',
          description: 'Description 3',
          isCompleted: false,
          createdAt: testDate.add(const Duration(hours: 2)),
          updatedAt: testDate.add(const Duration(hours: 2)),
          priority: 3,
        ),
      ];
    });

    group('Initialization and Loading', () {
      test('should initialize with default values', () {
        // Assert
        expect(taskProvider.allTasks, isEmpty);
        expect(taskProvider.currentFilter, equals(TaskFilter.all));
        expect(taskProvider.isLoading, equals(false));
        expect(taskProvider.searchQuery, equals(''));
        expect(taskProvider.totalTasks, equals(0));
        expect(taskProvider.activeTasks, equals(0));
        expect(taskProvider.completedTasks, equals(0));
        expect(taskProvider.completionPercentage, equals(0.0));
      });

      test('should load tasks on initialization', () async {
        // Arrange
        when(mockRepository.getAllTasks()).thenAnswer((_) async => testTasks);

        // Act
        await taskProvider.initialize();

        // Assert
        verify(mockRepository.getAllTasks()).called(1);
        expect(taskProvider.allTasks.length, equals(3));
        expect(taskProvider.isLoading, equals(false));
        expect(taskProvider.totalTasks, equals(3));
        expect(taskProvider.activeTasks, equals(2));
        expect(taskProvider.completedTasks, equals(1));
      });

      test('should handle initialization error gracefully', () async {
        // Arrange
        when(mockRepository.getAllTasks()).thenThrow(Exception('Database error'));

        // Act
        await taskProvider.initialize();

        // Assert
        expect(taskProvider.allTasks, isEmpty);
        expect(taskProvider.isLoading, equals(false));
      });

      test('should set loading state correctly during loadTasks', () async {
        // Arrange
        when(mockRepository.getAllTasks()).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return testTasks;
        });

        // Act
        final loadFuture = taskProvider.loadTasks();

        // Check loading state during operation
        expect(taskProvider.isLoading, equals(true));

        await loadFuture;

        // Assert
        expect(taskProvider.isLoading, equals(false));
        expect(taskProvider.allTasks.length, equals(3));
      });
    });

    group('Task CRUD Operations', () {
      test('should add task successfully', () async {
        // Arrange
        when(mockRepository.addTask(any)).thenAnswer((_) async {
          return null;
        });
        when(mockRepository.getAllTasks()).thenAnswer((_) async => testTasks);

        // Act
        await taskProvider.addTask('New Task', 'New Description', priority: 2);

        // Assert
        final capturedTask = verify(mockRepository.addTask(captureAny)).captured.single as Task;
        expect(capturedTask.title, equals('New Task'));
        expect(capturedTask.description, equals('New Description'));
        expect(capturedTask.priority, equals(2));
        expect(capturedTask.isCompleted, equals(false));
        verify(mockRepository.getAllTasks()).called(1);
      });

      test('should add task with default priority', () async {
        // Arrange
        when(mockRepository.addTask(any)).thenAnswer((_) async {
          return null;
        });
        when(mockRepository.getAllTasks()).thenAnswer((_) async => testTasks);

        // Act
        await taskProvider.addTask('Default Priority Task', 'Description');

        // Assert
        final capturedTask = verify(mockRepository.addTask(captureAny)).captured.single as Task;
        expect(capturedTask.priority, equals(1)); // Default priority
        expect(capturedTask.title, equals('Default Priority Task'));
        expect(capturedTask.description, equals('Description'));
        expect(capturedTask.isCompleted, equals(false));
      });

      test('should update task successfully', () async {
        // Arrange
        final updatedTask = testTasks.first.copyWith(title: 'Updated Title');
        when(mockRepository.updateTask(any)).thenAnswer((_) async {
          return null;
        });
        when(mockRepository.getAllTasks()).thenAnswer((_) async => testTasks);

        // Act
        await taskProvider.updateTask(updatedTask);

        // Assert
        verify(mockRepository.updateTask(updatedTask)).called(1);
        verify(mockRepository.getAllTasks()).called(1);
      });

      test('should delete task successfully', () async {
        // Arrange
        when(mockRepository.deleteTask(any)).thenAnswer((_) async {
          return null;
        });
        when(mockRepository.getAllTasks()).thenAnswer((_) async => testTasks);

        // Act
        await taskProvider.deleteTask('task-1');

        // Assert
        verify(mockRepository.deleteTask('task-1')).called(1);
        verify(mockRepository.getAllTasks()).called(1);
      });

      test('should toggle task completion successfully', () async {
        // Arrange
        when(mockRepository.toggleTaskCompletion(any)).thenAnswer((_) async {
          return null;
        });
        when(mockRepository.getAllTasks()).thenAnswer((_) async => testTasks);

        // Act
        await taskProvider.toggleTaskCompletion('task-1');

        // Assert
        verify(mockRepository.toggleTaskCompletion('task-1')).called(1);
        verify(mockRepository.getAllTasks()).called(1);
      });

      test('should delete all tasks successfully', () async {
        // Arrange
        when(mockRepository.deleteAllTasks()).thenAnswer((_) async {
          return null;
        });
        when(mockRepository.getAllTasks()).thenAnswer((_) async => <Task>[]);

        // Act
        await taskProvider.deleteAllTasks();

        // Assert
        verify(mockRepository.deleteAllTasks()).called(1);
        verify(mockRepository.getAllTasks()).called(1);
      });

      test('should handle CRUD operation errors', () async {
        // Arrange
        when(mockRepository.addTask(any)).thenThrow(Exception('Add error'));
        when(mockRepository.updateTask(any)).thenThrow(Exception('Update error'));
        when(mockRepository.deleteTask(any)).thenThrow(Exception('Delete error'));

        // Act & Assert
        expect(() => taskProvider.addTask('Failed Task', 'Description'), throwsException);

        expect(() => taskProvider.updateTask(testTasks.first), throwsException);

        expect(() => taskProvider.deleteTask('task-1'), throwsException);
      });
    });

    group('Filtering and Search', () {
      setUp(() {
        // Set up tasks in provider for filtering tests
        taskProvider.allTasks.clear();
        taskProvider.allTasks.addAll(testTasks);
      });

      test('should filter all tasks correctly', () {
        // Act
        taskProvider.setFilter(TaskFilter.all);
        final filteredTasks = taskProvider.filteredTasks;

        // Assert
        expect(filteredTasks.length, equals(3));
        expect(taskProvider.currentFilter, equals(TaskFilter.all));
      });

      test('should filter active tasks correctly', () {
        // Act
        taskProvider.setFilter(TaskFilter.active);
        final filteredTasks = taskProvider.filteredTasks;

        // Assert
        expect(filteredTasks.length, equals(2));
        expect(filteredTasks.every((task) => !task.isCompleted), isTrue);
        expect(taskProvider.currentFilter, equals(TaskFilter.active));
      });

      test('should filter completed tasks correctly', () {
        // Act
        taskProvider.setFilter(TaskFilter.completed);
        final filteredTasks = taskProvider.filteredTasks;

        // Assert
        expect(filteredTasks.length, equals(1));
        expect(filteredTasks.every((task) => task.isCompleted), isTrue);
        expect(taskProvider.currentFilter, equals(TaskFilter.completed));
      });

      test('should search by title correctly', () {
        // Act
        taskProvider.setSearchQuery('Task 2');
        final filteredTasks = taskProvider.filteredTasks;

        // Assert
        expect(filteredTasks.length, equals(1));
        expect(filteredTasks.first.title, equals('Task 2'));
        expect(taskProvider.searchQuery, equals('Task 2'));
      });

      test('should search by description correctly', () {
        // Act
        taskProvider.setSearchQuery('Description 3');
        final filteredTasks = taskProvider.filteredTasks;

        // Assert
        expect(filteredTasks.length, equals(1));
        expect(filteredTasks.first.description, equals('Description 3'));
      });

      test('should search case insensitively', () {
        // Act
        taskProvider.setSearchQuery('TASK 1');
        final filteredTasks = taskProvider.filteredTasks;

        // Assert
        expect(filteredTasks.length, equals(1));
        expect(filteredTasks.first.title, equals('Task 1'));
      });

      test('should return empty list for non-matching search', () {
        // Act
        taskProvider.setSearchQuery('Non-existent');
        final filteredTasks = taskProvider.filteredTasks;

        // Assert
        expect(filteredTasks, isEmpty);
      });

      test('should clear search correctly', () {
        // Arrange
        taskProvider.setSearchQuery('Task 1');
        expect(taskProvider.filteredTasks.length, equals(1));

        // Act
        taskProvider.clearSearch();

        // Assert
        expect(taskProvider.searchQuery, equals(''));
        expect(taskProvider.filteredTasks.length, equals(3));
      });

      test('should apply both filter and search correctly', () {
        // Arrange
        taskProvider.setFilter(TaskFilter.active);
        taskProvider.setSearchQuery('Task 1');

        // Act
        final filteredTasks = taskProvider.filteredTasks;

        // Assert
        expect(filteredTasks.length, equals(1));
        expect(filteredTasks.first.title, equals('Task 1'));
        expect(filteredTasks.first.isCompleted, equals(false));
      });

      test('should return empty when filter and search don\'t match', () {
        // Arrange
        taskProvider.setFilter(TaskFilter.completed);
        taskProvider.setSearchQuery('Task 1'); // Task 1 is not completed

        // Act
        final filteredTasks = taskProvider.filteredTasks;

        // Assert
        expect(filteredTasks, isEmpty);
      });
    });

    group('Statistics and Calculations', () {
      setUp(() {
        taskProvider.allTasks.clear();
        taskProvider.allTasks.addAll(testTasks);
      });

      test('should calculate total tasks correctly', () {
        expect(taskProvider.totalTasks, equals(3));
      });

      test('should calculate active tasks correctly', () {
        expect(taskProvider.activeTasks, equals(2));
      });

      test('should calculate completed tasks correctly', () {
        expect(taskProvider.completedTasks, equals(1));
      });

      test('should calculate completion percentage correctly', () {
        // 1 completed out of 3 total = 33.33%
        expect(taskProvider.completionPercentage, closeTo(33.33, 0.01));
      });

      test('should return 0 completion percentage for empty tasks', () {
        // Arrange
        taskProvider.allTasks.clear();

        // Assert
        expect(taskProvider.completionPercentage, equals(0.0));
      });

      test('should return 100 completion percentage when all completed', () {
        // Arrange
        final allCompletedTasks = testTasks.map((task) => task.copyWith(isCompleted: true)).toList();
        taskProvider.allTasks.clear();
        taskProvider.allTasks.addAll(allCompletedTasks);

        // Assert
        expect(taskProvider.completionPercentage, equals(100.0));
      });
    });

    group('Task Lookup and Utility Methods', () {
      setUp(() {
        taskProvider.allTasks.clear();
        taskProvider.allTasks.addAll(testTasks);
      });

      test('should return task when found by ID', () {
        // Act
        final task = taskProvider.getTaskById('task-2');

        // Assert
        expect(task, isNotNull);
        expect(task!.id, equals('task-2'));
        expect(task.title, equals('Task 2'));
      });

      test('should return null when task not found by ID', () {
        // Act
        final task = taskProvider.getTaskById('non-existent');

        // Assert
        expect(task, isNull);
      });

      test('should return tasks with specified priority', () {
        // Act
        final highPriorityTasks = taskProvider.getTasksByPriority(3);
        final lowPriorityTasks = taskProvider.getTasksByPriority(1);

        // Assert
        expect(highPriorityTasks.length, equals(1));
        expect(highPriorityTasks.first.priority, equals(3));

        expect(lowPriorityTasks.length, equals(1));
        expect(lowPriorityTasks.first.priority, equals(1));
      });

      test('should return empty list for non-existent priority', () {
        // Act
        final nonExistentPriorityTasks = taskProvider.getTasksByPriority(5);

        // Assert
        expect(nonExistentPriorityTasks, isEmpty);
      });
    });

    group('Notification and State Management', () {
      test('should notify listeners when filter changes', () {
        // Arrange
        var notificationCount = 0;
        taskProvider.addListener(() => notificationCount++);

        // Act
        taskProvider.setFilter(TaskFilter.active);
        taskProvider.setFilter(TaskFilter.completed);

        // Assert
        expect(notificationCount, equals(2));
      });

      test('should notify listeners when search query changes', () {
        // Arrange
        var notificationCount = 0;
        taskProvider.addListener(() => notificationCount++);

        // Act
        taskProvider.setSearchQuery('Test');
        taskProvider.clearSearch();

        // Assert
        expect(notificationCount, equals(2));
      });

      test('should notify listeners when tasks are loaded', () async {
        // Arrange
        var notificationCount = 0;
        taskProvider.addListener(() => notificationCount++);
        when(mockRepository.getAllTasks()).thenAnswer((_) async => testTasks);

        // Act
        await taskProvider.loadTasks();

        // Assert
        expect(notificationCount, greaterThan(0));
      });
    });

    group('Error Handling and Edge Cases', () {
      test('should maintain state consistency during errors', () async {
        // Arrange
        when(mockRepository.getAllTasks()).thenAnswer((_) async => testTasks);
        await taskProvider.loadTasks();
        final initialTaskCount = taskProvider.totalTasks;

        // Simulate error in next operation
        when(mockRepository.addTask(any)).thenThrow(Exception('Add error'));

        // Act & Assert
        try {
          await taskProvider.addTask('Failed Task', 'Description');
        } catch (e) {
          // Error expected
        }

        // State should remain consistent
        expect(taskProvider.totalTasks, equals(initialTaskCount));
        expect(taskProvider.isLoading, equals(false));
      });

      test('should handle rapid filter changes correctly', () {
        // Arrange
        taskProvider.allTasks.clear();
        taskProvider.allTasks.addAll(testTasks);

        // Act - Rapid filter changes
        taskProvider.setFilter(TaskFilter.active);
        taskProvider.setFilter(TaskFilter.completed);
        taskProvider.setFilter(TaskFilter.all);

        // Assert
        expect(taskProvider.currentFilter, equals(TaskFilter.all));
        expect(taskProvider.filteredTasks.length, equals(3));
      });

      test('should handle rapid search query changes correctly', () {
        // Arrange
        taskProvider.allTasks.clear();
        taskProvider.allTasks.addAll(testTasks);

        // Act - Rapid search changes
        taskProvider.setSearchQuery('Task');
        taskProvider.setSearchQuery('Task 1');
        taskProvider.setSearchQuery('');

        // Assert
        expect(taskProvider.searchQuery, equals(''));
        expect(taskProvider.filteredTasks.length, equals(3));
      });

      test('should handle empty task list operations gracefully', () {
        // Arrange - Start with empty tasks
        expect(taskProvider.allTasks, isEmpty);

        // Act & Assert
        expect(taskProvider.getTaskById('any-id'), isNull);
        expect(taskProvider.getTasksByPriority(1), isEmpty);
        expect(taskProvider.filteredTasks, isEmpty);
        expect(taskProvider.totalTasks, equals(0));
        expect(taskProvider.activeTasks, equals(0));
        expect(taskProvider.completedTasks, equals(0));
        expect(taskProvider.completionPercentage, equals(0.0));
      });
    });
  });
}
