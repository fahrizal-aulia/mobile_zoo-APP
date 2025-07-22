// File: lib/providers/location_map_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationProvider with ChangeNotifier {
  LatLng? _currentPosition;
  LatLng? get currentPosition => _currentPosition;

  double _heading = 0.0;
  double get heading => _heading;

  StreamSubscription<Position>? _positionStream;

  // PERBAIKAN: Fungsi ini tidak lagi memerlukan BuildContext
  Future<void> startLocationUpdates() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Layanan lokasi dinonaktifkan.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Izin lokasi ditolak secara permanen.');
    }

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update jika bergerak minimal 5 meter
    );

    // Hentikan stream lama sebelum memulai yang baru
    _positionStream?.cancel();

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      final newPosition = LatLng(position.latitude, position.longitude);

      // Hanya notifikasi jika ada perubahan posisi yang signifikan untuk efisiensi
      if (_currentPosition == null ||
          Geolocator.distanceBetween(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                  newPosition.latitude,
                  newPosition.longitude) >
              1) {
        _currentPosition = newPosition;
        _heading = position.heading;
        notifyListeners();
      }
    });
  }

  void stopLocationUpdates() {
    _positionStream?.cancel();
  }
}
