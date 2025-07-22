import 'package:flutter/material.dart';
import 'dart:ui'; // Diperlukan untuk ImageFilter (blur)
import '../widget/tema_background.dart'; // Pastikan path ini benar

class SejarahScreen extends StatefulWidget {
  const SejarahScreen({super.key});

  @override
  State<SejarahScreen> createState() => _SejarahScreenState();
}

class _SejarahScreenState extends State<SejarahScreen>
    with SingleTickerProviderStateMixin {
  // Controller untuk animasi
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimationText;
  late Animation<Offset> _slideAnimationImage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Animasi untuk kartu teks
    _slideAnimationText = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    // Animasi untuk infografik (sedikit delay)
    _slideAnimationImage = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut)));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showImageDialog(BuildContext context, String imagePath) {
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
                panEnabled: true,
                minScale: 1.0,
                maxScale: 4.0,
                child: Image.asset(imagePath, fit: BoxFit.contain),
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
    const String infographicPath = 'assets/poster/Infografik.png';

    // PERBAIKAN: Definisikan warna teks agar kontras
    const Color textColor =
        Color.fromARGB(255, 46, 70, 69); // Hijau Tua Kehitaman

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
                        child: Icon(Icons.arrow_back, color: Colors.black87),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Sejarah KBS',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor, // Menggunakan warna baru
                      ),
                    ),
                  ],
                ),
              ),

              // --- Konten Utama yang bisa di-scroll ---
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    children: [
                      // Kartu Teks Status (dengan animasi)
                      SlideTransition(
                        position: _slideAnimationText,
                        child: FadeTransition(
                          opacity: _animationController,
                          child: _buildStatusCard(
                              textColor), // Kirim warna ke widget
                        ),
                      ),

                      const SizedBox(height: 32), // Jarak lebih besar

                      // Infografik (dengan animasi)
                      SlideTransition(
                        position: _slideAnimationImage,
                        child: FadeTransition(
                          opacity: _animationController,
                          child: Column(
                            children: [
                              // PERBAIKAN: Menambahkan judul untuk infografik
                              const Text(
                                'Linimasa Sejarah',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () =>
                                    _showImageDialog(context, infographicPath),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.black38,
                                          blurRadius: 15,
                                          offset: Offset(0, 8)),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset(infographicPath),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ketuk infografik untuk memperbesar',
                                style: TextStyle(
                                  color: textColor.withOpacity(0.7),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk kartu "frosted glass"
  Widget _buildStatusCard(Color textColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.black
                .withOpacity(0.05), // Sedikit lebih gelap agar kontras
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PERBAIKAN: Teks dipecah menjadi Judul dan Deskripsi
              Text(
                'Status',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Berdirinya PD. Taman Satwa KBS merupakan peninggalan jaman Belanda, dimana pembentukan sebagai BUMD berdasarkan Perda Kota Surabaya No. 19 Tahun 2012 tentang PDTS KBS sejak bulan Juli 2012, dan pada Tahun 2019 dikeluarkannya Surat Keputusan pengakuan PDTS KBS sebagai Lembaga Konservasi dengan nomor SK. 340/Menlhk/Setjen/KSA.2/5/2019.',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  height: 1.5, // Jarak antar baris
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
