import 'package:flutter/material.dart';
import '../widget/tema_background.dart';

// BARU: Model data untuk setiap lokasi souvenir
class SouvenirSpotModel {
  final String name;
  final String imagePath;

  const SouvenirSpotModel({required this.name, required this.imagePath});
}

class SouvenirScreen extends StatefulWidget {
  const SouvenirScreen({super.key});

  @override
  State<SouvenirScreen> createState() => _SouvenirScreenState();
}

class _SouvenirScreenState extends State<SouvenirScreen>
    with SingleTickerProviderStateMixin {
  // Data untuk 6 lokasi souvenir, ganti nama dan path gambar sesuai kebutuhan
  final List<SouvenirSpotModel> _souvenirSpots = List.generate(
    6,
    (index) => SouvenirSpotModel(
      name: 'Toko Souvenir ${index + 1}',
      imagePath:
          'assets/souvenir/souvenir_${index + 1}.jpg', // Pastikan nama file Anda seperti ini
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

    _animations = List.generate(
      _souvenirSpots.length,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * (1.0 / _souvenirSpots.length),
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
                      'Pusat Souvenir',
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
                  itemCount: _souvenirSpots.length,
                  itemBuilder: (context, index) {
                    final spot = _souvenirSpots[index];
                    return FadeTransition(
                      opacity: _animations[index],
                      child: _buildSouvenirCard(spot),
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

  Widget _buildSouvenirCard(SouvenirSpotModel spot) {
    return GestureDetector(
      onTap: () => _showImageDialog(context, spot.imagePath),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              spot.imagePath,
              fit: BoxFit.cover,
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
