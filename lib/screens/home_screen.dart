import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/family_member.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/task_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _todayTasks = [];
  List<FamilyMember> _members = [];
  int _totalFamilyPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final allTasks = StorageService.getAllTasks();
    final members = StorageService.getAllMembers();
    
    setState(() {
      _todayTasks = allTasks.where((task) => 
        !task.isCompleted && (task.isDueToday || task.isOverdue)
      ).toList();
      _members = members;
      _totalFamilyPoints = members.fold(0, (sum, member) => sum + member.totalPoints);
    });
  }

  void _toggleTaskCompletion(Task task) {
    task.isCompleted = !task.isCompleted;
    if (task.isCompleted) {
      task.completedAt = DateTime.now();
      
      // Update member points
      final member = StorageService.getMember(task.assignedTo);
      if (member != null) {
        member.totalPoints += task.points;
        member.completedTasksCount += 1;
        StorageService.updateMember(member);
      }
    } else {
      task.completedAt = null;
      
      // Revert member points
      final member = StorageService.getMember(task.assignedTo);
      if (member != null) {
        member.totalPoints -= task.points;
        member.completedTasksCount -= 1;
        StorageService.updateMember(member);
      }
    }
    
    StorageService.updateTask(task);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMM d');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chore Tracker'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.stars, color: AppTheme.warningOrange, size: 20),
                const SizedBox(width: 4),
                Text(
                  '$_totalFamilyPoints',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and greeting
              Text(
                dateFormat.format(now),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You have ${_todayTasks.length} tasks today',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textMedium,
                ),
              ),
              const SizedBox(height: 24),
              
              // Today's tasks section
              if (_todayTasks.isEmpty)
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: AppTheme.successGreen.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No tasks for today!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enjoy your free time 🌸',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today\'s Tasks',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _todayTasks.length,
                      itemBuilder: (context, index) {
                        return TaskCard(
                          task: _todayTasks[index],
                          onToggle: () => _toggleTaskCompletion(_todayTasks[index]),
                          onTap: () {
                            // TODO: Show task details
                          },
                        );
                      },
                    ),
                  ],
                ),
              
              const SizedBox(height: 32),
              
              // Family members section
              const Text(
                'Family Members',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _members.length,
                  itemBuilder: (context, index) {
                    final member = _members[index];
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.2),
                                child: Text(
                                  member.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryOrange,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                member.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 14,
                                    color: AppTheme.warningOrange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${member.totalPoints}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new task
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
}
