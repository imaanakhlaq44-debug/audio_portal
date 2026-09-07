// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as TaskType,
      priority: fields[4] as Priority,
      assignedTo: fields[5] as String,
      dueDate: fields[6] as DateTime?,
      repeatFrequency: fields[7] as RepeatFrequency,
      isCompleted: fields[8] as bool,
      createdAt: fields[9] as DateTime,
      completedAt: fields[10] as DateTime?,
      points: fields[11] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.assignedTo)
      ..writeByte(6)
      ..write(obj.dueDate)
      ..writeByte(7)
      ..write(obj.repeatFrequency)
      ..writeByte(8)
      ..write(obj.isCompleted)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.completedAt)
      ..writeByte(11)
      ..write(obj.points);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskTypeAdapter extends TypeAdapter<TaskType> {
  @override
  final int typeId = 1;

  @override
  TaskType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskType.cleaning;
      case 1:
        return TaskType.cooking;
      case 2:
        return TaskType.laundry;
      case 3:
        return TaskType.organizing;
      case 4:
        return TaskType.shopping;
      case 5:
        return TaskType.petCare;
      case 6:
        return TaskType.gardening;
      case 7:
        return TaskType.maintenance;
      case 8:
        return TaskType.other;
      default:
        return TaskType.cleaning;
    }
  }

  @override
  void write(BinaryWriter writer, TaskType obj) {
    switch (obj) {
      case TaskType.cleaning:
        writer.writeByte(0);
        break;
      case TaskType.cooking:
        writer.writeByte(1);
        break;
      case TaskType.laundry:
        writer.writeByte(2);
        break;
      case TaskType.organizing:
        writer.writeByte(3);
        break;
      case TaskType.shopping:
        writer.writeByte(4);
        break;
      case TaskType.petCare:
        writer.writeByte(5);
        break;
      case TaskType.gardening:
        writer.writeByte(6);
        break;
      case TaskType.maintenance:
        writer.writeByte(7);
        break;
      case TaskType.other:
        writer.writeByte(8);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PriorityAdapter extends TypeAdapter<Priority> {
  @override
  final int typeId = 2;

  @override
  Priority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Priority.low;
      case 1:
        return Priority.medium;
      case 2:
        return Priority.high;
      default:
        return Priority.medium;
    }
  }

  @override
  void write(BinaryWriter writer, Priority obj) {
    switch (obj) {
      case Priority.low:
        writer.writeByte(0);
        break;
      case Priority.medium:
        writer.writeByte(1);
        break;
      case Priority.high:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RepeatFrequencyAdapter extends TypeAdapter<RepeatFrequency> {
  @override
  final int typeId = 3;

  @override
  RepeatFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RepeatFrequency.none;
      case 1:
        return RepeatFrequency.daily;
      case 2:
        return RepeatFrequency.weekly;
      case 3:
        return RepeatFrequency.monthly;
      default:
        return RepeatFrequency.none;
    }
  }

  @override
  void write(BinaryWriter writer, RepeatFrequency obj) {
    switch (obj) {
      case RepeatFrequency.none:
        writer.writeByte(0);
        break;
      case RepeatFrequency.daily:
        writer.writeByte(1);
        break;
      case RepeatFrequency.weekly:
        writer.writeByte(2);
        break;
      case RepeatFrequency.monthly:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepeatFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
