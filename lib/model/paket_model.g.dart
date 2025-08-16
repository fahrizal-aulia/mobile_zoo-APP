// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paket_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaketModelAdapter extends TypeAdapter<PaketModel> {
  @override
  final int typeId = 4;

  @override
  PaketModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaketModel(
      id: fields[0] as int,
      namaPaket: fields[1] as String,
      imageUrl: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PaketModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.namaPaket)
      ..writeByte(2)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaketModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
