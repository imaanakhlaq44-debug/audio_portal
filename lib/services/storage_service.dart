import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../models/family_member.dart';

class StorageService {
  static const String tasksBoxName = 'tasks';
  static const String membersBoxName = 'members';
  static const String settingsBoxName = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(TaskTypeAdapter());
    Hive.registerAdapter(PriorityAdapter());
    Hive.registerAdapter(RepeatFrequencyAdapter());
    Hive.registerAdapter(FamilyMemberAdapter());
    Hive.registerAdapter(MemberRoleAdapter());
    
    // Open boxes
    await Hive.openBox<Task>(tasksBoxName);
    await Hive.openBox<FamilyMember>(membersBoxName);
    await Hive.openBox(settingsBoxName);
    
    // Initialize default data if needed
    await _initializeDefaultData();
  }

  static Future<void> _initializeDefaultData() async {
    final membersBox = Hive.box<FamilyMember>(membersBoxName);
    
    // Create default family members if none exist
    if (membersBox.isEmpty) {
      final defaultMembers = [
        FamilyMember(
          id: 'member_1',
          name: 'Sarah',
          role: MemberRole.parent,
          avatarUrl: '',
          totalPoints: 150,
          completedTasksCount: 15,
          joinedAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        FamilyMember(
          id: 'member_2',
          name: 'Mike',
          role: MemberRole.parent,
          avatarUrl: '',
          totalPoints: 120,
          completedTasksCount: 12,
          joinedAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        FamilyMember(
          id: 'member_3',
          name: 'Emma',
          role: MemberRole.child,
          avatarUrl: '',
          totalPoints: 80,
          completedTasksCount: 8,
          joinedAt: DateTime.now().subtract(const Duration(days: 25)),
        ),
        FamilyMember(
          id: 'member_4',
          name: 'Jack',
          role: MemberRole.child,
          avatarUrl: '',
          totalPoints: 60,
          completedTasksCount: 6,
          joinedAt: DateTime.now().subtract(const Duration(days: 20)),
        ),
      ];
      
      for (var member in defaultMembers) {
        await membersBox.put(member.id, member);
      }
    }

    final tasksBox = Hive.box<Task>(tasksBoxName);
    
    // Create sample tasks if none exist
    if (tasksBox.isEmpty) {
      final now = DateTime.now();
      final sampleTasks = [
        Task(
          id: 'task_1',
          title: 'Clean the living room',
          description: 'Vacuum, dust, and organize',
          type: TaskType.cleaning,
          priority: Priority.high,
          assignedTo: 'member_1',
          dueDate: DateTime(now.year, now.month, now.day, 18, 0),
          repeatFrequency: RepeatFrequency.weekly,
          createdAt: now,
          points: 15,
        ),
        Task(
          id: 'task_2',
          title: 'Do the laundry',
          description: 'Wash, dry, and fold clothes',
          type: TaskType.laundry,
          priority: Priority.medium,
          assignedTo: 'member_2',
          dueDate: DateTime(now.year, now.month, now.day, 20, 0),
          repeatFrequency: RepeatFrequency.daily,
          createdAt: now,
          points: 10,
        ),
        Task(
          id: 'task_3',
          title: 'Prepare dinner',
          description: 'Cook a healthy meal for the family',
          type: TaskType.cooking,
          priority: Priority.high,
          assignedTo: 'member_1',
          dueDate: DateTime(now.year, now.month, now.day, 19, 0),
          repeatFrequency: RepeatFrequency.daily,
          createdAt: now,
          points: 20,
        ),
        Task(
          id: 'task_4',
          title: 'Feed the dog',
          description: 'Give Max his evening meal',
          type: TaskType.petCare,
          priority: Priority.high,
          assignedTo: 'member_3',
          dueDate: DateTime(now.year, now.month, now.day, 17, 0),
          repeatFrequency: RepeatFrequency.daily,
          createdAt: now,
          points: 5,
        ),
        Task(
          id: 'task_5',
          title: 'Take out trash',
          description: 'Empty all trash bins and take to curb',
          type: TaskType.cleaning,
          priority: Priority.medium,
          assignedTo: 'member_4',
          dueDate: DateTime(now.year, now.month, now.day, 21, 0),
          repeatFrequency: RepeatFrequency.weekly,
          createdAt: now,
          points: 8,
        ),
        Task(
          id: 'task_6',
          title: 'Water the plants',
          description: 'Water all indoor and outdoor plants',
          type: TaskType.gardening,
          priority: Priority.low,
          assignedTo: 'member_3',
          dueDate: DateTime(now.year, now.month, now.day + 1, 10, 0),
          repeatFrequency: RepeatFrequency.daily,
          createdAt: now,
          points: 5,
        ),
      ];
      
      for (var task in sampleTasks) {
        await tasksBox.put(task.id, task);
      }
    }
  }

  // Task operations
  static Future<void> addTask(Task task) async {
    final box = Hive.box<Task>(tasksBoxName);
    await box.put(task.id, task);
  }

  static Future<void> updateTask(Task task) async {
    final box = Hive.box<Task>(tasksBoxName);
    await box.put(task.id, task);
  }

  static Future<void> deleteTask(String taskId) async {
    final box = Hive.box<Task>(tasksBoxName);
    await box.delete(taskId);
  }

  static List<Task> getAllTasks() {
    final box = Hive.box<Task>(tasksBoxName);
    return box.values.toList();
  }

  static Task? getTask(String taskId) {
    final box = Hive.box<Task>(tasksBoxName);
    return box.get(taskId);
  }

  // Member operations
  static Future<void> addMember(FamilyMember member) async {
    final box = Hive.box<FamilyMember>(membersBoxName);
    await box.put(member.id, member);
  }

  static Future<void> updateMember(FamilyMember member) async {
    final box = Hive.box<FamilyMember>(membersBoxName);
    await box.put(member.id, member);
  }

  static Future<void> deleteMember(String memberId) async {
    final box = Hive.box<FamilyMember>(membersBoxName);
    await box.delete(memberId);
  }

  static List<FamilyMember> getAllMembers() {
    final box = Hive.box<FamilyMember>(membersBoxName);
    return box.values.toList();
  }

  static FamilyMember? getMember(String memberId) {
    final box = Hive.box<FamilyMember>(membersBoxName);
    return box.get(memberId);
  }
}
