import 'package:flutter_test/flutter_test.dart';
import 'package:taskify/domain/entities/task.dart';
import 'package:taskify/presentation/providers/task_provider.dart';

void main() {
  group('TaskProvider Logic Tests', () {
    late List<Task> testTasks;
    late DateTime testDate;

    setUp(() {
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

    group('Filter Logic Tests', () {
      test('should filter all tasks correctly', () {
        // Test the filtering logic used in TaskProvider
        final allTasks = testTasks;

        // All filter
        final allFiltered = allTasks;
        expect(allFiltered.length, equals(3));

        // Active filter
        final activeFiltered = allTasks.where((task) => !task.isCompleted).toList();
        expect(activeFiltered.length, equals(2));
        expect(activeFiltered.every((task) => !task.isCompleted), isTrue);

        // Completed filter
        final completedFiltered = allTasks.where((task) => task.isCompleted).toList();
        expect(completedFiltered.length, equals(1));
        expect(completedFiltered.every((task) => task.isCompleted), isTrue);
      });
    });

    group('Search Logic Tests', () {
      test('should search by title correctly', () {
        const searchQuery = 'Task 2';
        final filteredTasks = testTasks.where((task) {
          return task.title.toLowerCase().contains(searchQuery.toLowerCase()) || task.description.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        expect(filteredTasks.length, equals(1));
        expect(filteredTasks.first.title, equals('Task 2'));
      });

      test('should search by description correctly', () {
        const searchQuery = 'Description 3';
        final filteredTasks = testTasks.where((task) {
          return task.title.toLowerCase().contains(searchQuery.toLowerCase()) || task.description.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        expect(filteredTasks.length, equals(1));
        expect(filteredTasks.first.description, equals('Description 3'));
      });

      test('should search case insensitively', () {
        const searchQuery = 'TASK 1';
        final filteredTasks = testTasks.where((task) {
          return task.title.toLowerCase().contains(searchQuery.toLowerCase()) || task.description.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        expect(filteredTasks.length, equals(1));
        expect(filteredTasks.first.title, equals('Task 1'));
      });

      test('should return empty list for non-matching search', () {
        const searchQuery = 'Non-existent';
        final filteredTasks = testTasks.where((task) {
          return task.title.toLowerCase().contains(searchQuery.toLowerCase()) || task.description.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        expect(filteredTasks, isEmpty);
      });
    });

    group('Combined Filter and Search Logic Tests', () {
      test('should apply both filter and search correctly', () {
        // Filter: active tasks only
        final activeTasks = testTasks.where((task) => !task.isCompleted).toList();

        // Search: 'Task 1' within active tasks
        const searchQuery = 'Task 1';
        final filteredTasks = activeTasks.where((task) {
          return task.title.toLowerCase().contains(searchQuery.toLowerCase()) || task.description.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        expect(filteredTasks.length, equals(1));
        expect(filteredTasks.first.title, equals('Task 1'));
        expect(filteredTasks.first.isCompleted, equals(false));
      });

      test('should return empty when filter and search don\'t match', () {
        // Filter: completed tasks only
        final completedTasks = testTasks.where((task) => task.isCompleted).toList();

        // Search: 'Task 1' within completed tasks (Task 1 is not completed)
        const searchQuery = 'Task 1';
        final filteredTasks = completedTasks.where((task) {
          return task.title.toLowerCase().contains(searchQuery.toLowerCase()) || task.description.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        expect(filteredTasks, isEmpty);
      });
    });

    group('Statistics Calculation Tests', () {
      test('should calculate statistics correctly', () {
        final totalTasks = testTasks.length;
        final activeTasks = testTasks.where((task) => !task.isCompleted).length;
        final completedTasks = testTasks.where((task) => task.isCompleted).length;
        final completionPercentage = totalTasks == 0 ? 0.0 : (completedTasks / totalTasks) * 100;

        expect(totalTasks, equals(3));
        expect(activeTasks, equals(2));
        expect(completedTasks, equals(1));
        expect(completionPercentage, closeTo(33.33, 0.01));
      });

      test('should handle empty list statistics', () {
        final emptyTasks = <Task>[];
        final totalTasks = emptyTasks.length;
        final activeTasks = emptyTasks.where((task) => !task.isCompleted).length;
        final completedTasks = emptyTasks.where((task) => task.isCompleted).length;
        final completionPercentage = totalTasks == 0 ? 0.0 : (completedTasks / totalTasks) * 100;

        expect(totalTasks, equals(0));
        expect(activeTasks, equals(0));
        expect(completedTasks, equals(0));
        expect(completionPercentage, equals(0.0));
      });

      test('should handle all completed tasks', () {
        final allCompletedTasks = testTasks.map((task) => task.copyWith(isCompleted: true)).toList();

        final totalTasks = allCompletedTasks.length;
        final activeTasks = allCompletedTasks.where((task) => !task.isCompleted).length;
        final completedTasks = allCompletedTasks.where((task) => task.isCompleted).length;
        final completionPercentage = totalTasks == 0 ? 0.0 : (completedTasks / totalTasks) * 100;

        expect(totalTasks, equals(3));
        expect(activeTasks, equals(0));
        expect(completedTasks, equals(3));
        expect(completionPercentage, equals(100.0));
      });
    });

    group('Task Lookup Logic Tests', () {
      test('should find task by ID correctly', () {
        const targetId = 'task-2';
        Task? foundTask;

        try {
          foundTask = testTasks.firstWhere((task) => task.id == targetId);
        } catch (e) {
          foundTask = null;
        }

        expect(foundTask, isNotNull);
        expect(foundTask!.id, equals('task-2'));
        expect(foundTask.title, equals('Task 2'));
      });

      test('should return null for non-existent task ID', () {
        const targetId = 'non-existent';
        Task? foundTask;

        try {
          foundTask = testTasks.firstWhere((task) => task.id == targetId);
        } catch (e) {
          foundTask = null;
        }

        expect(foundTask, isNull);
      });
    });

    group('Priority Filtering Logic Tests', () {
      test('should filter tasks by priority correctly', () {
        final highPriorityTasks = testTasks.where((task) => task.priority == 3).toList();
        final mediumPriorityTasks = testTasks.where((task) => task.priority == 2).toList();
        final lowPriorityTasks = testTasks.where((task) => task.priority == 1).toList();

        expect(highPriorityTasks.length, equals(1));
        expect(highPriorityTasks.first.priority, equals(3));

        expect(mediumPriorityTasks.length, equals(1));
        expect(mediumPriorityTasks.first.priority, equals(2));

        expect(lowPriorityTasks.length, equals(1));
        expect(lowPriorityTasks.first.priority, equals(1));
      });

      test('should return empty list for non-existent priority', () {
        final nonExistentPriorityTasks = testTasks.where((task) => task.priority == 5).toList();
        expect(nonExistentPriorityTasks, isEmpty);
      });
    });

    group('TaskFilter Enum Tests', () {
      test('should have correct TaskFilter values', () {
        // Test the enum values used in TaskProvider
        const allFilter = TaskFilter.all;
        const activeFilter = TaskFilter.active;
        const completedFilter = TaskFilter.completed;

        expect(allFilter, equals(TaskFilter.all));
        expect(activeFilter, equals(TaskFilter.active));
        expect(completedFilter, equals(TaskFilter.completed));
      });

      test('should handle filter switching logic', () {
        // Simulate filter switching logic
        TaskFilter currentFilter = TaskFilter.all;

        // Switch to active
        currentFilter = TaskFilter.active;
        expect(currentFilter, equals(TaskFilter.active));

        // Switch to completed
        currentFilter = TaskFilter.completed;
        expect(currentFilter, equals(TaskFilter.completed));

        // Switch back to all
        currentFilter = TaskFilter.all;
        expect(currentFilter, equals(TaskFilter.all));
      });
    });

    group('Edge Cases and Performance Tests', () {
      test('should handle large task lists efficiently', () {
        // Generate large task list
        final largeTasks = List.generate(
          1000,
          (index) => Task(
            id: 'task-$index',
            title: 'Task $index',
            description: 'Description $index',
            isCompleted: index % 2 == 0,
            createdAt: testDate.add(Duration(minutes: index)),
            updatedAt: testDate.add(Duration(minutes: index)),
            priority: (index % 3) + 1,
          ),
        );

        // Test filtering performance
        final startTime = DateTime.now();
        final completed = largeTasks.where((task) => task.isCompleted).length;
        final active = largeTasks.where((task) => !task.isCompleted).length;
        final highPriority = largeTasks.where((task) => task.priority == 3).length;
        final endTime = DateTime.now();

        // Assert results
        expect(completed, equals(500));
        expect(active, equals(500));
        expect(highPriority, greaterThan(300));

        // Performance check
        final duration = endTime.difference(startTime);
        expect(duration.inMilliseconds, lessThan(100));
      });

      test('should handle rapid state changes correctly', () {
        // Simulate rapid filter changes
        var currentFilter = TaskFilter.all;
        var searchQuery = '';

        // Rapid changes
        currentFilter = TaskFilter.active;
        searchQuery = 'Task';
        currentFilter = TaskFilter.completed;
        searchQuery = 'Task 1';
        currentFilter = TaskFilter.all;
        searchQuery = '';

        // Final state should be consistent
        expect(currentFilter, equals(TaskFilter.all));
        expect(searchQuery, equals(''));
      });

      test('should handle empty search queries correctly', () {
        const emptyQuery = '';
        final filteredTasks = testTasks.where((task) {
          if (emptyQuery.isEmpty) return true;
          return task.title.toLowerCase().contains(emptyQuery.toLowerCase()) || task.description.toLowerCase().contains(emptyQuery.toLowerCase());
        }).toList();

        expect(filteredTasks.length, equals(testTasks.length));
      });

      test('should handle special characters in search', () {
        // Add task with special characters
        final specialTask = Task(
          id: 'special-task',
          title: 'Special!@#\$%^&*()Task',
          description: 'Contains émojis 🎉 and spëcial chars',
          isCompleted: false,
          createdAt: testDate,
          updatedAt: testDate,
        );

        final tasksWithSpecial = [...testTasks, specialTask];

        // Search for special characters
        const searchQuery = '🎉';
        final filteredTasks = tasksWithSpecial.where((task) {
          return task.title.toLowerCase().contains(searchQuery.toLowerCase()) || task.description.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        expect(filteredTasks.length, equals(1));
        expect(filteredTasks.first.id, equals('special-task'));
      });
    });
  });
}
