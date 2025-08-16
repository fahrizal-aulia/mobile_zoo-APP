import 'package:hive/hive.dart';

part 'tiket_model.g.dart';

@HiveType(typeId: 5)
class TiketModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String namaTiket;

  @HiveField(2)
  final String imageUrl;

  const TiketModel({
    required this.id,
    required this.namaTiket,
    required this.imageUrl,
  });

  factory TiketModel.fromJson(Map<String, dynamic> json) {
    String imageUrl = "https://kbs.simdabesmiwa.id${json['gambar_tiket_url']}";
    return TiketModel(
      id: json['id'],
      namaTiket: json['nama_tiket'] ?? 'Info Tiket',
      imageUrl: imageUrl,
    );
  }
}
