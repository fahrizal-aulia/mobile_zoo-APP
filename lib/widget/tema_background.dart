// File: lib/widget/tema_background.dart

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TemaBackground extends StatelessWidget {
  final Widget? child;
  final bool showAnimals;
  final bool showBunglon;

  const TemaBackground({
    super.key,
    this.child,
    this.showAnimals = true,
    this.showBunglon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // --- Lapisan Latar Belakang & Dekorasi ---
        Positioned.fill(
          child: Image.asset(
            'assets/bg_gabung.png',
            fit: BoxFit.cover,
          ),
        ),

        if (showAnimals) ...[
          // Align(
          //   alignment: Alignment.centerLeft,
          //   child: Lottie.asset(
          //     'assets/animation/bunglon_animation.json',
          //     width: MediaQuery.of(context).size.width * 0.35,
          //   ),
          // ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Lottie.asset(
              'assets/animation/jerapah_animation.json',
              width: MediaQuery.of(context).size.width * 0.7,
            ),
          ),
        ],
        if (showBunglon) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Lottie.asset(
              'assets/animation/bunglon_animation.json',
              width: MediaQuery.of(context).size.width * 0.35,
            ),
          ),
        ],
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
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Image.asset('assets/kiri2.png'),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          // bottom: 0,
          child: Image.asset('assets/atas.png'),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Transform.flip(
            flipX: true,
            child: Image.asset('assets/atas.png', fit: BoxFit.fitWidth),
          ),
        ),

        // PERBAIKAN: `child` hanya akan ditampilkan jika tidak null
        if (child != null) child!,
      ],
    );
  }
}
