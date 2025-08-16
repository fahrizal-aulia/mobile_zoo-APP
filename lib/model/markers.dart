// File: lib/model/markers.dart
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';

part 'markers.g.dart';

@HiveType(typeId: 1) // ID unik untuk class MarkerModel
class MarkerModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String namaMarker;

  @HiveField(2)
  final LatLng coordinates;

  @HiveField(3)
  final String tipe;

  @HiveField(4)
  final String iconUrl;

  @HiveField(5)
  final String kategoriTempat;

  @HiveField(6)
  final String? namaDetail;

  @HiveField(7)
  final String? deskripsi;

  @HiveField(8)
  final String? gambarDetailUrl;

  @HiveField(9)
  final String? namaLatin;

  MarkerModel({
    required this.id,
    required this.namaMarker,
    required this.coordinates,
    required this.tipe,
    required this.iconUrl,
    required this.kategoriTempat,
    this.namaDetail,
    this.deskripsi,
    this.gambarDetailUrl,
    this.namaLatin,
  });

  factory MarkerModel.fromJson(Map<String, dynamic> json) {
    const String baseUrl = "https://kbs.simdabesmiwa.id";
    final detail = json['detail'];
    final tipe = json['tipe'] ?? 'Unknown';

    String kategoriTempat;
    if (detail != null && detail['kategori_tempat'] != null) {
      kategoriTempat = detail['kategori_tempat'];
    } else {
      kategoriTempat = tipe;
    }

    String? namaDetail, deskripsi, gambarDetailUrl, namaLatin;
    if (detail != null) {
      if (tipe == 'Hewan') {
        namaDetail = detail['nama'];
        deskripsi = detail['deskripsi'];
        gambarDetailUrl = detail['gambar_hewan_url'] != null
            ? baseUrl + detail['gambar_hewan_url']
            : null;
        namaLatin = detail['nama_latin'];
      } else {
        namaDetail = detail['nama_fasilitas'];
        deskripsi = detail['deskripsi'];
        gambarDetailUrl = detail['gambar_fasilitas_url'] != null
            ? baseUrl + detail['gambar_fasilitas_url']
            : null;
      }
    }

    return MarkerModel(
      id: json['id'],
      namaMarker: json['nama_marker'] ?? 'Tanpa Nama',
      coordinates: LatLng(
        double.tryParse(json['latitude'].toString()) ?? 0.0,
        double.tryParse(json['longitude'].toString()) ?? 0.0,
      ),
      tipe: tipe,
      iconUrl:
          json['ikon']?['url'] != null ? baseUrl + json['ikon']['url'] : '',
      kategoriTempat: kategoriTempat,
      namaDetail: namaDetail,
      deskripsi: deskripsi,
      gambarDetailUrl: gambarDetailUrl,
      namaLatin: namaLatin,
    );
  }

  String getKategory() {
    return kategoriTempat;
  }
}
