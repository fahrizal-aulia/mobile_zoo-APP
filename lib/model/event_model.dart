import 'package:hive/hive.dart';

part 'event_model.g.dart';

@HiveType(typeId: 0)
class EventModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String deskripsi;

  @HiveField(3)
  final String imageUrl;

  EventModel({
    required this.id,
    required this.title,
    required this.deskripsi,
    required this.imageUrl,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    String imageUrl = "https://kbs.simdabesmiwa.id${json['gambar_event_url']}";
    return EventModel(
      id: json['id'],
      title: json['title'] ?? 'Tanpa Judul',
      deskripsi: json['deskripsi'] ?? 'Tidak ada deskripsi.',
      imageUrl: imageUrl,
    );
  }
}
