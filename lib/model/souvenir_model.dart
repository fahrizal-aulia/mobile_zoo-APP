import 'package:hive/hive.dart';

part 'souvenir_model.g.dart';

@HiveType(typeId: 3)
class SouvenirModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String namaSouvenir;

  @HiveField(2)
  final String imageUrl;

  const SouvenirModel({
    required this.id,
    required this.namaSouvenir,
    required this.imageUrl,
  });

  factory SouvenirModel.fromJson(Map<String, dynamic> json) {
    String imageUrl =
        "https://kbs.simdabesmiwa.id${json['gambar_souvenir_url']}";
    return SouvenirModel(
      id: json['id'],
      namaSouvenir: json['nama_souvenir'] ?? 'Souvenir',
      imageUrl: imageUrl,
    );
  }
}
