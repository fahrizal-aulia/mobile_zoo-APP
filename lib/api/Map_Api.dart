// File: lib/api/Map_Api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../model/NavigationInstruction.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// BARU: Class untuk menampung hasil gabungan dari API
class RouteInfo {
  final List<LatLng> routePoints;
  final List<NavigationInstruction> instructions;

  RouteInfo({required this.routePoints, required this.instructions});
}

class ApiService {
  static final String apiKey =
      dotenv.env['ORS_API_KEY'] ?? 'KUNCI_API_TIDAK_DITEMUKAN';

  // PERBAIKAN: Fungsi ini sekarang mengambil rute dan instruksi dalam SATU kali request
  static Future<RouteInfo> getRouteAndInstructions(
      LatLng start, LatLng end) async {
    final startCoord = '${start.longitude},${start.latitude}';
    final endCoord = '${end.longitude},${end.latitude}';

    final url =
        'https://api.openrouteservice.org/v2/directions/foot-walking?api_key=$apiKey&start=$startCoord&end=$endCoord';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final feature = data['features'][0];

          // 1. Ekstrak Geometri (garis rute)
          final coordinates = feature['geometry']['coordinates'];
          final routePoints = coordinates
              .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
              .toList();

          // 2. Ekstrak Instruksi
          final steps = feature['properties']['segments'][0]['steps'];
          final instructions = steps.map<NavigationInstruction>((step) {
            return NavigationInstruction.fromJson(
                step); // Gunakan factory constructor
          }).toList();

          return RouteInfo(
              routePoints: routePoints, instructions: instructions);
        } else {
          throw Exception('Tidak ada data rute ditemukan dalam respon.');
        }
      } else {
        // Memberikan error yang lebih informatif
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['error']?['message'] ?? response.reasonPhrase;
        throw Exception('Gagal memuat rute: $errorMessage');
      }
    } catch (e) {
      print('Error getRouteAndInstructions: $e');
      throw Exception('Terjadi kesalahan saat memuat rute: $e');
    }
  }

  static Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final startCoord = '${start.longitude},${start.latitude}';
    final endCoord = '${end.longitude},${end.latitude}';

    final url =
        'https://api.openrouteservice.org/v2/directions/foot-walking?api_key=$apiKey&start=$startCoord&end=$endCoord';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final coordinates = data['features'][0]['geometry']['coordinates'];
          return coordinates
              .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
              .toList();
        } else {
          throw Exception('Tidak ada data rute ditemukan dalam respon.');
        }
      } else {
        throw Exception(
            'Gagal memuat rute: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Terjadi kesalahan saat memuat rute: $e');
    }
  }

  static Future<List<LatLng>> fetchNewRoute(LatLng from, LatLng to) async {
    final url = Uri.parse(
        'https://api.openrouteservice.org/v2/directions/foot-walking/geojson');

    final body = jsonEncode({
      "coordinates": [
        [from.longitude, from.latitude],
        [to.longitude, to.latitude]
      ]
    });

    final headers = {
      'Authorization': apiKey,
      'Content-Type': 'application/json'
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // ✅ Perhatikan struktur JSON: geometry -> coordinates
        final coordinates = data['features'][0]['geometry']['coordinates'];

        return coordinates
            .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
            .toList();
      } else {
        print('Response error body: ${response.body}');
        throw Exception(
            'Gagal menghitung ulang rute: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetchNewRoute: $e');
      throw Exception('Terjadi kesalahan saat menghitung ulang rute: $e');
    }
  }
}
