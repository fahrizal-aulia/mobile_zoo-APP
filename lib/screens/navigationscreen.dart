import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../api/Map_Api.dart';
import '../model/NavigationInstruction.dart';
import '../providers/location_map_provider.dart';

class NavigationScreen extends StatefulWidget {
  final List<NavigationInstruction> initialInstructions;
  final List<LatLng> initialRoutePoints;

  const NavigationScreen({
    super.key,
    required this.initialInstructions,
    required this.initialRoutePoints,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen>
    with TickerProviderStateMixin {
  // --- Controllers & Services ---
  final MapController _mapController = MapController();
  late final AnimationController _animationController;
  final FlutterTts _flutterTts = FlutterTts();
  late LocationProvider _locationProvider;

  // --- State ---
  late List<NavigationInstruction> _instructions;
  late List<LatLng> _routePoints;
  double? _heading;
  int _currentStep = 0;
  bool _hasArrived = false;
  bool _isOffRoute = false;
  bool _isHeadsUpGiven = false;
  List<LatLng> _passedPoints = [];
  Timer? _navigationTimer;
  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void initState() {
    super.initState();
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    _instructions = List.from(widget.initialInstructions);
    _routePoints = List.from(widget.initialRoutePoints);

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _locationProvider.startLocationUpdates();
    _setupTts();
    _startCompassUpdates();
    _startAutoNavigation();

    if (_instructions.isNotEmpty) {
      _speakInstruction(_instructions.first.instructionText);
    }
  }

  // --- Setup & Dispose ---
  void _setupTts() async {
    await _flutterTts.setLanguage("id-ID");
    await _flutterTts.setSpeechRate(0.55);
    await _flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _compassSubscription?.cancel();
    _mapController.dispose();
    _animationController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  // --- Core Logic ---
  void _speakInstruction(String text) {
    if (!_hasArrived) {
      _flutterTts.stop();
      _flutterTts.speak(text);
    }
  }

  void _startCompassUpdates() {
    if (_compassSubscription != null) return;
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (mounted && event.heading != null) {
        if ((_heading ?? 0) - event.heading! > 1 ||
            (_heading ?? 0) - event.heading! < -1) {
          setState(() => _heading = event.heading);
        }
        _animateMapRotation(-event.heading!);
      }
    });
  }

  void _stopCompassUpdates() {
    _compassSubscription?.cancel();
    _compassSubscription = null;
  }

  void _animateMapRotation(double targetHeadingDegrees) {
    final targetRotationRad = targetHeadingDegrees * (pi / 180.0);
    final rotationTween = Tween<double>(
        begin: _mapController.camera.rotation, end: targetRotationRad);
    final animation = rotationTween.animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    animation.addListener(() {
      if (mounted) _mapController.rotate(animation.value);
    });

    if (!_animationController.isAnimating) {
      _animationController.forward(from: 0.0);
    }
  }

  void _startAutoNavigation() {
    _navigationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;
      final userLocation = _locationProvider.currentPosition;
      if (userLocation == null) return;

      _checkDistanceToNextInstruction(userLocation);
      _checkArrival(userLocation);
      _checkOffRoute(userLocation);

      _mapController.move(userLocation, _mapController.camera.zoom);
    });
  }

  // PERBAIKAN: Fungsi ini sekarang memicu suara di setiap langkah
  void _checkDistanceToNextInstruction(LatLng userLocation) {
    if (_currentStep >= _instructions.length - 1 ||
        _instructions[_currentStep].wayPoints.isEmpty) return;

    final nextManeuverPoint =
        _routePoints[_instructions[_currentStep].wayPoints.last];
    final distance =
        const Distance().as(LengthUnit.Meter, userLocation, nextManeuverPoint);

    if (distance < 30 &&
        !_isHeadsUpGiven &&
        _currentStep + 1 < _instructions.length) {
      final nextInstruction = _instructions[_currentStep + 1];
      _speakInstruction("Setelah ini, ${nextInstruction.instructionText}");
      setState(() => _isHeadsUpGiven = true);
    }

    if (distance < 15) {
      setState(() {
        // Tambahkan semua titik dari langkah sebelumnya ke _passedPoints
        final currentWayPoints = _instructions[_currentStep].wayPoints;
        if (currentWayPoints.isNotEmpty) {
          _passedPoints.addAll(_routePoints.getRange(
              currentWayPoints.first, currentWayPoints.last + 1));
        }

        // Pindah ke langkah berikutnya
        _currentStep++;
        _isHeadsUpGiven = false;

        // Ucapkan instruksi baru
        _speakInstruction(_instructions[_currentStep].instructionText);
      });
    }
  }

  void _checkArrival(LatLng userLocation) {
    if (_hasArrived || _routePoints.isEmpty) return;
    final destination = _routePoints.last;
    final distance =
        const Distance().as(LengthUnit.Meter, userLocation, destination);

    if (distance < 15) {
      setState(() => _hasArrived = true);
      _navigationTimer?.cancel();
      _speakInstruction("Anda telah tiba di tujuan.");
    }
  }

  void _checkOffRoute(LatLng userLocation) async {
    if (_isOffRoute || _routePoints.isEmpty) return;

    const deviationThreshold = 25.0;
    bool isOnSegment = false;
    // Cek hanya pada segmen rute saat ini untuk efisiensi
    if (_currentStep < _routePoints.length - 1) {
      final distToSegment = _distToSegment(userLocation,
          _routePoints[_currentStep], _routePoints[_currentStep + 1]);
      if (distToSegment <= deviationThreshold) {
        isOnSegment = true;
      }
    }

    if (!isOnSegment) {
      setState(() => _isOffRoute = true);
      Fluttertoast.showToast(
          msg: "Anda keluar jalur, menghitung ulang rute...",
          toastLength: Toast.LENGTH_LONG);

      try {
        final routeInfo = await ApiService.getRouteAndInstructions(
            userLocation, _routePoints.last);
        if (mounted) {
          setState(() {
            _routePoints = routeInfo.routePoints;
            _instructions = routeInfo.instructions;
            _currentStep = 0;
            _isOffRoute = false;
            _passedPoints.clear();
            _speakInstruction(
                "Rute baru dibuat. ${_instructions.first.instructionText}");
          });
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "Gagal menghitung ulang rute.");
        if (mounted) setState(() => _isOffRoute = false);
      }
    }
  }

