import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  TaskType type;

  @HiveField(4)
  Priority priority;

  @HiveField(5)
  String assignedTo;

  @HiveField(6)
  DateTime? dueDate;

  @HiveField(7)
  RepeatFrequency repeatFrequency;

  @HiveField(8)
  bool isCompleted;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime? completedAt;

  @HiveField(11)
  int points;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.type,
    this.priority = Priority.medium,
    required this.assignedTo,
    this.dueDate,
    this.repeatFrequency = RepeatFrequency.none,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.points = 10,
  });

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }
}

@HiveType(typeId: 1)
enum TaskType {
  @HiveField(0)
  cleaning,
  @HiveField(1)
  cooking,
  @HiveField(2)
  laundry,
  @HiveField(3)
  organizing,
  @HiveField(4)
  shopping,
  @HiveField(5)
  petCare,
  @HiveField(6)
  gardening,
  @HiveField(7)
  maintenance,
  @HiveField(8)
  other,
}

@HiveType(typeId: 2)
enum Priority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}

@HiveType(typeId: 3)
enum RepeatFrequency {
  @HiveField(0)
  none,
  @HiveField(1)
  daily,
  @HiveField(2)
  weekly,
  @HiveField(3)
  monthly,
}

extension TaskTypeExtension on TaskType {
  String get displayName {
    switch (this) {
      case TaskType.cleaning:
        return 'Cleaning';
      case TaskType.cooking:
        return 'Cooking';
      case TaskType.laundry:
        return 'Laundry';
      case TaskType.organizing:
        return 'Organizing';
      case TaskType.shopping:
        return 'Shopping';
      case TaskType.petCare:
        return 'Pet Care';
      case TaskType.gardening:
        return 'Gardening';
      case TaskType.maintenance:
        return 'Maintenance';
      case TaskType.other:
        return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case TaskType.cleaning:
        return '🧹';
      case TaskType.cooking:
        return '🍳';
      case TaskType.laundry:
        return '👕';
      case TaskType.organizing:
        return '📦';
      case TaskType.shopping:
        return '🛒';
      case TaskType.petCare:
        return '🐕';
      case TaskType.gardening:
        return '🌱';
      case TaskType.maintenance:
        return '🔧';
      case TaskType.other:
        return '📝';
    }
  }
}

extension PriorityExtension on Priority {
  String get displayName {
    switch (this) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
    }
  }

  String get emoji {
    switch (this) {
      case Priority.low:
        return '🟢';
      case Priority.medium:
        return '🟡';
      case Priority.high:
        return '🔴';
    }
  }
}
