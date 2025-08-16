// File: lib/screens/app_shell.dart

import 'package:flutter/material.dart';
import 'package:myapp/screens/camera_screen.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/info_screen.dart';
import 'package:myapp/screens/peta_screen.dart';
// BARU: Import semua layar detail
import 'package:myapp/screens/event_screen.dart';
import 'package:myapp/screens/paket_tiket_screen.dart';
import 'package:myapp/screens/souvenir_screen.dart';
import 'package:myapp/screens/spot_foto_screen.dart';
import 'package:myapp/screens/sejarah_screen.dart';
import 'package:myapp/screens/info_tiket_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Fungsi navigasi yang bisa dipanggil dari mana saja
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index < 4 ? index : 3; // Jika > 3, anggap Info yang aktif
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    // PERBAIKAN: Tambahkan semua halaman ke daftar
    final List<Widget> pages = [
      HomeScreen(onNavigate: _onItemTapped), // 0: Home
      PetaScreen(), // 1: Peta
      const CameraScreen(), // 2: Scan
      const InfoScreen(), // 3: Info
      // Halaman "tersembunyi" yang bisa diakses dari HomeScreen
      const EventScreen(), // 4
      const PaketTiketScreen(), // 5
      const SpotFotoScreen(), // 6
      const SouvenirScreen(), // 7
      const SejarahScreen(), // 8
      const InfoTiketScreen(), // 9
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          // Sinkronkan BottomNavBar saat halaman berganti
          if (index < 4) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal.shade700,
        unselectedItemColor: Colors.grey.shade600,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: 'Peta'),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner_rounded), label: 'Scan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.info_rounded), label: 'Info'),
        ],
      ),
    );
  }
}
