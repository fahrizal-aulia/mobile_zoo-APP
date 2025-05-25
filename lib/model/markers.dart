import 'package:latlong2/latlong.dart';

class MarkerModel {
  final int? id;
  final String? nama_marker;
  final LatLng coordinates;
  final int? id_kategori;
  final String? gambar;
  final String? deskripsi;

  MarkerModel({
    this.id,
    this.nama_marker,
    required this.coordinates,
    this.gambar,
    this.id_kategori,
    this.deskripsi,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_marker': nama_marker,
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      'id_kategori': id_kategori,
      'gambar': gambar,
      'deskripsi': deskripsi,
    };
  }

  factory MarkerModel.fromJson(Map<String, dynamic> json) {
    final latitude = double.tryParse(json['latitude'].toString()) ?? 0.0;
    final longitude = double.tryParse(json['longitude'].toString()) ?? 0.0;

    return MarkerModel(
      id: json['id'],
      nama_marker: json['nama_marker'],
      id_kategori: json['id_kategori'],
      coordinates: LatLng(latitude, longitude),
      gambar: json['gambar'],
      deskripsi: json['deskripsi'],
    );
  }

  String getKategory() {
    switch (id_kategori) {
      case 1:
        return 'Hewan';
      case 2:
        return 'Fasilitas Umum';
      case 3:
        return 'Tenan Makanan';
      default:
        return 'Semua';
    }
  }
}
