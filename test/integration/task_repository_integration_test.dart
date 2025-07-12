import 'package:flutter_test/flutter_test.dart';
import 'package:taskify/data/repositories/task_repository_impl.dart';
import 'package:taskify/domain/entities/task.dart';
import 'hive_test_setup.dart';

void main() {
  group('TaskRepositoryImpl Integration Tests', () {
    late TaskRepositoryImpl repository;

    setUpAll(() async {
      await HiveTestHelper.setupTestDatabase();
    });

    setUp(() async {
      repository = TaskRepositoryImpl();
      await HiveTestHelper.clearDatabase();
    });

    tearDownAll(() async {
      await HiveTestHelper.cleanupHive();
    });

    group('CRUD Operations', () {
      test('should add and retrieve task', () async {
        // Arrange
        final task = Task.create(title: 'Test Task', description: 'Test Description', priority: 2);

        // Act
        await repository.addTask(task);
        final retrievedTasks = await repository.getAllTasks();

        // Assert
        expect(retrievedTasks.length, equals(1));
        expect(retrievedTasks.first.title, equals('Test Task'));
        expect(retrievedTasks.first.description, equals('Test Description'));
        expect(retrievedTasks.first.priority, equals(2));
        expect(retrievedTasks.first.isCompleted, equals(false));
      });

      test('should retrieve task by ID', () async {
        // Arrange
        final task = Task.create(title: 'Findable Task', description: 'Can be found by ID');
        await repository.addTask(task);

        // Act
        final retrievedTask = await repository.getTaskById(task.id);

        // Assert
        expect(retrievedTask, isNotNull);
        expect(retrievedTask!.id, equals(task.id));
        expect(retrievedTask.title, equals('Findable Task'));
      });

      test('should throw error for non-existent task', () async {
        // Act & Assert
        expect(() async => await repository.getTaskById('non-existent'), throwsStateError);
      });

      test('should update existing task', () async {
        // Arrange
        final task = Task.create(title: 'Original Title', description: 'Original Description');
        await repository.addTask(task);

        // Act
        final updatedTask = task.copyWith(title: 'Updated Title', description: 'Updated Description', isCompleted: true);
        await repository.updateTask(updatedTask);

        // Assert
        final retrievedTask = await repository.getTaskById(task.id);
        expect(retrievedTask!.title, equals('Updated Title'));
        expect(retrievedTask.description, equals('Updated Description'));
        expect(retrievedTask.isCompleted, equals(true));
      });

      test('should delete task', () async {
        // Arrange
        final task1 = Task.create(title: 'Task 1', description: 'Keep this');
        final task2 = Task.create(title: 'Task 2', description: 'Delete this');
        await repository.addTask(task1);
        await repository.addTask(task2);

        // Act
        await repository.deleteTask(task2.id);

        // Assert
        final remainingTasks = await repository.getAllTasks();
        expect(remainingTasks.length, equals(1));
        expect(remainingTasks.first.title, equals('Task 1'));
      });

      test('should delete all tasks', () async {
        // Arrange
        final task1 = Task.create(title: 'Task 1', description: 'Description 1');
        final task2 = Task.create(title: 'Task 2', description: 'Description 2');
        final task3 = Task.create(title: 'Task 3', description: 'Description 3');
        await repository.addTask(task1);
        await repository.addTask(task2);
        await repository.addTask(task3);

        // Act
        await repository.deleteAllTasks();

        // Assert
        final remainingTasks = await repository.getAllTasks();
        expect(remainingTasks, isEmpty);
      });
    });

    group('Task Filtering', () {
      late List<Task> testTasks;

      setUp(() async {
        testTasks = [
          Task.create(title: 'Active Task 1', description: 'Not completed', priority: 1),
          Task.create(title: 'Completed Task', description: 'This is done', priority: 2).copyWith(isCompleted: true),
          Task.create(title: 'Active Task 2', description: 'Also not completed', priority: 3),
          Task.create(title: 'High Priority Done', description: 'High priority completed', priority: 3).copyWith(isCompleted: true),
        ];

        for (final task in testTasks) {
          await repository.addTask(task);
        }
      });

      test('should get all tasks sorted by creation date', () async {
        // Act
        final allTasks = await repository.getAllTasks();

        // Assert
        expect(allTasks.length, equals(4));
        // Should be sorted by creation date, newest first
        for (int i = 0; i < allTasks.length - 1; i++) {
          expect(allTasks[i].createdAt.isAfter(allTasks[i + 1].createdAt) || allTasks[i].createdAt.isAtSameMomentAs(allTasks[i + 1].createdAt), isTrue);
        }
      });

      test('should get only active tasks', () async {
        // Act
        final activeTasks = await repository.getActiveTasks();

        // Assert
        expect(activeTasks.length, equals(2));
        expect(activeTasks.every((task) => !task.isCompleted), isTrue);
        expect(activeTasks.map((t) => t.title), containsAll(['Active Task 1', 'Active Task 2']));
      });

      test('should get only completed tasks', () async {
        // Act
        final completedTasks = await repository.getCompletedTasks();

        // Assert
        expect(completedTasks.length, equals(2));
        expect(completedTasks.every((task) => task.isCompleted), isTrue);
        expect(completedTasks.map((t) => t.title), containsAll(['Completed Task', 'High Priority Done']));
      });

      test('should get tasks by priority', () async {
        // Act
        final lowPriorityTasks = await repository.getTasksByPriority(1);
        final mediumPriorityTasks = await repository.getTasksByPriority(2);
        final highPriorityTasks = await repository.getTasksByPriority(3);

        // Assert
        expect(lowPriorityTasks.length, equals(1));
        expect(lowPriorityTasks.first.title, equals('Active Task 1'));

        expect(mediumPriorityTasks.length, equals(1));
        expect(mediumPriorityTasks.first.title, equals('Completed Task'));

        expect(highPriorityTasks.length, equals(2));
        expect(highPriorityTasks.map((t) => t.title), containsAll(['Active Task 2', 'High Priority Done']));
      });

      test('should get task counts', () async {
        // Act
        final totalCount = await repository.getTasksCount();
        final completedCount = await repository.getCompletedTasksCount();

        // Assert
        expect(totalCount, equals(4));
        expect(completedCount, equals(2));
      });
    });

    group('Task Completion Toggle', () {
      test('should toggle task from incomplete to complete', () async {
        // Arrange
        final task = Task.create(title: 'Toggle Test', description: 'Will be toggled');
        await repository.addTask(task);

        // Act
        await repository.toggleTaskCompletion(task.id);

        // Assert
        final updatedTask = await repository.getTaskById(task.id);
        expect(updatedTask!.isCompleted, equals(true));
        expect(updatedTask.updatedAt.isAfter(task.updatedAt), isTrue);
      });

      test('should toggle task from complete to incomplete', () async {
        // Arrange
        final task = Task.create(title: 'Toggle Test', description: 'Will be toggled').copyWith(isCompleted: true);
        await repository.addTask(task);

        // Act
        await repository.toggleTaskCompletion(task.id);

        // Assert
        final updatedTask = await repository.getTaskById(task.id);
        expect(updatedTask!.isCompleted, equals(false));
      });
    });

    group('Edge Cases and Performance', () {
      test('should handle empty database', () async {
        // Act
        final tasks = await repository.getAllTasks();
        final activeTasks = await repository.getActiveTasks();
        final completedTasks = await repository.getCompletedTasks();
        final taskCount = await repository.getTasksCount();
        final completedCount = await repository.getCompletedTasksCount();

        // Assert
        expect(tasks, isEmpty);
        expect(activeTasks, isEmpty);
        expect(completedTasks, isEmpty);
        expect(taskCount, equals(0));
        expect(completedCount, equals(0));
      });

      test('should handle large number of tasks', () async {
        // Arrange - Create 100 tasks
        final tasks = List.generate(100, (index) => Task.create(title: 'Task $index', description: 'Description $index', priority: (index % 3) + 1));

        // Add tasks
        for (final task in tasks) {
          await repository.addTask(task);
        }

        // Act
        final startTime = DateTime.now();
        final allTasks = await repository.getAllTasks();
        final activeTasks = await repository.getActiveTasks();
        final endTime = DateTime.now();

        // Assert
        expect(allTasks.length, equals(100));
        expect(activeTasks.length, equals(100)); // All tasks are active by default

        // Performance check - should complete quickly
        final duration = endTime.difference(startTime);
        expect(duration.inMilliseconds, lessThan(500));
      });

      test('should handle tasks with same timestamps', () async {
        // Arrange
        final baseTime = DateTime.now();
        final task1 = Task(id: 'task-1', title: 'Task 1', description: 'Same time', isCompleted: false, createdAt: baseTime, updatedAt: baseTime);
        final task2 = Task(id: 'task-2', title: 'Task 2', description: 'Same time', isCompleted: false, createdAt: baseTime, updatedAt: baseTime);

        // Act
        await repository.addTask(task1);
        await repository.addTask(task2);
        final retrievedTasks = await repository.getAllTasks();

        // Assert
        expect(retrievedTasks.length, equals(2));
        // Should handle same timestamps gracefully
      });

      test('should maintain data integrity after multiple operations', () async {
        // Arrange
        final task = Task.create(title: 'Integrity Test', description: 'Testing data integrity', priority: 2);

        // Act - Multiple operations
        await repository.addTask(task);
        await repository.toggleTaskCompletion(task.id);

        // Get the toggled task and then update its title while preserving completion status
        final toggledTask = await repository.getTaskById(task.id);
        final updatedTask = toggledTask!.copyWith(title: 'Updated Title');
        await repository.updateTask(updatedTask);

        // Assert
        final finalTask = await repository.getTaskById(task.id);
        expect(finalTask!.id, equals(task.id));
        expect(finalTask.title, equals('Updated Title'));
        expect(finalTask.isCompleted, equals(true));
        expect(finalTask.priority, equals(2));
      });
    });
  });
}
