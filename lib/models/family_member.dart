import 'package:hive/hive.dart';

part 'family_member.g.dart';

@HiveType(typeId: 4)
class FamilyMember extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  MemberRole role;

  @HiveField(3)
  String avatarUrl;

  @HiveField(4)
  int totalPoints;

  @HiveField(5)
  int completedTasksCount;

  @HiveField(6)
  DateTime joinedAt;

  FamilyMember({
    required this.id,
    required this.name,
    required this.role,
    this.avatarUrl = '',
    this.totalPoints = 0,
    this.completedTasksCount = 0,
    required this.joinedAt,
  });
}

@HiveType(typeId: 5)
enum MemberRole {
  @HiveField(0)
  parent,
  @HiveField(1)
  child,
  @HiveField(2)
  elder,
}

extension MemberRoleExtension on MemberRole {
  String get displayName {
    switch (this) {
      case MemberRole.parent:
        return 'Parent';
      case MemberRole.child:
        return 'Child';
      case MemberRole.elder:
        return 'Elder';
    }
  }

  String get emoji {
    switch (this) {
      case MemberRole.parent:
        return '👑';
      case MemberRole.child:
        return '👦';
      case MemberRole.elder:
        return '👴';
    }
  }
}
