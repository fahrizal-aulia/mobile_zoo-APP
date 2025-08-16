// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spot_foto_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpotFotoModelAdapter extends TypeAdapter<SpotFotoModel> {
  @override
  final int typeId = 2;

  @override
  SpotFotoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SpotFotoModel(
      id: fields[0] as int,
      namaSpot: fields[1] as String,
      imageUrl: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SpotFotoModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.namaSpot)
      ..writeByte(2)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpotFotoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
