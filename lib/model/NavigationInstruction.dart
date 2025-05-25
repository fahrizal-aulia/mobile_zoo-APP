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
    required this.angle, // Tambahkan angle
  });
}
