// map_marker_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:latlong2/latlong.dart';
import '../model/markers.dart'; // Pastikan untuk mengimpor model marker

class MapMarkerApi {
  // Mengambil marker dari endpoint tertentu
  static Future<List<MarkerModel>> getMarkers() async {
    final url = 'https://kbs.simdabesmiwa.id/api/marker';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data
          .map<MarkerModel>((item) => MarkerModel.fromJson(item))
          .toList();
    } else {
      throw Exception('Gagal memuat marker');
    }
  }
}
