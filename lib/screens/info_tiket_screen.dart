import 'package:flutter/material.dart';
import '../widget/tema_background.dart'; // Pastikan path ini benar

class InfoTiketScreen extends StatelessWidget {
  const InfoTiketScreen({super.key});

  // BARU: Fungsi untuk menampilkan dialog gambar yang bisa di-zoom
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
              // Widget ini memungkinkan gambar untuk di-zoom dan digeser
              InteractiveViewer(
                panEnabled: true,
                minScale: 1.0,
                maxScale: 4.0,
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
              // Tombol tutup
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
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
    // Path ke gambar tiket Anda
    const String ticketImagePath = 'assets/tiket/tiket_promo.png';

    return Scaffold(
      body: TemaBackground(
        // Menggunakan tema latar belakang tanpa animasi hewan
        showAnimals: false,
        child: SafeArea(
          child: Column(
            children: [
              // --- Header Kustom ---
              Padding(
                padding: const EdgeInsets.all(10.0),
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
                      'Informasi Tiket',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 46, 70, 69),
                        shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                      ),
                    ),
                  ],
                ),
              ),

              // --- Konten Utama ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        'Promo Paket Tiket Terbaru',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 46, 70, 69),
                            shadows: [
                              Shadow(blurRadius: 4, color: Colors.black54)
                            ]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ketuk gambar di bawah untuk memperbesar dan melihat detail promo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 46, 70, 69)
                                .withOpacity(0.8),
                            shadows: const [
                              Shadow(blurRadius: 2, color: Colors.black54)
                            ]),
                      ),
                      const SizedBox(height: 24),

                      // BARU: Gambar tiket yang interaktif
                      GestureDetector(
                        onTap: () => _showImageDialog(context, ticketImagePath),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 15,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(ticketImagePath),
                          ),
                        ),
                      ),
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
}
