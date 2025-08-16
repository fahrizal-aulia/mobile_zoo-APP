// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'souvenir_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SouvenirModelAdapter extends TypeAdapter<SouvenirModel> {
  @override
  final int typeId = 3;

  @override
  SouvenirModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SouvenirModel(
      id: fields[0] as int,
      namaSouvenir: fields[1] as String,
      imageUrl: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SouvenirModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.namaSouvenir)
      ..writeByte(2)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SouvenirModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
