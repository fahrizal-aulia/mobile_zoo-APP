import 'package:myapp/model/markers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
// import 'model/markers.dart'; // Gantilah dengan path yang sesuai

class SharedPreferencesHelper {
  static const String _keyMarkers = 'markers';

  // Simpan daftar marker ke SharedPreferences
  static Future<void> saveMarkers(List<MarkerModel> markers) async {
    final prefs = await SharedPreferences.getInstance();
    final markersJson =
        jsonEncode(markers.map((marker) => marker.toJson()).toList());
    await prefs.setString(_keyMarkers, markersJson);
  }

  // Ambil daftar marker dari SharedPreferences
  static Future<List<MarkerModel>> getMarkers() async {
    final prefs = await SharedPreferences.getInstance();
    final markersJson = prefs.getString(_keyMarkers);
    if (markersJson != null) {
      final List<dynamic> markersList = jsonDecode(markersJson);
      return markersList.map((json) => MarkerModel.fromJson(json)).toList();
    } else {
      return [];
    }
  }
}
