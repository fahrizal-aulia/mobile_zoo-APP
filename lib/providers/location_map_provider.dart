import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../api/Map_Api.dart'; // Pastikan untuk mengimpor ApiService

class LocationProvider with ChangeNotifier {
  LatLng currentPosition = LatLng(0.0, 0.0);
  String currentAddress = "Mencari alamat...";
  double heading = 0.0; // Arah pengguna
  StreamSubscription<Position>? positionStream; // Ini benar

  LocationProvider() {
    _loadFromPreferences();
  }

  Future<void> _loadFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? latitude = prefs.getDouble('latitude');
    double? longitude = prefs.getDouble('longitude');
    if (latitude != null && longitude != null) {
      currentPosition = LatLng(latitude, longitude);
      notifyListeners();
    }
  }

  Future<void> _saveToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('latitude', currentPosition.latitude);
    prefs.setDouble('longitude', currentPosition.longitude);
  }

  Future<void> startLocationUpdates(BuildContext context) async {
    try {
      bool hasPermission = await _handleIzinLokasi(context);
      if (!hasPermission) return;

      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Mengurangi frekuensi update lokasi
      );

      // Mendapatkan stream posisi
      positionStream =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen((Position position) async {
        currentPosition = LatLng(position.latitude, position.longitude);
        heading = position.heading; // Menyimpan heading
        currentAddress = await _getAlamatDariLatLng(position);
        await _saveToPreferences(); // Simpan posisi saat ini
        notifyListeners(); // Notifikasi ke semua pendengar
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Kesalahan memperoleh lokasi: ${e.toString()}'),
      ));
    }
  }

  void stopLocationUpdates() {
    positionStream?.cancel();
  }

  Future<void> getCurrentLocation(BuildContext context) async {
    try {
      bool hasPermission = await _handleIzinLokasi(context);
      if (!hasPermission) return;

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      currentPosition = LatLng(position.latitude, position.longitude);
      currentAddress = await _getAlamatDariLatLng(position);
      heading = position.heading; // Simpan heading saat ini
      await _saveToPreferences(); // Simpan lokasi saat ini
      notifyListeners(); // Notifikasi semua pendengar
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Kesalahan memperoleh lokasi: ${e.toString()}'),
      ));
    }
  }

  Future<bool> _handleIzinLokasi(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Layanan lokasi dinonaktifkan.'),
      ));
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Izin lokasi ditolak.'),
        ));
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Izin lokasi ditolak secara permanen.'),
      ));
      return false;
    }
    return true;
  }

  Future<String> _getAlamatDariLatLng(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      return '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
    }
    return "Alamat tidak ditemukan";
  }
}
