import 'package:flutter/material.dart';

class NavigationInstruction {
  final String direction; // Arah
  final String streetName; // Nama jalan
  final String distance; // Jarak
  final String duration; // Waktu
  final double angle; // Arah dalam derajat

  NavigationInstruction({
    required this.direction,
    required this.streetName,
    required this.distance,
    required this.duration,
    required this.angle,
  });

  // Metode untuk mengonversi angle menjadi ikon yang sesuai
  IconData getDirectionIcon() {
    if (angle >= -45 && angle < 45) {
      return Icons.arrow_forward; // Lurus
    } else if (angle >= 45 && angle < 135) {
      return Icons.arrow_right; // Belok kanan
    } else if (angle >= -135 && angle < -45) {
      return Icons.arrow_left; // Belok kiri
    } else {
      return Icons.arrow_back; // Berbalik
    }
  }
}
