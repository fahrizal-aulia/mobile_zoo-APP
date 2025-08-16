import 'package:hive/hive.dart';

part 'paket_model.g.dart';

@HiveType(typeId: 4)
class PaketModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String namaPaket;

  @HiveField(2)
  final String imageUrl;

  const PaketModel({
    required this.id,
    required this.namaPaket,
    required this.imageUrl,
  });

  factory PaketModel.fromJson(Map<String, dynamic> json) {
    String imageUrl = "https://kbs.simdabesmiwa.id${json['gambar_paket_url']}";
    return PaketModel(
      id: json['id'],
      namaPaket: json['nama_paket'] ?? 'Paket',
      imageUrl: imageUrl,
    );
  }
}