  double _distToSegment(LatLng p, LatLng v, LatLng w) {
    final l2 = const Distance().as(LengthUnit.Meter, v, w) *
        const Distance().as(LengthUnit.Meter, v, w);
    if (l2 == 0.0) return const Distance().as(LengthUnit.Meter, p, v);
    var t = ((p.latitude - v.latitude) * (w.latitude - v.latitude) +
            (p.longitude - v.longitude) * (w.longitude - v.longitude)) /
        l2;
    t = max(0, min(1, t));
    final projection = LatLng(v.latitude + t * (w.latitude - v.latitude),
        v.longitude + t * (w.longitude - v.longitude));
    return const Distance().as(LengthUnit.Meter, p, projection);
  }

  // --- Build Methods ---
  @override
  Widget build(BuildContext context) {
    final userPosition = _locationProvider.currentPosition;
    return Scaffold(
      body: userPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: userPosition,
                    initialZoom: 18.5,
                    onPositionChanged: (position, hasGesture) {
                      if (hasGesture) _stopCompassUpdates();
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: 'id.kbs.mobile_zoo',
                    ),
                    PolylineLayer(
                      polylines: [
                        // PERBAIKAN: Garis solid dengan warna pudar untuk rute yang dilewati
                        if (_passedPoints.isNotEmpty)
                          Polyline(
                              points: _passedPoints,
                              strokeWidth: 7.0,
                              color: Colors.teal.shade300.withOpacity(0.9)),
                        // Rute yang akan datang
                        Polyline(
                            points: _routePoints
                                .skip(_passedPoints.length)
                                .toList(),
                            strokeWidth: 7.0,
                            color: Colors.blue.shade700,
                            borderStrokeWidth: 1,
                            borderColor: Colors.white),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: userPosition,
                          width: 80,
                          height: 80,
                          child: Transform.rotate(
                            angle: _heading != null
                                ? ((_mapController.camera.rotation * -1) +
                                    (_heading! * (pi / 180)))
                                : 0,
                            child: const Icon(Icons.navigation_rounded,
                                color: Colors.white,
                                size: 45,
                                shadows: [
                                  Shadow(color: Colors.black45, blurRadius: 5)
                                ]),
                          ),
                        ),
                        if (_routePoints.isNotEmpty)
                          Marker(
                            point: _routePoints.last,
                            width: 40.0,
                            height: 40.0,
                            child: const Icon(Icons.flag_circle_rounded,
                                color: Colors.green, size: 40),
                          ),
                      ],
                    ),
                  ],
                ),
                if (_hasArrived) _buildArrivalView(),
                if (!_hasArrived && _instructions.isNotEmpty) ...[
                  _buildInstructionCard(),
                  _buildBottomPanel(),
                ]
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_locationProvider.currentPosition != null) {
            _mapController.moveAndRotate(
                _locationProvider.currentPosition!, 18.5, 0);
            _startCompassUpdates();
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildArrivalView() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Card(
          elevation: 10,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events_rounded,
                    color: Colors.amber, size: 80),
                const SizedBox(height: 16),
                const Text("Anda Telah Tiba!",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15)),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Selesai"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionCard() {
    final current = _instructions[_currentStep];
    final next = _currentStep + 1 < _instructions.length
        ? _instructions[_currentStep + 1]
        : null;

    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(current.getDirectionIcon(),
                      color: Colors.blue.shade700, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(current.instructionText,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(current.streetName,
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade700)),
                      ],
                    ),
                  ),
                  Text('${current.distance.round()} m',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
              if (next != null) ...[
                const Divider(height: 20, thickness: 1),
                Row(
                  children: [
                    Icon(next.getDirectionIcon(),
                        color: Colors.grey.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(next.instructionText,
                            style: TextStyle(color: Colors.grey.shade700),
                            overflow: TextOverflow.ellipsis)),
                  ],
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    final remaining = _calculateRemaining();
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 10,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, max(16, MediaQuery.of(context).padding.bottom)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoColumn(
                  "Estimasi Tiba", _formatDuration(remaining['duration']!)),
              _buildInfoColumn(
                  "Sisa Jarak", _formatDistance(remaining['distance']!)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(title,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
      ],
    );
  }

  Map<String, double> _calculateRemaining() {
    if (_currentStep >= _instructions.length) {
      return {'distance': 0.0, 'duration': 0.0};
    }
    double remainingDistance = 0;
    double remainingDuration = 0;
    for (int i = _currentStep; i < _instructions.length; i++) {
      remainingDistance += _instructions[i].distance;
      remainingDuration += _instructions[i].duration;
    }
    return {'distance': remainingDistance, 'duration': remainingDuration};
  }

  String _formatDuration(double totalSeconds) {
    final duration = Duration(seconds: totalSeconds.toInt());
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return '$hours jam $minutes mnt';
    if (minutes < 1) return '< 1 mnt';
    return '$minutes mnt';
  }

  String _formatDistance(double totalMeters) {
    if (totalMeters >= 1000) {
      return '${(totalMeters / 1000).toStringAsFixed(1)} km';
    }
    return '${totalMeters.round()} m';
  }
}
