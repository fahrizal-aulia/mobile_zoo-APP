import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:myapp/api/api_service.dart'; // Import ApiService untuk sinkronisasi
import 'package:myapp/screens/app_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Jalankan sinkronisasi data dari API ke Hive
    await ApiService.synchronizeAllData();

    // Setelah sinkronisasi selesai, baru pindah halaman
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AppShell()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Latar Belakang
          Positioned.fill(
            child: Image.asset('assets/bg_gabung.png', fit: BoxFit.cover),
          ),

          // Dekorasi
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset('assets/bawah.png', fit: BoxFit.fitWidth),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Image.asset('assets/pohon_kanan_2.png'),
          ),

          // Animasi Bunglon
          Align(
            alignment: Alignment.centerLeft,
            child: Lottie.asset(
              'assets/animation/bunglon_animation.json',
              width: MediaQuery.of(context).size.width * 0.35,
            ),
          ),

          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Image.asset('assets/kiri2.png'),
          ),

          // Konten Utama
          Align(
            alignment: const Alignment(0.0, -0.4), // Geser lebih ke atas
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/icon/icon_screen.png',
                  width: MediaQuery.of(context).size.width * 0.45,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Selamat Datang Di Kebun Binatang Surabaya!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A535C),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Animasi Jerapah & Loading Indicator
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/animation/jerapah_animation.json',
                  width: MediaQuery.of(context).size.width * 0.7,
                ),
                // Tampilkan indikator loading saat sinkronisasi
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Menyiapkan data...',
                  style: TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
