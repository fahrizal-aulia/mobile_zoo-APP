// File: lib/screens/peta_screen.dart

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../api/map_marker_api.dart';
import '../api/Map_Api.dart';
import '../model/markers.dart';
import '../model/NavigationInstruction.dart';
import '../providers/location_map_provider.dart';
import 'custom_bar.dart';
import 'hewan_screen.dart';
import 'navigationscreen.dart';
import 'search_service.dart';

// tema
import '../widget/tema_background.dart';

class PetaScreen extends StatefulWidget {
  const PetaScreen({super.key});

  @override
  State<PetaScreen> createState() => _PetaScreenState();
}

class _PetaScreenState extends State<PetaScreen> {
  // --- Controllers & State ---
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

  final LatLng _initialCoordinates = const LatLng(-7.295583, 112.736706);
  late LocationProvider _locationProvider;
  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void initState() {
    super.initState();
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    _locationProvider.startLocationUpdates();
    _loadLocationAndMarkers();
    _startCompassListener();

    // Pindahkan listener ke sini agar tidak terpanggil saat build
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

  // --- Listener & Logic ---
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

  Future<void> _loadLocationAndMarkers() async {
    try {
      _markers = await MapMarkerApi.getMarkers();
      _filteredMarkers = _markers;
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) _showSnackBar('Gagal memuat marker.');
    }
  }

  void _navigateToHewanScreen(BuildContext context, MarkerModel marker) {
    // Sembunyikan popup sebelum berpindah halaman
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

    setState(() => _isLoading = true);
    try {
      final routeInfo =
          await ApiService.getRouteAndInstructions(startPosition, destination);
      if (mounted) {
        setState(() {
          _routePoints = routeInfo.routePoints;
          _instructions = routeInfo.instructions;
          _selectedMarker = null;
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

  // --- UI Methods ---
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
          : _filteredMarkers.map((m) => m.nama_marker ?? "Tanpa Nama").toList();
    });
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
      _searchController.clear(); // Hapus teks pencarian saat ganti kategori
      _filteredMarkers = category == null
          ? _markers
          : _markers.where((m) => m.getKategory() == category).toList();
    });
  }

  void _onSuggestionTap(String selectedSuggestion) {
    setState(() {
      final selected =
          _markers.firstWhere((m) => m.nama_marker == selectedSuggestion);
      _selectedMarker = selected;
      _mapController.move(selected.coordinates, 17.5);
      _suggestions.clear();
      _searchController.clear();
      FocusScope.of(context).unfocus();
    });
  }

  // --- Helper Widget Builders ---
  Widget _buildSimpleMarker(double size) =>
      Icon(Icons.location_pin, color: Colors.green.shade700, size: size);

  Widget _buildDetailedMarker(double size) => Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.location_pin, color: Colors.green.shade700, size: size),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Icon(Icons.pets, color: Colors.white, size: size * 0.4),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final locationProvider = Provider.of<LocationProvider>(context);
    // Tentukan tinggi header secara dinamis atau tetap
    const double headerHeight = 150.0;

    return PopScope(
      canPop: _selectedMarker == null && _routePoints.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_routePoints.isNotEmpty) {
          setState(() => _routePoints.clear());
        } else if (_selectedMarker != null) {
          setState(() => _selectedMarker = null);
        }
      },
      child: Scaffold(
        // PERBAIKAN: Menggunakan Stack untuk menumpuk tema, peta, dan custom bar
        body: Stack(
          children: [
            // LAPISAN 1: TEMA LATAR BELAKANG UKURAN PENUH
            const TemaBackground(showBunglon: false),

            // LAPISAN 2: PETA (dimulai dari bawah header)
            Padding(
              padding: const EdgeInsets.only(top: headerHeight),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _initialCoordinates,
                      initialZoom: _currentZoom,
                      maxZoom: 18.0,
                      minZoom: 14.0,
                      onPositionChanged: (position, hasGesture) {
                        if (position.zoom != null &&
                            position.zoom != _currentZoom) {
                          setState(() => _currentZoom = position.zoom!);
                        }
                      },
                      onTap: (_, __) => setState(() => _selectedMarker = null),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        // subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName: "id.kbs.mobile",
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                              points: _routePoints,
                              color: Colors.blue.shade700,
                              strokeWidth: 5),
                        ],
                      ),
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
                                    ? _buildDetailedMarker(markerSize)
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
                  if (_routePoints.isNotEmpty) _buildNavigationButton(),
                  if (_isLoading) _buildLoadingIndicator(),
                  Positioned(
                    bottom:
                        _routePoints.isNotEmpty ? screenSize.height * 0.12 : 20,
                    right: 20,
                    child: FloatingActionButton(
                      onPressed: () {
                        if (locationProvider.currentPosition != null) {
                          _mapController.move(
                              locationProvider.currentPosition!, 17.5);
                        }
                      },
                      child: const Icon(Icons.my_location),
                    ),
                  ),
                ],
              ),
            ),

            // LAPISAN 3: CUSTOM BAR (berada di atas tema dan di area aman)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false, // Hanya peduli pada area aman di atas
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.navigation_rounded),
        label: const Text('Mulai Navigasi'),
        onPressed: _startNavigation,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  Text(marker.nama_marker ?? "Tanpa Nama",
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),

                  // BARU: Menambahkan Hero widget untuk animasi gambar
                  Hero(
                    tag: 'hewan-image-${marker.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        marker.gambar ?? '',
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                            'assets/gambar/tiger.jpg',
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    marker.deskripsi ?? "Deskripsi tidak tersedia.",
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
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
                      // PERBAIKAN: Tombol Detail sekarang menavigasi ke HewanScreen
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

  void _showAnimalDetail(BuildContext context, MarkerModel marker) {
    print('DEBUG: URL Gambar dari API untuk detail: ${marker.gambar}');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                  child: Text(marker.nama_marker ?? "Tanpa Nama",
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold))),
              const SizedBox(height: 16),
              if (marker.gambar != null && marker.gambar!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(marker.gambar!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                              ? child
                              : const Center(
                                  heightFactor: 3,
                                  child: CircularProgressIndicator()),
                      errorBuilder: (context, error, stackTrace) {
                        print(
                            'DEBUG: Gagal memuat gambar dari URL. Error: $error');
                        return Image.asset('assets/gambar/tiger.jpg',
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover);
                      }),
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset('assets/gambar/tiger.jpg',
                      width: double.infinity, height: 200, fit: BoxFit.cover),
                ),
              const SizedBox(height: 16),
              Text(marker.deskripsi ?? "Deskripsi tidak tersedia.",
                  style: TextStyle(
                      fontSize: 16, height: 1.5, color: Colors.grey[850])),
            ],
          ),
        ),
      ),
    );
  }
}
