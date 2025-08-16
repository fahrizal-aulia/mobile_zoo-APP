// File: lib/model/latlng_adapter.dart
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';

class LatLngAdapter extends TypeAdapter<LatLng> {
  @override
  final int typeId = 100; // ID unik untuk adapter ini

  @override
  LatLng read(BinaryReader reader) {
    final lat = reader.readDouble();
    final lng = reader.readDouble();
    return LatLng(lat, lng);
  }

  @override
  void write(BinaryWriter writer, LatLng obj) {
    writer.writeDouble(obj.latitude);
    writer.writeDouble(obj.longitude);
  }
}
