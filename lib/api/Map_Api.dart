import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../model/NavigationInstruction.dart';

class ApiService {
  static const String apiKey =
      '5b3ce3597851110001cf624895d918be692442e6946e237012042519';

  static Future<List<NavigationInstruction>> getRouteInstructions(
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
          final instructions =
              data['features'][0]['properties']['segments'][0]['steps'];
          return instructions.map<NavigationInstruction>((step) {
            return NavigationInstruction(
              direction: step['instruction'],
              streetName: step['name'] ?? "Jalan tidak diketahui",
              distance: step['distance'].toString(),
              duration: step['duration'].toString(),
              angle: step['angle'] != null
                  ? step['angle'].toDouble()
                  : 0.0, // Ambil angle dari API
            );
          }).toList();
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
