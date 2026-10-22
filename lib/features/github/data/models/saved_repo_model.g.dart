// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_repo_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedRepoModelAdapter extends TypeAdapter<SavedRepoModel> {
  @override
  final typeId = 0;

  @override
  SavedRepoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedRepoModel(
      id: (fields[0] as num).toInt(),
      name: fields[1] as String,
      fullName: fields[2] as String,
      description: fields[3] as String,
      stargazersCount: (fields[4] as num).toInt(),
      language: fields[5] as String,
      ownerId: (fields[6] as num).toInt(),
      ownerLogin: fields[7] as String,
      ownerAvatarUrl: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SavedRepoModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.fullName)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.stargazersCount)
      ..writeByte(5)
      ..write(obj.language)
      ..writeByte(6)
      ..write(obj.ownerId)
      ..writeByte(7)
      ..write(obj.ownerLogin)
      ..writeByte(8)
      ..write(obj.ownerAvatarUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedRepoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
