import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import '../api/map_marker_api.dart';
import '../providers/location_map_provider.dart';
import '../model/markers.dart';
import '../api/Map_Api.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../model/NavigationInstruction.dart';
import 'navigationscreen.dart';
import 'custom_bar.dart';
import 'search_service.dart'; // Import untuk pencarian

class PetaScreen extends StatefulWidget {
  @override
  _PetaScreenState createState() => _PetaScreenState();
}

class _PetaScreenState extends State<PetaScreen> {
  final MapController _mapController = MapController();
  List<MarkerModel> _markers = [];
  List<MarkerModel> _filteredMarkers = [];
  List<LatLng> _routePoints = [];
  final double _initialZoom = 16.0;
  final LatLng _initialCoordinates = LatLng(-7.295583, 112.736706);
  double? _heading;
  MarkerModel? _selectedMarker;
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();
  List<String> _suggestions = []; // Daftar saran berdasarkan input pengguna

  @override
  void initState() {
    super.initState();
    _loadLocationAndMarkers();
    _startLocationUpdates();

    FlutterCompass.events?.listen((direction) {
      setState(() {
        _heading = direction.heading;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(_initialCoordinates, _initialZoom);
    });
  }

  void _startLocationUpdates() {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    locationProvider.startLocationUpdates(context);
  }

  Future<void> _loadLocationAndMarkers() async {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.getCurrentLocation(context);

    try {
      _markers = await MapMarkerApi.getMarkers();
      _filteredMarkers = _markers;
      setState(() {});
    } catch (e) {
      _showSnackBar('Gagal memuat marker.');
    }
  }

  Future<void> _loadRoute(LatLng destination) async {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);

    if (locationProvider.currentPosition != null) {
      try {
        List<NavigationInstruction> instructions =
            await ApiService.getRouteInstructions(
          locationProvider.currentPosition,
          destination,
        );

        List<LatLng> routePoints = await ApiService.getRoute(
          locationProvider.currentPosition,
          destination,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NavigationScreen(
              instructions: instructions,
              routePoints: routePoints,
            ),
          ),
        );
      } catch (e) {
        _showSnackBar('Gagal memuat rute.');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _clearRoute() {
    setState(() {
      _routePoints.clear();
    });
  }

  List<String> _getCategories() {
    return _markers.map((marker) => marker.getKategory()).toSet().toList();
  }

  void _onSearch(String query) {
    setState(() {
      // Filter marker berdasarkan nama_marker
      _filteredMarkers = _searchService.searchMarkers(_markers, query);

      // Ambil daftar saran (nama_marker) dari hasil pencarian
      _suggestions = query.isEmpty
          ? [] // Kosongkan saran jika query kosong
          : _filteredMarkers
              .map((marker) => marker.nama_marker ?? "Tanpa Nama")
              .toList();
    });
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
      _filteredMarkers = _selectedCategory == null
          ? _markers // Tampilkan semua marker jika kategori "Semua" dipilih
          : _markers
              .where((marker) => marker.getKategory() == category)
              .toList();
    });
  }

  void _onSuggestionTap(String selectedSuggestion) {
    setState(() {
      // Cari marker yang sesuai dengan saran yang dipilih
      _selectedMarker = _markers.firstWhere(
        (marker) => marker.nama_marker == selectedSuggestion,
      );

      // Fokus ke marker yang dipilih
      _mapController.move(_selectedMarker!.coordinates, _initialZoom);

      // Bersihkan daftar saran setelah dipilih
      _suggestions.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          if (_routePoints.isNotEmpty) {
            setState(() {
              _routePoints.clear();
            });
            return false;
          }

          if (_selectedMarker != null) {
            setState(() {
              _selectedMarker = null;
            });
            return false;
          }

          return true;
        },
        child: Column(
          children: [
            CustomBar(
              onSearch: _onSearch,
              categories: _getCategories(),
              selectedCategory: _selectedCategory,
              onCategorySelected: _onCategorySelected,
              suggestions: _suggestions, // Kirim daftar saran ke CustomBar
              onSuggestionTap: _onSuggestionTap, // Kirim handler untuk saran
            ),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _initialCoordinates,
                      initialZoom: _initialZoom,
                      onTap: (tapPosition, point) {
                        setState(() {
                          _selectedMarker = null;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      ),
                      MarkerLayer(
                        markers: _filteredMarkers
                            .map((marker) => Marker(
                                  point: marker.coordinates,
                                  width: 30,
                                  height: 30,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedMarker = marker;
                                      });
                                    },
                                    child: Icon(
                                      Icons.pin_drop,
                                      color: Colors.blue,
                                      size: 30,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            color: Colors.blue,
                            strokeWidth: 4,
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (_selectedMarker != null) _buildMarkerPopup(screenSize),
                  Positioned(
                    bottom: screenSize.height * 0.08,
                    right: screenSize.width * 0.05,
                    child: FloatingActionButton(
                      onPressed: () async {
                        await locationProvider.getCurrentLocation(context);
                        _mapController.move(
                            locationProvider.currentPosition, _initialZoom);
                      },
                      child: const Icon(Icons.my_location),
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

  Widget _buildMarkerPopup(Size screenSize) {
    // Fungsi untuk memotong deskripsi jika lebih dari 100 karakter
    String truncateDescription(String description) {
      const maxLength = 100;
      if (description.length > maxLength) {
        return '${description.substring(0, maxLength)}...';
      }
      return description;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMarker = null;
        });
      },
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Card(
            elevation: 8,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedMarker!.nama_marker ?? "Tanpa Nama",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _selectedMarker!.gambar != null &&
                            _selectedMarker!.gambar!.isNotEmpty
                        ? Image.network(
                            _selectedMarker!.gambar!,
                            width: screenSize.width * 0.6,
                            height: screenSize.width * 0.4,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/gambar/tiger.jpg',
                            width: double.infinity,
                            height: screenSize.width * 0.4,
                            fit: BoxFit.cover,
                          ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    truncateDescription(_selectedMarker!.deskripsi ??
                        "Deskripsi tidak tersedia."),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          _loadRoute(_selectedMarker!.coordinates);
                          setState(() {
                            _selectedMarker = null;
                          });
                        },
                        icon: Icon(Icons.directions),
                        label: Text('Rute'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showAnimalDetail(context);
                        },
                        icon: Icon(Icons.info),
                        label: Text('Detail'),
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

  void _showAnimalDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Memungkinkan modal untuk menyesuaikan tinggi layar
      builder: (context) {
        double screenHeight =
            MediaQuery.of(context).size.height; // Ambil tinggi layar
        double modalHeight =
            screenHeight * 0.75; // Set tinggi modal = 75% tinggi layar

        return Container(
          height: modalHeight, // Gunakan ukuran dalam pixel
          padding: EdgeInsets.fromLTRB(16, 16, 16, 50), // Padding untuk konten
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(20)), // Sudut melengkung
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul
              Text(
                _selectedMarker!.nama_marker ?? "Tanpa Nama",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),

              // Gambar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _selectedMarker!.gambar != null &&
                        _selectedMarker!.gambar!.isNotEmpty
                    ? Image.network(
                        _selectedMarker!.gambar!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/gambar/tiger.jpg',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
              ),
              SizedBox(height: 16),

              // Deskripsi (Scrollable)
              Expanded(
                child: ListView(
                  shrinkWrap:
                      true, // Agar ListView hanya mengambil ruang yang diperlukan
                  children: [
                    Text(
                      _selectedMarker!.deskripsi ?? "Deskripsi tidak tersedia.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),

              // Tombol Tutup
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: Text(
                    'Tutup',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    locationProvider.stopLocationUpdates();
    _searchController.dispose();
    super.dispose();
  }
}
