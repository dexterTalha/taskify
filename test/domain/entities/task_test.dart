import 'package:flutter_test/flutter_test.dart';
import 'package:taskify/domain/entities/task.dart';

void main() {
  group('Task Entity Tests', () {
    late Task testTask;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 1, 12, 0, 0);
      testTask = Task(id: 'test-id', title: 'Test Task', description: 'Test Description', isCompleted: false, createdAt: testDate, updatedAt: testDate, priority: 2);
    });

    group('Constructor Tests', () {
      test('should create a task with all required properties', () {
        expect(testTask.id, equals('test-id'));
        expect(testTask.title, equals('Test Task'));
        expect(testTask.description, equals('Test Description'));
        expect(testTask.isCompleted, equals(false));
        expect(testTask.createdAt, equals(testDate));
        expect(testTask.updatedAt, equals(testDate));
        expect(testTask.priority, equals(2));
      });

      test('should create a task with default priority of 1', () {
        final task = Task(id: 'test-id', title: 'Test Task', description: 'Test Description', isCompleted: false, createdAt: testDate, updatedAt: testDate);
        expect(task.priority, equals(1));
      });
    });

    group('Factory Constructor Tests', () {
      test('should create a new task with generated ID and timestamps', () {
        final task = Task.create(title: 'New Task', description: 'New Description', priority: 3);

        expect(task.id, isNotEmpty);
        expect(task.title, equals('New Task'));
        expect(task.description, equals('New Description'));
        expect(task.isCompleted, equals(false));
        expect(task.priority, equals(3));
        expect(task.createdAt, isNotNull);
        expect(task.updatedAt, isNotNull);
        expect(task.createdAt, equals(task.updatedAt));
      });

      test('should create a new task with default priority', () {
        final task = Task.create(title: 'New Task', description: 'New Description');

        expect(task.priority, equals(1));
      });

      test('should create tasks with unique IDs', () {
        final task1 = Task.create(title: 'Task 1', description: 'Desc 1');
        final task2 = Task.create(title: 'Task 2', description: 'Desc 2');

        expect(task1.id, isNot(equals(task2.id)));
      });
    });

    group('CopyWith Tests', () {
      test('should copy task with updated title', () {
        final updatedTask = testTask.copyWith(title: 'Updated Title');

        expect(updatedTask.id, equals(testTask.id));
        expect(updatedTask.title, equals('Updated Title'));
        expect(updatedTask.description, equals(testTask.description));
        expect(updatedTask.isCompleted, equals(testTask.isCompleted));
        expect(updatedTask.priority, equals(testTask.priority));
      });

      test('should copy task with updated completion status', () {
        final updatedTask = testTask.copyWith(isCompleted: true);

        expect(updatedTask.isCompleted, equals(true));
        expect(updatedTask.title, equals(testTask.title));
      });

      test('should copy task with updated priority', () {
        final updatedTask = testTask.copyWith(priority: 3);

        expect(updatedTask.priority, equals(3));
        expect(updatedTask.title, equals(testTask.title));
      });

      test('should copy task with updated timestamps', () {
        final newDate = DateTime(2024, 2, 1);
        final updatedTask = testTask.copyWith(createdAt: newDate, updatedAt: newDate);

        expect(updatedTask.createdAt, equals(newDate));
        expect(updatedTask.updatedAt, equals(newDate));
      });

      test('should return identical task when no parameters provided', () {
        final copiedTask = testTask.copyWith();

        expect(copiedTask.id, equals(testTask.id));
        expect(copiedTask.title, equals(testTask.title));
        expect(copiedTask.description, equals(testTask.description));
        expect(copiedTask.isCompleted, equals(testTask.isCompleted));
        expect(copiedTask.priority, equals(testTask.priority));
      });
    });

    group('ToggleCompleted Tests', () {
      test('should toggle completion status from false to true', () {
        final toggledTask = testTask.toggleCompleted();

        expect(toggledTask.isCompleted, equals(true));
        expect(toggledTask.title, equals(testTask.title));
        expect(toggledTask.id, equals(testTask.id));
        expect(toggledTask.updatedAt.isAfter(testTask.updatedAt), isTrue);
      });

      test('should toggle completion status from true to false', () {
        final completedTask = testTask.copyWith(isCompleted: true);
        final toggledTask = completedTask.toggleCompleted();

        expect(toggledTask.isCompleted, equals(false));
        expect(toggledTask.title, equals(testTask.title));
        expect(toggledTask.id, equals(testTask.id));
      });

      test('should update timestamp when toggling', () {
        final originalTime = testTask.updatedAt;

        // Add a small delay to ensure different timestamp
        Future.delayed(const Duration(milliseconds: 1));

        final toggledTask = testTask.toggleCompleted();

        expect(toggledTask.updatedAt.isAfter(originalTime), isTrue);
      });
    });

    group('Equality Tests', () {
      test('should be equal when all properties match', () {
        final task1 = Task(id: 'same-id', title: 'Same Title', description: 'Same Description', isCompleted: false, createdAt: testDate, updatedAt: testDate, priority: 1);

        final task2 = Task(id: 'same-id', title: 'Same Title', description: 'Same Description', isCompleted: false, createdAt: testDate, updatedAt: testDate, priority: 1);

        expect(task1, equals(task2));
        expect(task1.hashCode, equals(task2.hashCode));
      });

      test('should not be equal when IDs differ', () {
        final task1 = testTask;
        final task2 = testTask.copyWith(id: 'different-id');

        expect(task1, isNot(equals(task2)));
        expect(task1.hashCode, isNot(equals(task2.hashCode)));
      });

      test('should not be equal when titles differ', () {
        final task1 = testTask;
        final task2 = testTask.copyWith(title: 'Different Title');

        expect(task1, isNot(equals(task2)));
      });

      test('should not be equal when completion status differs', () {
        final task1 = testTask;
        final task2 = testTask.copyWith(isCompleted: true);

        expect(task1, isNot(equals(task2)));
      });

      test('should not be equal when priorities differ', () {
        final task1 = testTask;
        final task2 = testTask.copyWith(priority: 3);

        expect(task1, isNot(equals(task2)));
      });
    });

    group('ToString Tests', () {
      test('should return formatted string representation', () {
        final taskString = testTask.toString();

        expect(taskString, contains('Task('));
        expect(taskString, contains('id: test-id'));
        expect(taskString, contains('title: Test Task'));
        expect(taskString, contains('description: Test Description'));
        expect(taskString, contains('isCompleted: false'));
        expect(taskString, contains('priority: 2'));
      });
    });

    group('Edge Cases', () {
      test('should handle empty title and description', () {
        final task = Task.create(title: '', description: '');

        expect(task.title, equals(''));
        expect(task.description, equals(''));
        expect(task.id, isNotEmpty);
      });

      test('should handle extreme priority values', () {
        final lowPriorityTask = Task.create(title: 'Test', description: 'Test', priority: 0);
        final highPriorityTask = Task.create(title: 'Test', description: 'Test', priority: 100);

        expect(lowPriorityTask.priority, equals(0));
        expect(highPriorityTask.priority, equals(100));
      });

      test('should handle very long title and description', () {
        final longText = 'A' * 1000;
        final task = Task.create(title: longText, description: longText);

        expect(task.title, equals(longText));
        expect(task.description, equals(longText));
      });
    });
  });
}
