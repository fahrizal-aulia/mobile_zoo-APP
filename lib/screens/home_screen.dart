// File: lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart'; // BARU: Import Hive
import 'package:myapp/screens/info_tiket_screen.dart';
import 'package:myapp/screens/souvenir_screen.dart';
import 'package:myapp/screens/spot_foto_screen.dart';
import 'event_screen.dart';
import 'info_tiket_screen.dart';
import 'spot_foto_screen.dart';
import 'sejarah_screen.dart';
import 'souvenir_screen.dart';
import 'paket_tiket_screen.dart';
import '../widget/tema_background.dart';
import '../api/api_service.dart'; // Tetap diperlukan untuk sinkronisasi di masa depan
import '../model/event_model.dart';
import '../model/tiket_model.dart';
import '../model/spot_foto_model.dart';
import '../model/souvenir_model.dart';

typedef NavigationCallback = void Function(int index);

class HomeScreen extends StatefulWidget {
  final NavigationCallback onNavigate;
  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // PERBAIKAN: Gunakan List biasa, bukan Future
  List<EventModel> _events = [];
  TiketModel? _tiket;
  SpotFotoModel? _spotFoto;
  SouvenirModel? _souvenir;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // PERBAIKAN: Panggil fungsi untuk memuat data dari Hive
    _loadDataFromHive();
  }

  // BARU: Fungsi untuk membaca semua data langsung dari database Hive
  Future<void> _loadDataFromHive() async {
    // Buka semua kotak yang diperlukan
    final eventsBox = await Hive.openBox<EventModel>('eventsBox');
    final tiketsBox = await Hive.openBox<TiketModel>('tiketsBox');
    final spotFotosBox = await Hive.openBox<SpotFotoModel>('spotFotosBox');
    final souvenirsBox = await Hive.openBox<SouvenirModel>('souvenirsBox');

    if (mounted) {
      setState(() {
        _events = eventsBox.values.toList();
        _tiket = tiketsBox.values.firstOrNull;
        _spotFoto = spotFotosBox.values.firstOrNull;
        _souvenir = souvenirsBox.values.firstOrNull;
        _isLoading = false;
      });
    }
  }

  void _navigateToInfoPage(Widget screen) {
    // Pindah ke tab Info (indeks 3)
    widget.onNavigate(3);
    // Setelah frame selesai, dorong halaman spesifik di atas InfoScreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => screen));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TemaBackground(
        showAnimals: true,
        child: SafeArea(
          bottom: false,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- BAGIAN STATIS (TIDAK SCROLL) ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: _buildHeader(context),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildWelcomeCard(context),
                    ),
                    const SizedBox(height: 16),

                    // --- BAGIAN YANG BISA DI-SCROLL ---
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildEventsSection(context, _events),
                              const SizedBox(height: 24),
                              _buildMainMenu(
                                  context, _tiket, _spotFoto, _souvenir),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    // Panggil fungsi sinkronisasi utama
    await ApiService.synchronizeAllData();
    // Muat ulang data dari Hive setelah sinkronisasi selesai
    await _loadDataFromHive();
  }

  // --- SEMUA HELPER METHOD (TIDAK BERUBAH) ---
  Widget _buildHeader(BuildContext context) {
    return const Text('Kebun Binatang Surabaya',
        style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A535C)));
  }

  Widget _buildWelcomeCard(BuildContext context) {
    String formattedDate =
        DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Stack(
        children: [
          Image.asset('assets/poster/cardzoo.png',
              fit: BoxFit.cover, height: 150, width: double.infinity),
          Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.5)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selamat Datang!',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text(formattedDate,
                    style:
                        const TextStyle(fontSize: 16, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsSection(BuildContext context, List<EventModel> events) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Berita & Event',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A535C))),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: events.isEmpty
              ? const Center(child: Text('Saat ini belum ada event.'))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      margin: const EdgeInsets.only(right: 16),
                      child: InkWell(
                        // PERBAIKAN: onTap sekarang mengarah ke halaman Event
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const EventScreen()));
                        },
                        child: SizedBox(
                          width: 250,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: event.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.broken_image,
                                        color: Colors.grey),
                              ),
                              Container(
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: [
                                    Colors.black.withOpacity(0.0),
                                    Colors.black.withOpacity(0.6)
                                  ],
                                          begin: Alignment.center,
                                          end: Alignment.bottomCenter))),
                              Positioned(
                                bottom: 8,
                                left: 8,
                                right: 8,
                                child: Text(
                                  event.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    shadows: [
                                      Shadow(
                                          color: Colors.black54, blurRadius: 4)
                                    ],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMainMenu(BuildContext context, TiketModel? tiket,
      SpotFotoModel? spotFoto, SouvenirModel? souvenir) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildMenuCard(context,
            title: 'Peta Interaktif',
            imageUrl: null,
            imagePath: 'assets/poster/petacard.jpg',
            onTap: () => widget.onNavigate(1)), // Indeks 1 untuk Peta
        _buildMenuCard(context,
            title: 'Tiket',
            imageUrl: tiket?.imageUrl,
            imagePath: 'assets/tiket/tiket_promo.png',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const InfoTiketScreen()))), // Buka InfoScreen (indeks 3) untuk tiket
        _buildMenuCard(context,
            title: 'Spot Foto',
            imageUrl: spotFoto?.imageUrl,
            imagePath: 'assets/spots/spot_1.png',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SpotFotoScreen()))),
        _buildMenuCard(context,
            title: 'Souvenir',
            imageUrl: souvenir?.imageUrl,
            imagePath: 'assets/poster/infografik.png',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const SouvenirScreen()))), // Buka InfoScreen (indeks 3) untuk souvenir
      ],
    );
  }

  Widget _buildMenuCard(BuildContext context,
      {required String title,
      String? imageUrl,
      required String imagePath,
      required VoidCallback onTap}) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Positioned.fill(
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey.shade200),
                      errorWidget: (context, url, error) =>
                          Image.asset(imagePath, fit: BoxFit.cover))
                  : Image.asset(imagePath, fit: BoxFit.cover),
            ),
            Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
              Colors.black.withOpacity(0.6),
              Colors.transparent
            ], begin: Alignment.bottomCenter, end: Alignment.center))),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
