import 'package:flutter_test/flutter_test.dart';
import 'package:taskify/data/models/task_model.dart';
import 'package:taskify/domain/entities/task.dart';

void main() {
  group('TaskModel Tests', () {
    late TaskModel testTaskModel;
    late Task testTask;
    late DateTime testDate;
    late Map<String, dynamic> testJson;

    setUp(() {
      testDate = DateTime(2024, 1, 1, 12, 0, 0);

      testTaskModel = TaskModel(id: 'test-id', title: 'Test Task', description: 'Test Description', isCompleted: false, createdAt: testDate, updatedAt: testDate, priority: 2);

      testTask = Task(id: 'test-id', title: 'Test Task', description: 'Test Description', isCompleted: false, createdAt: testDate, updatedAt: testDate, priority: 2);

      testJson = {
        'id': 'test-id',
        'title': 'Test Task',
        'description': 'Test Description',
        'isCompleted': false,
        'createdAt': testDate.millisecondsSinceEpoch,
        'updatedAt': testDate.millisecondsSinceEpoch,
        'priority': 2,
      };
    });

    group('Constructor Tests', () {
      test('should create TaskModel with all properties', () {
        expect(testTaskModel.id, equals('test-id'));
        expect(testTaskModel.title, equals('Test Task'));
        expect(testTaskModel.description, equals('Test Description'));
        expect(testTaskModel.isCompleted, equals(false));
        expect(testTaskModel.createdAt, equals(testDate));
        expect(testTaskModel.updatedAt, equals(testDate));
        expect(testTaskModel.priority, equals(2));
      });

      test('should create TaskModel with default priority', () {
        final taskModel = TaskModel(id: 'test-id', title: 'Test Task', description: 'Test Description', isCompleted: false, createdAt: testDate, updatedAt: testDate);

        expect(taskModel.priority, equals(1));
      });

      test('should extend Task entity', () {
        expect(testTaskModel, isA<Task>());
      });
    });

    group('FromTask Factory Tests', () {
      test('should create TaskModel from Task entity', () {
        final taskModel = TaskModel.fromTask(testTask);

        expect(taskModel.id, equals(testTask.id));
        expect(taskModel.title, equals(testTask.title));
        expect(taskModel.description, equals(testTask.description));
        expect(taskModel.isCompleted, equals(testTask.isCompleted));
        expect(taskModel.createdAt, equals(testTask.createdAt));
        expect(taskModel.updatedAt, equals(testTask.updatedAt));
        expect(taskModel.priority, equals(testTask.priority));
      });

      test('should preserve all Task properties', () {
        final completedTask = testTask.copyWith(isCompleted: true, priority: 3);
        final taskModel = TaskModel.fromTask(completedTask);

        expect(taskModel.isCompleted, equals(true));
        expect(taskModel.priority, equals(3));
      });
    });

    group('FromJson Factory Tests', () {
      test('should create TaskModel from valid JSON', () {
        final taskModel = TaskModel.fromJson(testJson);

        expect(taskModel.id, equals('test-id'));
        expect(taskModel.title, equals('Test Task'));
        expect(taskModel.description, equals('Test Description'));
        expect(taskModel.isCompleted, equals(false));
        expect(taskModel.createdAt, equals(testDate));
        expect(taskModel.updatedAt, equals(testDate));
        expect(taskModel.priority, equals(2));
      });

      test('should handle JSON without priority field', () {
        final jsonWithoutPriority = Map<String, dynamic>.from(testJson);
        jsonWithoutPriority.remove('priority');

        final taskModel = TaskModel.fromJson(jsonWithoutPriority);

        expect(taskModel.priority, equals(1)); // Default priority
      });

      test('should handle JSON with null priority', () {
        final jsonWithNullPriority = Map<String, dynamic>.from(testJson);
        jsonWithNullPriority['priority'] = null;

        final taskModel = TaskModel.fromJson(jsonWithNullPriority);

        expect(taskModel.priority, equals(1)); // Default priority
      });

      test('should create correct DateTime from timestamps', () {
        final futureDate = DateTime(2025, 6, 15, 10, 30, 0);
        final jsonWithDifferentDates = Map<String, dynamic>.from(testJson);
        jsonWithDifferentDates['createdAt'] = testDate.millisecondsSinceEpoch;
        jsonWithDifferentDates['updatedAt'] = futureDate.millisecondsSinceEpoch;

        final taskModel = TaskModel.fromJson(jsonWithDifferentDates);

        expect(taskModel.createdAt, equals(testDate));
        expect(taskModel.updatedAt, equals(futureDate));
      });
    });

    group('ToJson Tests', () {
      test('should convert TaskModel to JSON correctly', () {
        final json = testTaskModel.toJson();

        expect(json['id'], equals('test-id'));
        expect(json['title'], equals('Test Task'));
        expect(json['description'], equals('Test Description'));
        expect(json['isCompleted'], equals(false));
        expect(json['createdAt'], equals(testDate.millisecondsSinceEpoch));
        expect(json['updatedAt'], equals(testDate.millisecondsSinceEpoch));
        expect(json['priority'], equals(2));
      });

      test('should handle completed task correctly', () {
        final completedTaskModel = testTaskModel.copyWith(isCompleted: true);
        final json = completedTaskModel.toJson();

        expect(json['isCompleted'], equals(true));
      });

      test('should handle different priorities correctly', () {
        final highPriorityTask = testTaskModel.copyWith(priority: 3);
        final json = highPriorityTask.toJson();

        expect(json['priority'], equals(3));
      });

      test('should convert timestamps correctly', () {
        final json = testTaskModel.toJson();
        final recreatedDate = DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int);

        expect(recreatedDate, equals(testDate));
      });
    });

    group('ToTask Tests', () {
      test('should convert TaskModel to Task entity', () {
        final task = testTaskModel.toTask();

        expect(task, isA<Task>());
        expect(task.id, equals(testTaskModel.id));
        expect(task.title, equals(testTaskModel.title));
        expect(task.description, equals(testTaskModel.description));
        expect(task.isCompleted, equals(testTaskModel.isCompleted));
        expect(task.createdAt, equals(testTaskModel.createdAt));
        expect(task.updatedAt, equals(testTaskModel.updatedAt));
        expect(task.priority, equals(testTaskModel.priority));
      });

      test('should preserve all properties during conversion', () {
        final completedTaskModel = testTaskModel.copyWith(isCompleted: true, priority: 3, title: 'Updated Title');
        final task = completedTaskModel.toTask();

        expect(task.isCompleted, equals(true));
        expect(task.priority, equals(3));
        expect(task.title, equals('Updated Title'));
      });
    });

    group('CopyWith Tests', () {
      test('should copy TaskModel with updated title', () {
        final updatedTaskModel = testTaskModel.copyWith(title: 'Updated Title');

        expect(updatedTaskModel.title, equals('Updated Title'));
        expect(updatedTaskModel.id, equals(testTaskModel.id));
        expect(updatedTaskModel.description, equals(testTaskModel.description));
        expect(updatedTaskModel, isA<TaskModel>());
      });

      test('should copy TaskModel with updated completion status', () {
        final updatedTaskModel = testTaskModel.copyWith(isCompleted: true);

        expect(updatedTaskModel.isCompleted, equals(true));
        expect(updatedTaskModel.title, equals(testTaskModel.title));
        expect(updatedTaskModel, isA<TaskModel>());
      });

      test('should copy TaskModel with all properties updated', () {
        final newDate = DateTime(2024, 6, 15);
        final updatedTaskModel = testTaskModel.copyWith(
          id: 'new-id',
          title: 'New Title',
          description: 'New Description',
          isCompleted: true,
          createdAt: newDate,
          updatedAt: newDate,
          priority: 3,
        );

        expect(updatedTaskModel.id, equals('new-id'));
        expect(updatedTaskModel.title, equals('New Title'));
        expect(updatedTaskModel.description, equals('New Description'));
        expect(updatedTaskModel.isCompleted, equals(true));
        expect(updatedTaskModel.createdAt, equals(newDate));
        expect(updatedTaskModel.updatedAt, equals(newDate));
        expect(updatedTaskModel.priority, equals(3));
        expect(updatedTaskModel, isA<TaskModel>());
      });
    });

    group('ToggleCompleted Tests', () {
      test('should toggle completion and return TaskModel', () {
        final toggledTaskModel = testTaskModel.toggleCompleted();

        expect(toggledTaskModel.isCompleted, equals(true));
        expect(toggledTaskModel.title, equals(testTaskModel.title));
        expect(toggledTaskModel.id, equals(testTaskModel.id));
        expect(toggledTaskModel, isA<TaskModel>());
        expect(toggledTaskModel.updatedAt.isAfter(testTaskModel.updatedAt), isTrue);
      });

      test('should toggle from completed to incomplete', () {
        final completedTaskModel = testTaskModel.copyWith(isCompleted: true);
        final toggledTaskModel = completedTaskModel.toggleCompleted();

        expect(toggledTaskModel.isCompleted, equals(false));
        expect(toggledTaskModel, isA<TaskModel>());
      });
    });

    group('JSON Serialization Round Trip Tests', () {
      test('should maintain data integrity through JSON round trip', () {
        // TaskModel -> JSON -> TaskModel
        final originalTaskModel = testTaskModel;
        final json = originalTaskModel.toJson();
        final recreatedTaskModel = TaskModel.fromJson(json);

        expect(recreatedTaskModel.id, equals(originalTaskModel.id));
        expect(recreatedTaskModel.title, equals(originalTaskModel.title));
        expect(recreatedTaskModel.description, equals(originalTaskModel.description));
        expect(recreatedTaskModel.isCompleted, equals(originalTaskModel.isCompleted));
        expect(recreatedTaskModel.createdAt, equals(originalTaskModel.createdAt));
        expect(recreatedTaskModel.updatedAt, equals(originalTaskModel.updatedAt));
        expect(recreatedTaskModel.priority, equals(originalTaskModel.priority));
      });

      test('should maintain data integrity through Task conversion round trip', () {
        // TaskModel -> Task -> TaskModel
        final originalTaskModel = testTaskModel;
        final task = originalTaskModel.toTask();
        final recreatedTaskModel = TaskModel.fromTask(task);

        expect(recreatedTaskModel.id, equals(originalTaskModel.id));
        expect(recreatedTaskModel.title, equals(originalTaskModel.title));
        expect(recreatedTaskModel.description, equals(originalTaskModel.description));
        expect(recreatedTaskModel.isCompleted, equals(originalTaskModel.isCompleted));
        expect(recreatedTaskModel.createdAt, equals(originalTaskModel.createdAt));
        expect(recreatedTaskModel.updatedAt, equals(originalTaskModel.updatedAt));
        expect(recreatedTaskModel.priority, equals(originalTaskModel.priority));
      });
    });

    group('Edge Cases', () {
      test('should handle empty strings', () {
        final taskModel = TaskModel(id: '', title: '', description: '', isCompleted: false, createdAt: testDate, updatedAt: testDate);

        expect(taskModel.id, equals(''));
        expect(taskModel.title, equals(''));
        expect(taskModel.description, equals(''));
      });

      test('should handle very long strings', () {
        final longString = 'A' * 10000;
        final taskModel = TaskModel(id: longString, title: longString, description: longString, isCompleted: false, createdAt: testDate, updatedAt: testDate);

        expect(taskModel.id, equals(longString));
        expect(taskModel.title, equals(longString));
        expect(taskModel.description, equals(longString));
      });

      test('should handle extreme priority values', () {
        final taskModel = TaskModel(id: 'test', title: 'test', description: 'test', isCompleted: false, createdAt: testDate, updatedAt: testDate, priority: -100);

        expect(taskModel.priority, equals(-100));
      });

      test('should handle special characters in strings', () {
        const specialString = '!@#\$%^&*()_+{}[]|\\:";\'<>?,./ 🎉💻📱';
        final taskModel = TaskModel(id: specialString, title: specialString, description: specialString, isCompleted: false, createdAt: testDate, updatedAt: testDate);

        expect(taskModel.id, equals(specialString));
        expect(taskModel.title, equals(specialString));
        expect(taskModel.description, equals(specialString));
      });
    });
  });
}
