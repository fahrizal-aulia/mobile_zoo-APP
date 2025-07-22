import 'package:flutter/material.dart';
import 'dart:ui'; // Diperlukan untuk ImageFilter
import 'info_tiket_screen.dart';
import 'spot_foto_screen.dart';
import 'sejarah_screen.dart';
import 'souvenir_screen.dart';
import '../widget/tema_background.dart';

class InfoMenuItem {
  final String title;
  final IconData icon;
  final Widget destinationScreen;

  const InfoMenuItem({
    required this.title,
    required this.icon,
    required this.destinationScreen,
  });
}

class InfoScreen extends StatefulWidget {
  // Diubah menjadi StatefulWidget untuk menangani animasi
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen>
    with SingleTickerProviderStateMixin {
  final List<InfoMenuItem> _infoMenu = [
    InfoMenuItem(
        title: 'Info Tiket',
        icon: Icons.confirmation_number_rounded,
        destinationScreen: InfoTiketScreen()),
    InfoMenuItem(
        title: 'Spot Foto',
        icon: Icons.camera_alt_rounded,
        destinationScreen: SpotFotoScreen()),
    InfoMenuItem(
        title: 'Sejarah',
        icon: Icons.history_edu_rounded,
        destinationScreen: SejarahScreen()),
    InfoMenuItem(
        title: 'Souvenir',
        icon: Icons.shopping_bag_rounded,
        destinationScreen: SouvenirScreen()),
  ];

  // BARU: Controller dan variabel untuk animasi
  late AnimationController _animationController;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Membuat animasi terpisah untuk setiap item list
    _slideAnimations = List.generate(
      _infoMenu.length,
      (index) => Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.4 + (index * 0.1), // Delay staggered
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TemaBackground(
        showAnimals: true,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Pusatkan semua konten
              children: [
                // const Spacer(flex: 0),
                // Logo dan Judul dengan animasi
                FadeTransition(
                  opacity: _animationController,
                  child: Column(
                    children: [
                      Image.asset('assets/icon/icon_screen.png',
                          width: MediaQuery.of(context).size.width * 0.4),
                      const SizedBox(height: 12),
                      const Text(
                        'Informasi Pengunjung',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A535C),
                          shadows: [
                            Shadow(
                                blurRadius: 2.0,
                                color: Colors.white,
                                offset: Offset(1.0, 1.0))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // PERBAIKAN: ListView tidak lagi di dalam Expanded
                // Ini membuat ukurannya pas sesuai konten, tidak meregang
                ListView.builder(
                  shrinkWrap:
                      true, // Penting agar ListView tidak error di dalam Column
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _infoMenu.length,
                  itemBuilder: (context, index) {
                    final item = _infoMenu[index];
                    // Setiap item dibungkus dengan widget animasi
                    return FadeTransition(
                      opacity: _animationController,
                      child: SlideTransition(
                        position: _slideAnimations[index],
                        child: _buildMenuItem(item),
                      ),
                    );
                  },
                ),

                const Spacer(flex: 3),
                const Text(
                  'Powered by KBS x UWP',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // BARU: Helper widget untuk membangun setiap item menu
  Widget _buildMenuItem(InfoMenuItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF4ECDC4).withOpacity(0.8),
                child: Icon(item.icon, color: Colors.white, size: 28),
              ),
              title: Text(
                item.title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E4645)),
              ),
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF2E4645)),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => item.destinationScreen));
              },
            ),
          ),
        ),
      ),
    );
  }
}
