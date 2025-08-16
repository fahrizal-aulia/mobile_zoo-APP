// File: lib/api/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Import semua model data Anda
import '../model/event_model.dart';
import '../model/markers.dart';
import '../model/spot_foto_model.dart';
import '../model/souvenir_model.dart';
import '../model/paket_model.dart';
import '../model/tiket_model.dart';
import '../model/NavigationInstruction.dart';

// Class untuk menampung hasil gabungan dari API Rute
class RouteInfo {
  final List<LatLng> routePoints;
  final List<NavigationInstruction> instructions;
  RouteInfo({required this.routePoints, required this.instructions});
}

class ApiService {
  static const String baseUrl = 'https://kbs.simdabesmiwa.id/api';
  static final String orsApiKey = dotenv.env['ORS_API_KEY'] ?? '';

  // --- FUNGSI INTI: SINKRONISASI CERDAS & VALIDASI CACHE BASI ---
  static Future<List<T>> _fetchAndSyncData<T>(String endpoint, String boxName,
      T Function(Map<String, dynamic>) fromJson) async {
    final box = await Hive.openBox<T>(boxName);

    // Cek apakah data di cache sudah usang sebelum memanggil API
    if (await _isCacheStale(boxName)) {
      print("Cache untuk '$boxName' usang, memulai sinkronisasi...");
      try {
        final url = Uri.parse('$baseUrl/$endpoint');
        final response =
            await http.get(url, headers: {'Accept': 'application/json'});

        if (response.statusCode == 200) {
          final Map<String, dynamic> decodedData = json.decode(response.body);
          final List<dynamic> data = decodedData['data'];

          final List<T> itemsFromApi =
              data.map((jsonItem) => fromJson(jsonItem)).toList();

          // --- LOGIKA SINKRONISASI (TAMBAH/PERBARUI/HAPUS) ---
          final apiItemKeys =
              itemsFromApi.map((item) => (item as dynamic).id).toSet();
          final localItemKeys = box.keys.toSet();

          // Tambah atau Perbarui data dari API ke Hive
          for (var item in itemsFromApi) {
            await box.put((item as dynamic).id, item);
          }

          // Hapus data di Hive yang sudah tidak ada lagi di API
          final keysToDelete = localItemKeys.difference(apiItemKeys);
          for (var key in keysToDelete) {
            await box.delete(key);
          }

          // Simpan waktu sinkronisasi berhasil
          final timestampBox = await Hive.openBox('syncTimestamps');
          await timestampBox.put(boxName, DateTime.now());
          print("Sinkronisasi untuk '$boxName' berhasil.");
        } else {
          print(
              "Gagal mengambil data dari server ($endpoint), data lama dari cache akan digunakan.");
        }
      } catch (e) {
        print(
            'Kesalahan jaringan ($endpoint), data lama dari cache akan digunakan: ${e.toString()}');
      }
    } else {
      print("Cache untuk '$boxName' masih baru, tidak perlu sinkronisasi.");
    }

    // Selalu kembalikan data terbaru dari Hive, baik setelah sinkronisasi maupun dari cache
    return box.values.toList();
  }

  static Future<bool> _isCacheStale(String boxName) async {
    final box = await Hive.openBox('syncTimestamps');
    final lastSync = box.get(boxName) as DateTime?;
    if (lastSync == null) {
      return true; // Jika belum pernah sinkron, maka usang
    }
    // Anggap data usang jika sudah lebih dari 1 jam (bisa diubah)
    return DateTime.now().difference(lastSync) > const Duration(hours: 1);
  }

  // --- Endpoint Spesifik untuk Setiap Jenis Data ---
  static Future<List<EventModel>> getEvents() async => _fetchAndSyncData(
      'events', 'eventsBox', (json) => EventModel.fromJson(json));
  static Future<List<MarkerModel>> getMarkers() async => _fetchAndSyncData(
      'markers', 'markersBox', (json) => MarkerModel.fromJson(json));
  static Future<List<SpotFotoModel>> getSpotFotos() async => _fetchAndSyncData(
      'spot-fotos', 'spotFotosBox', (json) => SpotFotoModel.fromJson(json));
  static Future<List<SouvenirModel>> getSouvenirs() async => _fetchAndSyncData(
      'souvenirs', 'souvenirsBox', (json) => SouvenirModel.fromJson(json));
  static Future<List<PaketModel>> getPakets() async => _fetchAndSyncData(
      'pakets', 'paketsBox', (json) => PaketModel.fromJson(json));
  static Future<List<TiketModel>> getTikets() async => _fetchAndSyncData(
      'tikets', 'tiketsBox', (json) => TiketModel.fromJson(json));

  // --- Endpoint Navigasi (tidak di-cache) ---
  static Future<RouteInfo> getRouteAndInstructions(
      LatLng start, LatLng end) async {
    final startCoord = '${start.longitude},${start.latitude}';
    final endCoord = '${end.longitude},${end.latitude}';
    final url =
        'https://api.openrouteservice.org/v2/directions/foot-walking?api_key=$orsApiKey&start=$startCoord&end=$endCoord';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final feature = data['features'][0];
      final coordinates = feature['geometry']['coordinates'];
      final routePoints = coordinates
          .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
          .toList();
      final steps = feature['properties']['segments'][0]['steps'];
      final instructions = steps
          .map<NavigationInstruction>(
              (step) => NavigationInstruction.fromJson(step))
          .toList();
      return RouteInfo(routePoints: routePoints, instructions: instructions);
    } else {
      throw Exception('Gagal memuat rute dari OpenRouteService');
    }
  }

  // Fungsi sinkronisasi yang dipanggil di SplashScreen
  static Future<bool> synchronizeAllData() async {
    try {
      await Future.wait([
        getEvents(),
        getMarkers(),
        getSpotFotos(),
        getSouvenirs(),
        getPakets(),
        getTikets(),
      ]);
      print("Sinkronisasi semua data selesai!");
      return true;
    } catch (e) {
      print("Sinkronisasi gagal: $e");
      return false;
    }
  }
}
