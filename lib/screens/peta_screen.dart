import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart' as html;
import 'package:cached_network_image/cached_network_image.dart';
import '../api/api_service.dart';
import '../model/markers.dart';
import '../model/NavigationInstruction.dart';
import '../providers/location_map_provider.dart';
import 'custom_bar.dart';
import 'hewan_screen.dart';
import 'navigationscreen.dart';
import 'search_service.dart';
import '../widget/tema_background.dart';

class PetaScreen extends StatefulWidget {
  const PetaScreen({super.key});

  @override
  State<PetaScreen> createState() => _PetaScreenState();
}

class _PetaScreenState extends State<PetaScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();

  List<MarkerModel> _markers = [];
  List<MarkerModel> _filteredMarkers = [];
  List<LatLng> _routePoints = [];
  List<NavigationInstruction> _instructions = [];
  MarkerModel? _selectedMarker;
  String? _selectedCategory;
  List<String> _suggestions = [];
  bool _isLoading = false;
  double? _heading;
  double _currentZoom = 16.0;

  String _routeDistance = '';
  String _routeDuration = '';

  final LatLng _initialCoordinates = const LatLng(-7.295583, 112.736706);
  late LocationProvider _locationProvider;
  StreamSubscription<CompassEvent>? _compassSubscription;

  final LatLngBounds kbsBounds = LatLngBounds(
    const LatLng(-7.3005, 112.7335),
    const LatLng(-7.2925, 112.7415),
  );

  @override
  void initState() {
    super.initState();
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    _locationProvider.startLocationUpdates();
    _loadMarkersFromHive();
    _startCompassListener();
    _searchController.addListener(() {
      _onSearch(_searchController.text);
    });
  }

  @override
  void dispose() {
    _locationProvider.stopLocationUpdates();
    _searchController.dispose();
    _stopCompassListener();
    _mapController.dispose();
    super.dispose();
  }

  void _startCompassListener() {
    _compassSubscription?.cancel();
    _compassSubscription = FlutterCompass.events?.listen((direction) {
      if (mounted && direction.heading != null) {
        setState(() => _heading = direction.heading);
      }
    });
  }

  void _stopCompassListener() {
    _compassSubscription?.cancel();
  }

  Future<void> _loadMarkersFromHive() async {
    final box = await Hive.openBox<MarkerModel>('markersBox');
    if (mounted) {
      setState(() {
        _markers = box.values.toList();
        _filteredMarkers = _markers;
      });
    }
  }

  void _navigateToHewanScreen(BuildContext context, MarkerModel marker) {
    setState(() => _selectedMarker = null);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HewanScreen(marker: marker),
      ),
    );
  }

  Future<void> _loadRoute(LatLng destination) async {
    final startPosition = _locationProvider.currentPosition;
    if (startPosition == null) {
      _showSnackBar('Lokasi saat ini belum tersedia. Mohon tunggu...');
      return;
    }

    // PERBAIKAN: Validasi lokasi pengguna sebelum membuat rute
    if (!kbsBounds.contains(startPosition)) {
      _showSnackBar(
          'Rute hanya bisa dibuat jika Anda berada di dalam area KBS.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final routeInfo =
          await ApiService.getRouteAndInstructions(startPosition, destination);
      if (mounted) {
        setState(() {
          _routePoints = routeInfo.routePoints;
          _instructions = routeInfo.instructions;
          _selectedMarker = null;
          _calculateRouteSummary();
          _mapController.fitCamera(
            CameraFit.bounds(
              bounds: LatLngBounds.fromPoints(_routePoints),
              padding: const EdgeInsets.all(50),
            ),
          );
        });
      }
    } catch (e) {
      if (mounted) _showSnackBar('Gagal memuat rute: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startNavigation() {
    if (_routePoints.isEmpty || _instructions.isEmpty) {
      _showSnackBar('Tidak ada rute untuk dinavigasikan.');
      return;
    }
    _stopCompassListener();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NavigationScreen(
          initialInstructions: _instructions,
          initialRoutePoints: _routePoints,
        ),
      ),
    ).then((_) {
      if (mounted) _startCompassListener();
    });
  }

  void _clearRoute() {
    setState(() {
      _routePoints.clear();
      _instructions.clear();
    });
  }

  void _calculateRouteSummary() {
    double totalDistance = 0;
    double totalDuration = 0;
    for (var instruction in _instructions) {
      totalDistance += instruction.distance;
      totalDuration += instruction.duration;
    }
    setState(() {
      _routeDistance = (totalDistance / 1000).toStringAsFixed(1);
      _routeDuration = (totalDuration / 60).ceil().toString();
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  void _onSearch(String query) {
    setState(() {
      List<MarkerModel> sourceMarkers = _selectedCategory == null
          ? _markers
          : _markers
              .where((m) => m.getKategory() == _selectedCategory)
              .toList();
      _filteredMarkers = _searchService.searchMarkers(sourceMarkers, query);
      _suggestions = query.isEmpty
          ? []
          : _filteredMarkers.map((m) => m.namaMarker).toList();
    });
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
      _searchController.clear();
      _filteredMarkers = category == null
          ? _markers
          : _markers.where((m) => m.getKategory() == category).toList();
    });
  }

  void _onSuggestionTap(String selectedSuggestion) {
    setState(() {
      final selected =
          _markers.firstWhere((m) => m.namaMarker == selectedSuggestion);
      _selectedMarker = selected;
      _mapController.move(selected.coordinates, 17.5);
      _suggestions.clear();
      _searchController.clear();
      FocusScope.of(context).unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final locationProvider = Provider.of<LocationProvider>(context);

    return PopScope(
      canPop: _selectedMarker == null && _routePoints.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_routePoints.isNotEmpty) {
          _clearRoute();
        } else if (_selectedMarker != null) {
          setState(() => _selectedMarker = null);
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(
              height: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const TemaBackground(
                    showAnimals: false,
                    displayMode: BackgroundDisplayMode.topOnly,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: CustomBar(
                      onSearch: _onSearch,
                      categories:
                          _markers.map((e) => e.getKategory()).toSet().toList(),
                      selectedCategory: _selectedCategory,
                      onCategorySelected: _onCategorySelected,
                      suggestions: _suggestions,
                      onSuggestionTap: _onSuggestionTap,
                      searchController: _searchController,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _initialCoordinates,
                      initialZoom: 16.0,
                      maxZoom: 22.0,
                      minZoom: 16.0,
                      // PERBAIKAN: Hapus cameraConstraint
                      // cameraConstraint: CameraConstraint.contain(bounds: kbsBounds),

                      // BARU: Tambahkan logika ini untuk membatasi pergerakan peta
                      onPositionChanged: (position, hasGesture) {
                        if (hasGesture) {
                          if (!kbsBounds.contains(position.center)) {
                            // Clamp the center to the bounds manually
                            final lat = position.center.latitude.clamp(
                              kbsBounds.southWest.latitude,
                              kbsBounds.northEast.latitude,
                            );
                            final lng = position.center.longitude.clamp(
                              kbsBounds.southWest.longitude,
                              kbsBounds.northEast.longitude,
                            );
                            final constrainedCenter = LatLng(lat, lng);

                            Future.microtask(() => _mapController.move(
                                constrainedCenter, position.zoom));
                          }
                        }
                        // Update zoom level seperti biasa
                        if (position.zoom != _currentZoom) {
                          setState(() => _currentZoom = position.zoom);
                        }
                      },
                      onTap: (_, __) => setState(() => _selectedMarker = null),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: "id.kbs.mobile",
                      ),
                      PolylineLayer(polylines: [
                        Polyline(
                            points: _routePoints,
                            color: Colors.blue.shade700,
                            strokeWidth: 5),
                      ]),
                      MarkerLayer(
                        markers: [
                          ..._filteredMarkers.map((marker) {
                            final markerSize = screenSize.width * 0.1;
                            return Marker(
                              point: marker.coordinates,
                              width: markerSize,
                              height: markerSize,
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedMarker = marker),
                                child: _currentZoom > 16.5
                                    ? _buildDetailedMarker(
                                        markerSize, marker.iconUrl)
                                    : _buildSimpleMarker(markerSize),
                              ),
                            );
                          }),
                          if (locationProvider.currentPosition != null)
                            Marker(
                              point: locationProvider.currentPosition!,
                              width: 40,
                              height: 40,
                              child: Transform.rotate(
                                angle: _heading != null
                                    ? (_heading! * (pi / 180))
                                    : 0,
                                child: Image.asset('assets/icon/arah.png'),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  if (_selectedMarker != null) _buildMarkerPopup(screenSize),
                  if (_routePoints.isNotEmpty) _buildRouteInfoPanel(),
                  if (_isLoading) _buildLoadingIndicator(),
                  Positioned(
                    bottom: _routePoints.isNotEmpty ? 150 : 20,
                    right: 20,
                    child: Tooltip(
                      message: 'Tampilkan Lokasi Saya',
                      child: FloatingActionButton(
                        onPressed: () {
                          // PERBAIKAN: Logika cerdas untuk tombol "My Location"
                          final userPosition = locationProvider.currentPosition;
                          if (userPosition == null) {
                            _showSnackBar('Mencari lokasi Anda...');
                            return;
                          }
                          if (kbsBounds.contains(userPosition)) {
                            _mapController.move(userPosition, 17.5);
                          } else {
                            _mapController.move(_initialCoordinates, 16.0);
                            _showSnackBar(
                                'Anda berada di luar area Kebun Binatang Surabaya.');
                          }
                        },
                        child: const Icon(Icons.my_location),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widget Builders ---

  Widget _buildSimpleMarker(double size) =>
      Icon(Icons.location_pin, color: Colors.green.shade700, size: size);

  Widget _buildDetailedMarker(double size, String iconUrl) {
    if (iconUrl.isEmpty) {
      return _buildSimpleMarker(size);
    }
    return CachedNetworkImage(
      imageUrl: iconUrl,
      width: size,
      height: size,
      fit: BoxFit.contain,
      placeholder: (context, url) => _buildSimpleMarker(size),
      errorWidget: (context, url, error) => _buildSimpleMarker(size),
    );
  }

  Widget _buildRouteInfoPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Card(
        margin: const EdgeInsets.all(16),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Estimasi Perjalanan',
                          style: TextStyle(color: Colors.grey)),
                      Text(
                        '$_routeDuration mnt • $_routeDistance km',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: _clearRoute,
                    tooltip: "Batal Rute",
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: _startNavigation,
                child: const Text('Mulai Navigasi',
                    style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildMarkerPopup(Size screenSize) {
    if (_selectedMarker == null) return const SizedBox.shrink();
    final marker = _selectedMarker!;
    return GestureDetector(
      onTap: () => setState(() => _selectedMarker = null),
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Card(
            elevation: 8,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(marker.namaDetail ?? marker.namaMarker,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Hero(
                    tag: 'hewan-image-${marker.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      // PERBAIKAN: Gunakan CachedNetworkImage untuk gambar di popup
                      child: CachedNetworkImage(
                        imageUrl: marker.gambarDetailUrl ?? '',
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: double.infinity,
                          height: 150,
                          color: Colors.grey.shade200,
                          child:
                              const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                            'assets/gambar/tiger.jpg',
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  html.Html(
                    data: marker.deskripsi ?? "Deskripsi tidak tersedia.",
                    style: {
                      "body": html.Style(
                        fontSize: html.FontSize(15.0),
                        color: Colors.grey[700],
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        textOverflow: TextOverflow.ellipsis,
                      ),
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700),
                        onPressed: () => _loadRoute(marker.coordinates),
                        icon: const Icon(Icons.directions_rounded,
                            color: Colors.white),
                        label: const Text('Rute',
                            style: TextStyle(color: Colors.white)),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            _navigateToHewanScreen(context, marker),
                        icon: const Icon(Icons.info_outline_rounded),
                        label: const Text('Detail'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
