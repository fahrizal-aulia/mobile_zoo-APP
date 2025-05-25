import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../model/NavigationInstruction.dart';

class ApiService {
  static const String apiKey =
      'API KEY ANDA DI SINI'; // Ganti dengan API key Anda

  static Future<List<NavigationInstruction>> getRouteInstructions(
      LatLng start, LatLng end) async {
    final startCoord = '${start.longitude},${start.latitude}';
    final endCoord = '${end.longitude},${end.latitude}';

    final url =
        'https://api.openrouteservice.org/v2/directions/foot-walking?api_key=$apiKey&start=$startCoord&end=$endCoord';

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
            angle: step['angle'] != null ? step['angle'].toDouble() : 0.0,
          );
        }).toList();
      } else {
        throw Exception('Tidak ada data rute ditemukan dalam respon.');
      }
    } else {
      print('Response error: ${response.body}');
      throw Exception(
          'Gagal memuat rute: ${response.statusCode} ${response.reasonPhrase}');
    }
  }

  static Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final startCoord = '${start.longitude},${start.latitude}';
    final endCoord = '${end.longitude},${end.latitude}';

    final url =
        'https://api.openrouteservice.org/v2/directions/foot-walking?api_key=$apiKey&start=$startCoord&end=$endCoord';

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
      print('Response error: ${response.body}');
      throw Exception(
          'Gagal memuat rute: ${response.statusCode} ${response.reasonPhrase}');
    }
  }
}
