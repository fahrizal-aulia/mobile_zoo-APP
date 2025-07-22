import 'package:flutter/material.dart';
import '../widget/tema_background.dart';

// BARU: Model data untuk setiap spot foto
class SpotFotoModel {
  final String name;
  final String imagePath;

  const SpotFotoModel({required this.name, required this.imagePath});
}

class SpotFotoScreen extends StatefulWidget {
  const SpotFotoScreen({super.key});

  @override
  State<SpotFotoScreen> createState() => _SpotFotoScreenState();
}

class _SpotFotoScreenState extends State<SpotFotoScreen>
    with SingleTickerProviderStateMixin {
  // Data untuk 9 spot foto, ganti nama dan path gambar sesuai kebutuhan
  final List<SpotFotoModel> _photoSpots = List.generate(
    9,
    (index) => SpotFotoModel(
      name: 'Spot Foto ${index + 1}',
      imagePath:
          'assets/spots/spot_${index + 1}.jpg', // Pastikan nama file Anda seperti ini
    ),
  );

  // Controller untuk animasi
  late AnimationController _animationController;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Membuat animasi terpisah untuk setiap item grid
    _animations = List.generate(
      _photoSpots.length,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * (1.0 / _photoSpots.length),
            1.0,
            curve: Curves.easeOut,
          ),
        ),
      ),
    );

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
    return Scaffold(
      body: TemaBackground(
        showAnimals: true,
        showBunglon: false,
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
                      'Spot Foto Menarik',
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

              // --- Galeri Foto ---
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 kolom
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8, // Rasio kartu
                  ),
                  itemCount: _photoSpots.length,
                  itemBuilder: (context, index) {
                    final spot = _photoSpots[index];
                    return FadeTransition(
                      opacity: _animations[index],
                      child: _buildPhotoCard(spot),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoCard(SpotFotoModel spot) {
    return GestureDetector(
      onTap: () => _showImageDialog(context, spot.imagePath),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior:
            Clip.antiAlias, // Penting agar gambar mengikuti bentuk kartu
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Gambar spot foto
            Image.asset(
              spot.imagePath,
              fit: BoxFit.cover,
              // Tampilkan placeholder saat loading (opsional tapi bagus)
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOut,
                  child: child,
                );
              },
            ),
            // Gradasi gelap di bawah agar teks mudah dibaca
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            // Judul spot foto
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Text(
                spot.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 2, color: Colors.black87)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
