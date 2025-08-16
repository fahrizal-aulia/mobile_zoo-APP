// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'markers.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MarkerModelAdapter extends TypeAdapter<MarkerModel> {
  @override
  final int typeId = 1;

  @override
  MarkerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MarkerModel(
      id: fields[0] as int,
      namaMarker: fields[1] as String,
      coordinates: fields[2] as LatLng,
      tipe: fields[3] as String,
      iconUrl: fields[4] as String,
      kategoriTempat: fields[5] as String,
      namaDetail: fields[6] as String?,
      deskripsi: fields[7] as String?,
      gambarDetailUrl: fields[8] as String?,
      namaLatin: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MarkerModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.namaMarker)
      ..writeByte(2)
      ..write(obj.coordinates)
      ..writeByte(3)
      ..write(obj.tipe)
      ..writeByte(4)
      ..write(obj.iconUrl)
      ..writeByte(5)
      ..write(obj.kategoriTempat)
      ..writeByte(6)
      ..write(obj.namaDetail)
      ..writeByte(7)
      ..write(obj.deskripsi)
      ..writeByte(8)
      ..write(obj.gambarDetailUrl)
      ..writeByte(9)
      ..write(obj.namaLatin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
