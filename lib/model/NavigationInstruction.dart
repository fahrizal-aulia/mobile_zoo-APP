// File: lib/model/NavigationInstruction.dart

import 'package:flutter/material.dart';

class NavigationInstruction {
  final String instructionText;
  final String streetName;
  final double distance;
  final double duration;
  final int type;
  // BARU: Menyimpan indeks titik untuk setiap instruksi
  final List<int> wayPoints;

  NavigationInstruction({
    required this.instructionText,
    required this.streetName,
    required this.distance,
    required this.duration,
    required this.type,
    required this.wayPoints,
  });

  factory NavigationInstruction.fromJson(Map<String, dynamic> json) {
    return NavigationInstruction(
      instructionText: json['instruction'] ?? 'Arah tidak diketahui',
      streetName: json['name'] ?? '',
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
      type: (json['type'] as int?) ?? 0,
      // BARU: Mengambil data way_points dari JSON
      wayPoints: (json['way_points'] as List<dynamic>?)?.cast<int>() ?? [],
    );
  }

  IconData getDirectionIcon() {
    switch (type) {
      case 0:
        return Icons.arrow_upward_rounded; // Lurus
      case 1:
        return Icons.turn_right_rounded; // Belok kanan
      case 2:
        return Icons.turn_left_rounded; // Belok kiri
      case 3:
        return Icons.turn_sharp_right_rounded; // Tajam kanan
      case 4:
        return Icons.turn_sharp_left_rounded; // Tajam kiri
      case 5:
        return Icons.u_turn_right_rounded; // Putar balik
      case 6:
        return Icons.u_turn_left_rounded; // Putar balik
      case 10:
        return Icons.flag_circle_rounded; // Tiba
      default:
        return Icons.arrow_upward_rounded;
    }
  }
}
