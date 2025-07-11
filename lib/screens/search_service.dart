import '../model/markers.dart';

class SearchService {
  List<MarkerModel> searchMarkers(List<MarkerModel> markers, String query) {
    if (query.isEmpty) {
      return markers;
    }
    return markers.where((marker) {
      return marker.nama_marker?.toLowerCase().contains(query.toLowerCase()) ??
          false;
    }).toList();
  }
}
