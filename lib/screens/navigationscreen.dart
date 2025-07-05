import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/api/Map_Api.dart';
import 'package:provider/provider.dart';
import '../model/NavigationInstruction.dart';
import '../providers/location_map_provider.dart';

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
  int _currentStep = 0;
  Timer? _navigationTimer;
  bool _hasArrived = false;
  bool _isOffRoute = false;
  List<LatLng> _passedPoints = [];

  @override
  void initState() {
    super.initState();
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    _startCompassUpdates();
    _startLocationUpdates();
    _startAutoNavigation();
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  void _startCompassUpdates() {
    FlutterCompass.events?.listen((event) {
      setState(() {
        _heading = event.heading;
      });
    });
  }

  void _startLocationUpdates() {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    locationProvider.startLocationUpdates(context);
  }

  void _startAutoNavigation() {
    _navigationTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      _checkDistanceToNextInstruction();
      _checkArrival();
      _checkOffRoute();
    });
  }

  void _checkDistanceToNextInstruction() {
    if (_currentStep >= widget.routePoints.length - 1) return;

    final userLocation = _locationProvider.currentPosition;
    final nextPoint = widget.routePoints[_currentStep];

    final distance = Distance().as(
      LengthUnit.Meter,
      userLocation,
      nextPoint,
    );

    if (distance < 25) {
      setState(() {
        _passedPoints.add(
            widget.routePoints[_currentStep]); // Simpan yang sudah dilewati
        if (_currentStep < widget.instructions.length - 1) {
          _currentStep++;
        }
      });
    }
  }

  void _checkArrival() {
    final userLocation = _locationProvider.currentPosition;
    final destination = widget.routePoints.last;

    final distance = Distance().as(
      LengthUnit.Meter,
      userLocation,
      destination,
    );

    if (!_hasArrived && distance < 15) {
      _hasArrived = true;
      Fluttertoast.showToast(
        msg: "Anda telah sampai di tujuan!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  void _checkOffRoute() async {
    final userLocation = _locationProvider.currentPosition;

    final deviationThreshold = 15.0; // dalam meter
    bool isOnRoute = false;

    for (var point in widget.routePoints) {
      final distance = Distance().as(
        LengthUnit.Meter,
        userLocation,
        point,
      );
      if (distance <= deviationThreshold) {
        isOnRoute = true;
        break;
      }
    }

    if (!isOnRoute && !_isOffRoute) {
      setState(() {
        _isOffRoute = true;
      });

      Fluttertoast.showToast(
        msg: "Anda keluar dari jalur, menghitung ulang rute...",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );

      final newRoute = await ApiService.fetchNewRoute(
        userLocation,
        widget.routePoints.last,
      );

      final newInstructions = await ApiService.getRouteInstructions(
        userLocation,
        widget.routePoints.last,
      );

      setState(() {
        widget.routePoints
          ..clear()
          ..addAll(newRoute);
        widget.instructions
          ..clear()
          ..addAll(newInstructions);
        _currentStep = 0;
        _isOffRoute = false;
        _passedPoints.clear();
      });
    }
  }

  void _reroute(LatLng userLocation) async {
    try {
      final newRoute =
          await ApiService.fetchNewRoute(userLocation, widget.routePoints.last);
      setState(() {
        widget.routePoints
          ..clear()
          ..addAll(newRoute);
        _currentStep = 0;
        _isOffRoute = false;
        _passedPoints.clear();
      });
      Fluttertoast.showToast(msg: "Rute baru berhasil dihitung ulang.");
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Gagal Reroute"),
          content: Text("Tidak dapat menghitung ulang rute: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Tutup"),
            ),
          ],
        ),
      );
    }
  }

  String formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    String formatted = '';
    if (hours > 0) formatted += '$hours jam ';
    if (minutes > 0) formatted += '$minutes menit';
    return formatted.isNotEmpty ? formatted : '0 menit';
  }

  IconData _getDirectionIcon(double angle) {
    if (angle >= -45 && angle < 45) return Icons.arrow_upward;
    if (angle >= 45 && angle < 135) return Icons.turn_right;
    if (angle >= -135 && angle < -45) return Icons.turn_left;
    return Icons.u_turn_left;
  }

  @override
  Widget build(BuildContext context) {
    final instruction = widget.instructions[_currentStep];

    return Scaffold(
      appBar: AppBar(title: Text('Navigasi')),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: widget.routePoints.isNotEmpty
                  ? widget.routePoints[0]
                  : LatLng(0, 0),
              initialZoom: 17.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              PolylineLayer(
                polylines: [
                  if (_passedPoints.isNotEmpty)
                    Polyline(
                      points: _passedPoints,
                      strokeWidth: 4.0,
                      color: Colors.grey,
                    ),
                  Polyline(
                    points: widget.routePoints.skip(_currentStep).toList(),
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
                          ? (_heading! - 90) * (pi / 180)
                          : 0),
                      child: Image.asset(
                        'assets/icon/arah.png',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Marker(
                    point: widget.routePoints.last,
                    width: 40.0,
                    height: 40.0,
                    child: Icon(Icons.flag, color: Colors.green, size: 40),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 6,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Transform.rotate(
                      angle: (instruction.angle - 90) * (pi / 180),
                      child: Icon(
                        _getDirectionIcon(instruction.angle),
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            instruction.direction,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            instruction.streetName,
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatDuration(int.tryParse(instruction.duration) ?? 0),
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
