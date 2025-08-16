// File: lib/screens/info_tiket_screen.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widget/tema_background.dart';
import '../model/tiket_model.dart';

class InfoTiketScreen extends StatefulWidget {
  const InfoTiketScreen({super.key});

  @override
  State<InfoTiketScreen> createState() => _InfoTiketScreenState();
}

class _InfoTiketScreenState extends State<InfoTiketScreen> {
  // PERBAIKAN: Gunakan List biasa untuk menampung data dari Hive
  List<TiketModel> _tikets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // PERBAIKAN: Panggil fungsi untuk memuat data dari Hive
    _loadTicketsFromHive();
  }

  // BARU: Fungsi untuk membaca data langsung dari database Hive
  Future<void> _loadTicketsFromHive() async {
    final box = await Hive.openBox<TiketModel>('tiketsBox');
    if (mounted) {
      setState(() {
        _tikets = box.values.toList();
        _isLoading = false;
      });
    }
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, color: Colors.white),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TemaBackground(
        showAnimals: false,
        child: SafeArea(
          child: Column(
            children: [
              // --- Header Kustom ---
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const CircleAvatar(
                          backgroundColor: Colors.white70,
                          child: Icon(Icons.arrow_back, color: Colors.black87)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 16),
                    const Text('Info Tiket Masuk',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 46, 70, 69))),
                  ],
                ),
              ),

              // --- Konten Utama ---
              Expanded(
                child: _buildContentView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_tikets.isEmpty) {
      return const Center(
        child: Text(
          "Informasi tiket tidak tersedia.\nPastikan koneksi internet aktif saat pertama kali membuka aplikasi.",
          textAlign: TextAlign.center,
          style:
              TextStyle(color: Color.fromARGB(255, 46, 70, 69), fontSize: 16),
        ),
      );
    }

    // Tampilkan gambar tiket pertama dari data Hive
    final tiket = _tikets.first;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            tiket.namaTiket,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 46, 70, 69)),
          ),
          const SizedBox(height: 8),
          Text(
            'Ketuk gambar di bawah untuk memperbesar.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16,
                color: const Color.fromARGB(255, 46, 70, 69).withOpacity(0.8)),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _showImageDialog(context, tiket.imageUrl),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black38,
                      blurRadius: 15,
                      offset: Offset(0, 8))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: tiket.imageUrl,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.broken_image, size: 50),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
