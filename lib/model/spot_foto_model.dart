import 'package:hive/hive.dart';

part 'spot_foto_model.g.dart';

@HiveType(typeId: 2)
class SpotFotoModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String namaSpot;

  @HiveField(2)
  final String imageUrl;

  SpotFotoModel(
      {required this.id, required this.namaSpot, required this.imageUrl});

  factory SpotFotoModel.fromJson(Map<String, dynamic> json) {
    String imageUrl = "https://kbs.simdabesmiwa.id${json['gambar_spot_url']}";
    return SpotFotoModel(
      id: json['id'],
      namaSpot: json['nama_spot'] ?? 'Tanpa Nama',
      imageUrl: imageUrl,
    );
  }
}
