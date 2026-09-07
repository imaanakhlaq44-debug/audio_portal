// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_member.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FamilyMemberAdapter extends TypeAdapter<FamilyMember> {
  @override
  final int typeId = 4;

  @override
  FamilyMember read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FamilyMember(
      id: fields[0] as String,
      name: fields[1] as String,
      role: fields[2] as MemberRole,
      avatarUrl: fields[3] as String,
      totalPoints: fields[4] as int,
      completedTasksCount: fields[5] as int,
      joinedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FamilyMember obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.role)
      ..writeByte(3)
      ..write(obj.avatarUrl)
      ..writeByte(4)
      ..write(obj.totalPoints)
      ..writeByte(5)
      ..write(obj.completedTasksCount)
      ..writeByte(6)
      ..write(obj.joinedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FamilyMemberAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MemberRoleAdapter extends TypeAdapter<MemberRole> {
  @override
  final int typeId = 5;

  @override
  MemberRole read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MemberRole.parent;
      case 1:
        return MemberRole.child;
      case 2:
        return MemberRole.elder;
      default:
        return MemberRole.parent;
    }
  }

  @override
  void write(BinaryWriter writer, MemberRole obj) {
    switch (obj) {
      case MemberRole.parent:
        writer.writeByte(0);
        break;
      case MemberRole.child:
        writer.writeByte(1);
        break;
      case MemberRole.elder:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberRoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
