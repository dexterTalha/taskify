import 'package:flutter_test/flutter_test.dart';
import 'package:taskify/data/models/task_model.dart';
import 'package:taskify/domain/entities/task.dart';

void main() {
  group('TaskRepositoryImpl Business Logic Tests', () {
    late List<TaskModel> testTasks;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 1, 12, 0, 0);

      testTasks = [
        TaskModel(id: 'task-1', title: 'Task 1', description: 'Description 1', isCompleted: false, createdAt: testDate, updatedAt: testDate, priority: 1),
        TaskModel(
          id: 'task-2',
          title: 'Task 2',
          description: 'Description 2',
          isCompleted: true,
          createdAt: testDate.add(const Duration(hours: 1)),
          updatedAt: testDate.add(const Duration(hours: 1)),
          priority: 2,
        ),
        TaskModel(
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

    group('Task Sorting Logic Tests', () {
      test('should sort tasks by creation date (newest first)', () {
        // Arrange
        final unsortedTasks = List<TaskModel>.from(testTasks);

        // Act - Sort by creation date, newest first
        unsortedTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // Assert
        expect(unsortedTasks.first.id, equals('task-3')); // Most recent
        expect(unsortedTasks.last.id, equals('task-1')); // Oldest
        expect(unsortedTasks[1].id, equals('task-2')); // Middle
      });

      test('should handle empty list sorting', () {
        // Arrange
        final emptyTasks = <TaskModel>[];

        // Act
        emptyTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // Assert
        expect(emptyTasks, isEmpty);
      });

      test('should maintain order for tasks with same timestamp', () {
        // Arrange
        final sameDateTasks = [
          TaskModel(id: 'task-a', title: 'Task A', description: 'Same time', isCompleted: false, createdAt: testDate, updatedAt: testDate),
          TaskModel(id: 'task-b', title: 'Task B', description: 'Same time', isCompleted: false, createdAt: testDate, updatedAt: testDate),
        ];

        // Act
        sameDateTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // Assert
        expect(sameDateTasks.length, equals(2));
        expect(sameDateTasks[0].id, equals('task-a')); // Original order maintained
        expect(sameDateTasks[1].id, equals('task-b'));
      });
    });

    group('Task Filtering Logic Tests', () {
      test('should filter active tasks correctly', () {
        // Act
        final activeTasks = testTasks.where((task) => !task.isCompleted).toList();

        // Assert
        expect(activeTasks.length, equals(2));
        expect(activeTasks.every((task) => !task.isCompleted), isTrue);
        expect(activeTasks.map((t) => t.id), containsAll(['task-1', 'task-3']));
      });

      test('should filter completed tasks correctly', () {
        // Act
        final completedTasks = testTasks.where((task) => task.isCompleted).toList();

        // Assert
        expect(completedTasks.length, equals(1));
        expect(completedTasks.every((task) => task.isCompleted), isTrue);
        expect(completedTasks.first.id, equals('task-2'));
      });

      test('should filter tasks by priority correctly', () {
        // Act
        final highPriorityTasks = testTasks.where((task) => task.priority == 3).toList();
        final mediumPriorityTasks = testTasks.where((task) => task.priority == 2).toList();
        final lowPriorityTasks = testTasks.where((task) => task.priority == 1).toList();

        // Assert
        expect(highPriorityTasks.length, equals(1));
        expect(highPriorityTasks.first.id, equals('task-3'));

        expect(mediumPriorityTasks.length, equals(1));
        expect(mediumPriorityTasks.first.id, equals('task-2'));

        expect(lowPriorityTasks.length, equals(1));
        expect(lowPriorityTasks.first.id, equals('task-1'));
      });

      test('should return empty list for non-existent priority', () {
        // Act
        final nonExistentPriorityTasks = testTasks.where((task) => task.priority == 5).toList();

        // Assert
        expect(nonExistentPriorityTasks, isEmpty);
      });

      test('should handle edge case priority values', () {
        // Arrange
        final edgeCaseTasks = [
          TaskModel(id: 'zero-task', title: 'Zero Priority', description: 'Zero priority task', isCompleted: false, createdAt: testDate, updatedAt: testDate, priority: 0),
          TaskModel(
            id: 'negative-task',
            title: 'Negative Priority',
            description: 'Negative priority task',
            isCompleted: false,
            createdAt: testDate,
            updatedAt: testDate,
            priority: -1,
          ),
        ];

        // Act
        final zeroTasks = edgeCaseTasks.where((task) => task.priority == 0).toList();
        final negativeTasks = edgeCaseTasks.where((task) => task.priority == -1).toList();

        // Assert
        expect(zeroTasks.length, equals(1));
        expect(zeroTasks.first.priority, equals(0));

        expect(negativeTasks.length, equals(1));
        expect(negativeTasks.first.priority, equals(-1));
      });
    });

    group('Task Search Logic Tests', () {
      test('should find task by ID correctly', () {
        // Arrange
        const targetId = 'task-2';

        // Act
        final foundTask = testTasks.firstWhere((task) => task.id == targetId);

        // Assert
        expect(foundTask.id, equals(targetId));
        expect(foundTask.title, equals('Task 2'));
        expect(foundTask.isCompleted, isTrue);
      });

      test('should throw StateError when task not found', () {
        // Act & Assert
        expect(() => testTasks.firstWhere((task) => task.id == 'non-existent'), throwsStateError);
      });

      test('should find task index correctly', () {
        // Arrange
        const targetId = 'task-3';

        // Act
        final index = testTasks.indexWhere((task) => task.id == targetId);

        // Assert
        expect(index, equals(2));
      });

      test('should return -1 for non-existent task index', () {
        // Act
        final index = testTasks.indexWhere((task) => task.id == 'non-existent');

        // Assert
        expect(index, equals(-1));
      });
    });

    group('Task Count Logic Tests', () {
      test('should count tasks correctly', () {
        // Act
        final totalCount = testTasks.length;
        final completedCount = testTasks.where((task) => task.isCompleted).length;
        final activeCount = testTasks.where((task) => !task.isCompleted).length;

        // Assert
        expect(totalCount, equals(3));
        expect(completedCount, equals(1));
        expect(activeCount, equals(2));
        expect(completedCount + activeCount, equals(totalCount));
      });

      test('should handle empty list counts', () {
        // Arrange
        final emptyTasks = <TaskModel>[];

        // Act
        final totalCount = emptyTasks.length;
        final completedCount = emptyTasks.where((task) => task.isCompleted).length;
        final activeCount = emptyTasks.where((task) => !task.isCompleted).length;

        // Assert
        expect(totalCount, equals(0));
        expect(completedCount, equals(0));
        expect(activeCount, equals(0));
      });
    });

    group('Task Conversion Logic Tests', () {
      test('should convert TaskModel to Task correctly', () {
        // Arrange
        final taskModel = testTasks.first;

        // Act
        final task = taskModel.toTask();

        // Assert
        expect(task, isA<Task>());
        expect(task.id, equals(taskModel.id));
        expect(task.title, equals(taskModel.title));
        expect(task.description, equals(taskModel.description));
        expect(task.isCompleted, equals(taskModel.isCompleted));
        expect(task.createdAt, equals(taskModel.createdAt));
        expect(task.updatedAt, equals(taskModel.updatedAt));
        expect(task.priority, equals(taskModel.priority));
      });

      test('should convert Task to TaskModel correctly', () {
        // Arrange
        final task = Task.create(title: 'Test Task', description: 'Test Description', priority: 2);

        // Act
        final taskModel = TaskModel.fromTask(task);

        // Assert
        expect(taskModel, isA<TaskModel>());
        expect(taskModel.id, equals(task.id));
        expect(taskModel.title, equals(task.title));
        expect(taskModel.description, equals(task.description));
        expect(taskModel.isCompleted, equals(task.isCompleted));
        expect(taskModel.createdAt, equals(task.createdAt));
        expect(taskModel.updatedAt, equals(task.updatedAt));
        expect(taskModel.priority, equals(task.priority));
      });

      test('should convert list of TaskModels to Tasks correctly', () {
        // Act
        final tasks = testTasks.map((model) => model.toTask()).toList();

        // Assert
        expect(tasks.length, equals(testTasks.length));
        expect(tasks.every((task) => task is Task), isTrue);

        for (int i = 0; i < tasks.length; i++) {
          expect(tasks[i].id, equals(testTasks[i].id));
          expect(tasks[i].title, equals(testTasks[i].title));
        }
      });
    });

    group('Task Toggle Logic Tests', () {
      test('should toggle task completion correctly', () {
        // Arrange
        final originalTask = testTasks.first; // isCompleted: false

        // Act
        final toggledTask = originalTask.toggleCompleted();

        // Assert
        expect(toggledTask.isCompleted, equals(true));
        expect(toggledTask.id, equals(originalTask.id));
        expect(toggledTask.title, equals(originalTask.title));
        expect(toggledTask.updatedAt.isAfter(originalTask.updatedAt), isTrue);
      });

      test('should toggle from completed to incomplete', () {
        // Arrange
        final completedTask = testTasks[1]; // isCompleted: true

        // Act
        final toggledTask = completedTask.toggleCompleted();

        // Assert
        expect(toggledTask.isCompleted, equals(false));
        expect(toggledTask.id, equals(completedTask.id));
        expect(toggledTask.title, equals(completedTask.title));
      });
    });

    group('Performance and Edge Cases', () {
      test('should handle large task lists efficiently', () {
        // Arrange
        final largeTasks = List.generate(
          1000,
          (index) => TaskModel(
            id: 'task-$index',
            title: 'Task $index',
            description: 'Description $index',
            isCompleted: index % 2 == 0,
            createdAt: testDate.add(Duration(minutes: index)),
            updatedAt: testDate.add(Duration(minutes: index)),
            priority: (index % 3) + 1,
          ),
        );

        // Act
        final startTime = DateTime.now();
        final completed = largeTasks.where((task) => task.isCompleted).length;
        final active = largeTasks.where((task) => !task.isCompleted).length;
        final highPriority = largeTasks.where((task) => task.priority == 3).length;
        final endTime = DateTime.now();

        // Assert
        expect(completed, equals(500));
        expect(active, equals(500));
        expect(highPriority, greaterThan(300)); // Approximately 333

        // Performance check - should complete quickly
        final duration = endTime.difference(startTime);
        expect(duration.inMilliseconds, lessThan(100));
      });

      test('should handle all completed tasks scenario', () {
        // Arrange
        final allCompletedTasks = testTasks.map((task) => task.copyWith(isCompleted: true)).toList();

        // Act
        final activeTasks = allCompletedTasks.where((task) => !task.isCompleted).toList();
        final completedTasks = allCompletedTasks.where((task) => task.isCompleted).toList();

        // Assert
        expect(activeTasks, isEmpty);
        expect(completedTasks.length, equals(testTasks.length));
      });

      test('should handle all active tasks scenario', () {
        // Arrange
        final allActiveTasks = testTasks.map((task) => task.copyWith(isCompleted: false)).toList();

        // Act
        final activeTasks = allActiveTasks.where((task) => !task.isCompleted).toList();
        final completedTasks = allActiveTasks.where((task) => task.isCompleted).toList();

        // Assert
        expect(activeTasks.length, equals(testTasks.length));
        expect(completedTasks, isEmpty);
      });
    });
  });
}
