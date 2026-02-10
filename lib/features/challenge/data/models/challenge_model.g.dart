// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChallengeSubtaskAdapter extends TypeAdapter<ChallengeSubtask> {
  @override
  final int typeId = 3;

  @override
  ChallengeSubtask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChallengeSubtask(
      id: fields[0] as String,
      title: fields[1] as String,
      isCompleted: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ChallengeSubtask obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeSubtaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChallengeMilestoneAdapter extends TypeAdapter<ChallengeMilestone> {
  @override
  final int typeId = 2;

  @override
  ChallengeMilestone read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChallengeMilestone(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      durationDays: fields[3] as int,
      isCompleted: fields[4] as bool,
      subtasks: (fields[6] as List).cast<ChallengeSubtask>(),
    );
  }

  @override
  void write(BinaryWriter writer, ChallengeMilestone obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.durationDays)
      ..writeByte(4)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.subtasks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeMilestoneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChallengeModelAdapter extends TypeAdapter<ChallengeModel> {
  @override
  final int typeId = 1;

  @override
  ChallengeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChallengeModel(
      id: fields[0] as String,
      name: fields[1] as String,
      duration: fields[2] as int,
      threatLevel: fields[3] as String,
      consequenceType: fields[4] as String,
      specificConsequence: fields[5] as String,
      startDate: fields[6] as DateTime,
      completedDates: (fields[7] as List).cast<DateTime>(),
      roadmap: (fields[8] as List).cast<ChallengeMilestone>(),
    );
  }

  @override
  void write(BinaryWriter writer, ChallengeModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.duration)
      ..writeByte(3)
      ..write(obj.threatLevel)
      ..writeByte(4)
      ..write(obj.consequenceType)
      ..writeByte(5)
      ..write(obj.specificConsequence)
      ..writeByte(6)
      ..write(obj.startDate)
      ..writeByte(7)
      ..write(obj.completedDates)
      ..writeByte(8)
      ..write(obj.roadmap);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
