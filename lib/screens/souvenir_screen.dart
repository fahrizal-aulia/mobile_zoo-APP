// File: lib/screens/souvenir_screen.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widget/tema_background.dart';
import '../model/souvenir_model.dart';

class SouvenirScreen extends StatefulWidget {
  const SouvenirScreen({super.key});

  @override
  State<SouvenirScreen> createState() => _SouvenirScreenState();
}

class _SouvenirScreenState extends State<SouvenirScreen>
    with SingleTickerProviderStateMixin {
  List<SouvenirModel> _souvenirSpots = [];
  bool _isLoading = true;

  late AnimationController _animationController;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _loadSouvenirsFromHive();
  }

  Future<void> _loadSouvenirsFromHive() async {
    final box = await Hive.openBox<SouvenirModel>('souvenirsBox');
    final souvenirsFromDb = box.values.toList();

    if (mounted) {
      setState(() {
        _souvenirSpots = souvenirsFromDb;
        _isLoading = false;
      });

      if (_souvenirSpots.isNotEmpty) {
        _animationController = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1000),
        );

        _animations = List.generate(
          _souvenirSpots.length,
          (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(index * (1.0 / _souvenirSpots.length), 1.0,
                  curve: Curves.easeOut),
            ),
          ),
        );
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    if (mounted && _souvenirSpots.isNotEmpty) {
      _animationController.dispose();
    }
    super.dispose();
  }

  void _showImageDialog(BuildContext context, String imageUrl, String title) {
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
                    const Text('Pusat Oleh-Oleh',
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
    if (_souvenirSpots.isEmpty) {
      return const Center(
          child: Text("Informasi souvenir tidak tersedia.",
              style: TextStyle(
                  color: Color.fromARGB(255, 46, 70, 69), fontSize: 16)));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _souvenirSpots.length,
      itemBuilder: (context, index) {
        final spot = _souvenirSpots[index];
        return FadeTransition(
          opacity: _animations[index],
          child: _buildSouvenirCard(spot),
        );
      },
    );
  }

  Widget _buildSouvenirCard(SouvenirModel spot) {
    return GestureDetector(
      onTap: () => _showImageDialog(context, spot.imageUrl, spot.namaSouvenir),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // PERBAIKAN: Menggunakan CachedNetworkImage
            CachedNetworkImage(
              imageUrl: spot.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 40, color: Colors.grey),
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
                spot.namaSouvenir,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 2, color: Colors.black87)]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
