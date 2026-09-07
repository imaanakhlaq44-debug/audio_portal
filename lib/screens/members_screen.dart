import 'package:flutter/material.dart';
import '../models/family_member.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  List<FamilyMember> _members = [];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  void _loadMembers() {
    setState(() {
      _members = StorageService.getAllMembers()
        ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
    });
  }

  int _getMemberRank(int index) {
    if (index == 0) return 1;
    if (_members[index].totalPoints == _members[index - 1].totalPoints) {
      return _getMemberRank(index - 1);
    }
    return index + 1;
  }

  String _getRankEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Members'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadMembers();
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _members.length,
          itemBuilder: (context, index) {
            final member = _members[index];
            final rank = _getMemberRank(index);
            final rankEmoji = _getRankEmoji(rank);
            
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Rank badge
                    if (rankEmoji.isNotEmpty)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.warningOrange.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            rankEmoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundGray,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '#$rank',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textMedium,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 16),
                    
                    // Avatar
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.2),
                      child: Text(
                        member.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Member info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                member.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                member.role.emoji,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 16,
                                color: AppTheme.successGreen,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${member.completedTasksCount} tasks',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textMedium,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: AppTheme.warningOrange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${member.totalPoints} pts',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.warningOrange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Arrow icon
                    const Icon(
                      Icons.chevron_right,
                      color: AppTheme.textLight,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add member feature coming soon!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
