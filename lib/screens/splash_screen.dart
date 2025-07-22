import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:myapp/main.dart'; // Pastikan path import ini benar

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Latar Belakang (Lapisan 1, paling bawah)
          Positioned.fill(
            child: Image.asset(
              'assets/bg_gabung.png',
              fit: BoxFit.cover,
            ),
          ),

          // Dekorasi bawah (Lapisan 2)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset('assets/bawah.png', fit: BoxFit.fitWidth),
          ),

          // Dekorasi kanan (Lapisan 3)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Image.asset('assets/pohon_kanan_2.png'),
          ),

          // PERBAIKAN 2: Animasi Bunglon dipindahkan ke sini (Lapisan 4)
          // agar berada di bawah aset daun kiri.
          Align(
            alignment: Alignment.centerLeft,
            child: Lottie.asset(
              'assets/animation/bunglon_animation.json',
              width: MediaQuery.of(context).size.width * 0.35,
            ),
          ),

          // Dekorasi kiri (Lapisan 5, sekarang di atas bunglon)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Image.asset('assets/kiri2.png'),
          ),

          // PERBAIKAN 1: Menggunakan Align untuk menggeser konten ke atas
          Align(
            alignment:
                const Alignment(0.0, -0.8), // Geser sedikit ke atas dari tengah
            child: Column(
              mainAxisSize: MainAxisSize.min, // Ukuran kolom seperlunya
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
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Animasi Jerapah (Lapisan terakhir, paling atas)
          Align(
            alignment: Alignment.bottomCenter,
            child: Lottie.asset(
              'assets/animation/jerapah_animation.json',
              width: MediaQuery.of(context).size.width * 0.7,
            ),
          ),
        ],
      ),
    );
  }
}
