import 'package:flutter/material.dart';
import '../widget/tema_background.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// Model data untuk event
class EventModel {
  final String title;
  final String imagePath;
  // Properti lain bisa disimpan di sini untuk halaman detail nanti
  // final String date;
  // final String description;

  const EventModel({
    required this.title,
    required this.imagePath,
    // required this.date,
    // required this.description,
  });
}

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  double _currentPageValue = 0.0;

  // Data event
  final List<EventModel> _events = [
    EventModel(
      title: "Wahana Kid's Zoo",
      imagePath: 'assets/poster/happy_kids.jpg',
    ),
    EventModel(
      title: "Holirap Day",
      imagePath: 'assets/poster/holirap.jpg',
    ),
    EventModel(
      title: "Lokasi Parkir",
      imagePath: 'assets/poster/parkir.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page != null) {
        setState(() {
          _currentPageValue = _pageController.page!;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // BARU: Fungsi untuk menampilkan dialog gambar
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
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/bg_gabung.png', fit: BoxFit.cover),
          ),
          const TemaBackground(
            showAnimals: false,
            showBunglon: true,
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Event Spesial',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 46, 70, 69),
                    shadows: [Shadow(blurRadius: 5.0, color: Colors.black54)],
                  ),
                ),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Text(
                    'Jangan lewatkan berbagai keseruan di Kebun Binatang Surabaya!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 46, 70, 69),
                      shadows: [Shadow(blurRadius: 3.0, color: Colors.black54)],
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      double scale = 1.0;
                      if (_pageController.position.haveDimensions) {
                        scale = 1 - (_currentPageValue - index).abs() * 0.2;
                        scale = scale.clamp(0.8, 1.0);
                      }
                      return Transform.scale(
                        scale: scale,
                        child: _buildEventCard(_events[index]),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: _events.length,
                    effect: WormEffect(
                      // Anda bisa ganti efeknya
                      dotHeight: 12,
                      dotWidth: 12,
                      activeDotColor: Colors.teal.shade200,
                      dotColor: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(EventModel event) {
    return GestureDetector(
      // BARU: Menambahkan onTap untuk memanggil dialog
      onTap: () => _showImageDialog(context, event.imagePath),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: AssetImage(event.imagePath),
            fit: BoxFit.cover,
          ),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 15, offset: Offset(0, 10)),
          ],
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child:
                  // PERBAIKAN: Hanya menampilkan judul
                  Text(
                event.title,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black54)]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
