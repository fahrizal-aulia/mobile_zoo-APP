// // File: lib/api/api_service.dart

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:hive_flutter/hive_flutter.dart';

// // Import semua model data Anda
// import '../model/event_model.dart';
// import '../model/markers.dart';
// import '../model/spot_foto_model.dart';
// import '../model/souvenir_model.dart';
// import '../model/paket_model.dart';
// import '../model/tiket_model.dart';

// class ApiService {
//   static const String baseUrl = 'https://kbs.simdabesmiwa.id/api';

//   // Fungsi generik untuk mengambil DAN menyimpan data
//   static Future<List<T>> _fetchAndCacheData<T>(String endpoint, String boxName,
//       T Function(Map<String, dynamic>) fromJson) async {
//     final url = Uri.parse('$baseUrl/$endpoint');
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> decodedData = json.decode(response.body);
//         final List<dynamic> data = decodedData['data'];

//         final List<T> items =
//             data.map((jsonItem) => fromJson(jsonItem)).toList();

//         final box = await Hive.openBox<T>(boxName);
//         await box.clear();
//         for (var item in items) {
//           await box.put((item as dynamic).id, item);
//         }

//         return items;
//       } else {
//         throw Exception('Gagal memuat dari: $endpoint');
//       }
//     } catch (e) {
//       throw Exception('Kesalahan jaringan: ${e.toString()}');
//     }
//   }

//   // --- Endpoint Spesifik untuk Setiap Layar ---

//   /// Mengambil daftar semua event
//   static Future<List<EventModel>> getEvents() async {
//     return _fetchAndCacheData<EventModel>(
//         'events', 'eventsBox', (json) => EventModel.fromJson(json));
//   }

//   /// Mengambil daftar semua marker
//   static Future<List<MarkerModel>> getMarkers() async {
//     // Menggunakan endpoint 'markers' yang benar
//     return _fetchAndCacheData<MarkerModel>(
//         'markers', 'markersBox', (json) => MarkerModel.fromJson(json));
//   }

//   /// Mengambil daftar semua spot foto
//   static Future<List<SpotFotoModel>> getSpotFotos() async {
//     return _fetchAndCacheData<SpotFotoModel>(
//         'spot-fotos', 'spotFotosBox', (json) => SpotFotoModel.fromJson(json));
//   }

//   /// Mengambil daftar semua souvenir
//   static Future<List<SouvenirModel>> getSouvenirs() async {
//     return _fetchAndCacheData<SouvenirModel>(
//         'souvenirs', 'souvenirsBox', (json) => SouvenirModel.fromJson(json));
//   }

//   /// Mengambil daftar semua paket
//   static Future<List<PaketModel>> getPakets() async {
//     return _fetchAndCacheData<PaketModel>(
//         'pakets', 'paketsBox', (json) => PaketModel.fromJson(json));
//   }

//   /// Mengambil daftar semua tiket
//   static Future<List<TiketModel>> getTikets() async {
//     return _fetchAndCacheData<TiketModel>(
//         'tikets', 'tiketsBox', (json) => TiketModel.fromJson(json));
//   }

//   // Fungsi sinkronisasi yang akan dipanggil di SplashScreen
//   static Future<void> synchronizeAllData() async {
//     try {
//       await Future.wait([
//         getEvents(),
//         getMarkers(),
//         getSpotFotos(),
//         getSouvenirs(),
//         getPakets(),
//         getTikets(),
//       ]);
//       print("Sinkronisasi semua data berhasil!");
//     } catch (e) {
//       print("Sinkronisasi gagal: $e");
//       // Anda bisa menambahkan penanganan error di sini
//     }
//   }
// }
