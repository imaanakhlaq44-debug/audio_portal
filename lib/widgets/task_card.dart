import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onTap,
  });

  Color _getPriorityColor() {
    switch (task.priority) {
      case Priority.high:
        return AppTheme.errorRed;
      case Priority.medium:
        return AppTheme.warningOrange;
      case Priority.low:
        return AppTheme.successGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final member = StorageService.getMember(task.assignedTo);
    final timeFormat = DateFormat('h:mm a');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Task type icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    task.type.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Task details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                              decoration: task.isCompleted 
                                  ? TextDecoration.lineThrough 
                                  : null,
                            ),
                          ),
                        ),
                        // Priority indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor().withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            task.priority.emoji,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (member != null) ...[
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: AppTheme.mintGreen.withValues(alpha: 0.3),
                            child: Text(
                              member.name[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            member.name,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textMedium,
                            ),
                          ),
                        ],
                        const SizedBox(width: 12),
                        if (task.dueDate != null) ...[
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: task.isOverdue 
                                ? AppTheme.errorRed 
                                : AppTheme.textMedium,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeFormat.format(task.dueDate!),
                            style: TextStyle(
                              fontSize: 13,
                              color: task.isOverdue 
                                  ? AppTheme.errorRed 
                                  : AppTheme.textMedium,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: AppTheme.warningOrange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${task.points}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.warningOrange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              
              // Completion checkbox
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: task.isCompleted 
                        ? AppTheme.successGreen 
                        : Colors.transparent,
                    border: Border.all(
                      color: task.isCompleted 
                          ? AppTheme.successGreen 
                          : AppTheme.textLight,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: task.isCompleted
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
