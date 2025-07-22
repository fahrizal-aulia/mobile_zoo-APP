import 'package:flutter/material.dart';
import 'package:myapp/model/markers.dart'; // Sesuaikan path import
import 'package:myapp/widget/tema_background.dart'; // Sesuaikan path import
import 'dart:ui'; // Diperlukan untuk ImageFilter

class HewanScreen extends StatelessWidget {
  final MarkerModel marker;

  const HewanScreen({super.key, required this.marker});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // PERBAIKAN: Definisikan warna teks baru Anda
    const Color textColor = Color.fromARGB(255, 46, 70, 69);

    return Scaffold(
      body: Stack(
        children: [
          const TemaBackground(
            showAnimals: true,
            showBunglon: true,
          ),

          SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  // PERBAIKAN: Mengatur konten agar selalu di tengah secara horizontal
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: screenSize.height * 0.1),

                    // PERBAIKAN: Desain ulang gambar lingkaran
                    Hero(
                      tag: 'hewan-image-${marker.id}',
                      child: Container(
                        width: screenSize.width * 0.6,
                        height: screenSize.width * 0.6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            marker.gambar ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset('assets/gambar/tiger.jpg',
                                    fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      marker.nama_marker ?? 'Detail Hewan',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 5, color: Colors.black54)],
                      ),
                    ),
                    const SizedBox(height: 24),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(
                                0.5), // Latar belakang lebih solid untuk kontras
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Deskripsi',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: textColor, // Menggunakan warna baru
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                marker.deskripsi ??
                                    'Informasi detail tidak tersedia.',
                                textAlign: TextAlign.justify,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: textColor, // Menggunakan warna baru
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // Tombol Kembali Kustom
          Positioned(
            top: 40,
            left: 16,
            child: SafeArea(
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.5),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
