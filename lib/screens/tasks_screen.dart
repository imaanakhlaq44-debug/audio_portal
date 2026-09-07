import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/task_card.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task> _tasks = [];
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      _tasks = StorageService.getAllTasks();
    });
  }

  List<Task> get _filteredTasks {
    switch (_filter) {
      case 'pending':
        return _tasks.where((task) => !task.isCompleted).toList();
      case 'completed':
        return _tasks.where((task) => task.isCompleted).toList();
      case 'overdue':
        return _tasks.where((task) => task.isOverdue).toList();
      default:
        return _tasks;
    }
  }

  void _toggleTaskCompletion(Task task) {
    task.isCompleted = !task.isCompleted;
    if (task.isCompleted) {
      task.completedAt = DateTime.now();
      final member = StorageService.getMember(task.assignedTo);
      if (member != null) {
        member.totalPoints += task.points;
        member.completedTasksCount += 1;
        StorageService.updateMember(member);
      }
    } else {
      task.completedAt = null;
      final member = StorageService.getMember(task.assignedTo);
      if (member != null) {
        member.totalPoints -= task.points;
        member.completedTasksCount -= 1;
        StorageService.updateMember(member);
      }
    }
    StorageService.updateTask(task);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _filteredTasks;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tasks'),
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('All', 'all', _tasks.length),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Pending',
                  'pending',
                  _tasks.where((t) => !t.isCompleted).length,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Completed',
                  'completed',
                  _tasks.where((t) => t.isCompleted).length,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Overdue',
                  'overdue',
                  _tasks.where((t) => t.isOverdue).length,
                ),
              ],
            ),
          ),
          
          // Tasks list
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 80,
                          color: AppTheme.textLight.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks found',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppTheme.textMedium,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      _loadTasks();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        return TaskCard(
                          task: filteredTasks[index],
                          onToggle: () => _toggleTaskCompletion(filteredTasks[index]),
                          onTap: () {
                            // TODO: Show task details
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add task feature coming soon!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _filter == value;
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Colors.white.withValues(alpha: 0.3)
                  : AppTheme.backgroundGray,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filter = value;
        });
      },
      selectedColor: AppTheme.primaryOrange,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textDark,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      showCheckmark: false,
    );
  }
}
