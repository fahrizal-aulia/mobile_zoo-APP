import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../model/NavigationInstruction.dart';
import '../providers/location_map_provider.dart';
import 'package:provider/provider.dart';
import '../api/Map_Api.dart';

class NavigationScreen extends StatefulWidget {
  final List<NavigationInstruction> instructions;
  final List<LatLng> routePoints;

  NavigationScreen({required this.instructions, required this.routePoints});

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  double? _heading;
  late LocationProvider _locationProvider;

  @override
  void initState() {
    super.initState();
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    _startCompassUpdates();
    _startLocationUpdates();
  }

  void _startCompassUpdates() {
    FlutterCompass.events?.listen((event) {
      setState(() {
        _heading = event.heading; // Update heading
      });
    });
  }

  void _startLocationUpdates() {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    locationProvider.startLocationUpdates(context);
  }

  Future<void> _updateRoute(LatLng currentPosition) async {
    if (widget.routePoints.isNotEmpty) {
      try {
        // Ambil rute baru dari API
        List<LatLng> newRoutePoints = await ApiService.getRoute(
          currentPosition,
          widget.routePoints.last,
        );

        // Ambil instruksi baru dari API
        List<NavigationInstruction> newInstructions =
            await ApiService.getRouteInstructions(
          currentPosition,
          widget.routePoints.last,
        );

        setState(() {
          widget.routePoints.clear();
          widget.routePoints.addAll(newRoutePoints);
          widget.instructions.clear();
          widget.instructions.addAll(newInstructions);
        });
      } catch (e) {
        print('Gagal memperbarui rute: ${e.toString()}');
      }
    }
  }

  String formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    String formatted = '';
    if (hours > 0) {
      formatted += '$hours jam ';
    }
    if (minutes > 0) {
      formatted += '$minutes menit';
    }
    return formatted.isNotEmpty ? formatted : '0 menit';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Navigasi'),
      ),
      body: Stack(
        children: [
          // Peta
          FlutterMap(
            options: MapOptions(
              initialCenter: widget.routePoints.isNotEmpty
                  ? widget.routePoints[0]
                  : LatLng(0, 0),
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.routePoints,
                    strokeWidth: 4.0,
                    color: Colors.blue,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _locationProvider.currentPosition,
                    width: 40,
                    height: 40,
                    child: Transform.rotate(
                      angle: (_heading != null
                          ? _heading! * (3.141592653589793 / 180)
                          : 0),
                      child: Image.asset(
                        'assets/icon/arah.png', // Ganti dengan path ke ikon panah
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Marker untuk titik akhir
                  Marker(
                    point: widget.routePoints.isNotEmpty
                        ? widget.routePoints.last
                        : LatLng(0, 0),
                    width: 40.0,
                    height: 40.0,
                    child: Icon(Icons.flag, color: Colors.green, size: 40),
                  ),
                ],
              ),
            ],
          ),
          // Panel instruksi navigasi
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Card untuk instruksi
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Ikon arah dinamis
                          Transform.rotate(
                            angle: (widget.instructions.isNotEmpty
                                ? (widget.instructions[0].angle - 90) *
                                    (3.141592653589793 / 180)
                                : 0),
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.blue,
                              size: 40,
                            ),
                          ),
                          SizedBox(width: 10),
                          // Nama jalan
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.instructions.isNotEmpty
                                      ? widget.instructions[0].direction
                                      : "Mulai",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.instructions.isNotEmpty
                                      ? widget.instructions[0].streetName
                                      : "",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          // Waktu yang tersisa
                          Text(
                            widget.instructions.isNotEmpty
                                ? formatDuration(int.tryParse(
                                        widget.instructions[0].duration) ??
                                    0)
                                : "",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Total waktu dan jarak
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Waktu: ${widget.instructions.isNotEmpty ? formatDuration(int.tryParse(widget.instructions[0].duration) ?? 0) : "0 menit"}",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "Jarak: ${widget.instructions.isNotEmpty ? widget.instructions[0].distance : "0"} m",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
