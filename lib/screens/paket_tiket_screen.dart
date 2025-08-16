// File: lib/screens/paket_tiket_screen.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import '../widget/tema_background.dart';
import '../model/paket_model.dart';

class PaketTiketScreen extends StatefulWidget {
  const PaketTiketScreen({super.key});

  @override
  State<PaketTiketScreen> createState() => _PaketTiketScreenState();
}

class _PaketTiketScreenState extends State<PaketTiketScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  double _currentPageValue = 0.0;

  List<PaketModel> _pakets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaketsFromHive();
    _pageController.addListener(() {
      if (_pageController.page != null) {
        setState(() => _currentPageValue = _pageController.page!);
      }
    });
  }

  Future<void> _loadPaketsFromHive() async {
    final box = await Hive.openBox<PaketModel>('paketsBox');
    if (mounted) {
      setState(() {
        _pakets = box.values.toList();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        showAnimals: true,
        displayMode: BackgroundDisplayMode.full,
        child: SafeArea(
          child: Column(
            children: [
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
                    const Text('Paket & Promo Tiket',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 46, 70, 69),
                            shadows: [
                              Shadow(blurRadius: 4, color: Colors.black54)
                            ])),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Text(
                    'Jangan lewatkan Paket Promo Tiket di Kebun Binatang Surabaya!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16, color: Color.fromARGB(255, 46, 70, 69))),
              ),
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

    if (_pakets.isEmpty) {
      return const Center(
        child: Text(
          "Informasi paket tidak tersedia.\nPastikan Anda memiliki koneksi internet saat pertama kali membuka aplikasi.",
          textAlign: TextAlign.center,
          style:
              TextStyle(color: Color.fromARGB(255, 46, 70, 69), fontSize: 16),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _pakets.length,
            itemBuilder: (context, index) {
              double scale = 1.0;
              if (_pageController.position.haveDimensions) {
                scale = 1 - (_currentPageValue - index).abs() * 0.2;
                scale = scale.clamp(0.8, 1.0);
              }
              return Transform.scale(
                scale: scale,
                child: _buildPaketCard(_pakets[index]),
              );
            },
          ),
        ),
        if (_pakets.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: _pakets.length,
              effect: WormEffect(
                dotHeight: 12,
                dotWidth: 12,
                activeDotColor: Colors.teal.shade200,
                dotColor: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPaketCard(PaketModel paket) {
    return GestureDetector(
      onTap: () => _showImageDialog(context, paket.imageUrl),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white, // Warna placeholder
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 15, offset: Offset(0, 10))
          ],
        ),
        // PERBAIKAN: Gunakan ClipRRect untuk memotong gambar
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: CachedNetworkImage(
            imageUrl: paket.imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) =>
                const Icon(Icons.error, color: Colors.red),
          ),
        ),
      ),
    );
  }
}
