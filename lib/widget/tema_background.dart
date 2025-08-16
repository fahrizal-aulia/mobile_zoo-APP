// File: lib/widget/tema_background.dart

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// Enum untuk mengontrol bagian mana dari tema yang akan ditampilkan
enum BackgroundDisplayMode { full, topOnly }

class TemaBackground extends StatelessWidget {
  final Widget? child;
  final bool showAnimals;
  final BackgroundDisplayMode displayMode;

  const TemaBackground({
    super.key,
    this.child,
    this.showAnimals = true,
    this.displayMode = BackgroundDisplayMode.full,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Latar Belakang & Dekorasi Atas (Selalu Tampil)
        Positioned.fill(
          child: Image.asset('assets/bg_gabung.png', fit: BoxFit.cover),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Image.asset('assets/atas.png', fit: BoxFit.fitWidth),
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

        // Lapisan Bawah & Animasi (Hanya Tampil dalam Mode 'full')
        if (displayMode == BackgroundDisplayMode.full) ...[
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Transform.flip(
              flipY: true,
              child: Image.asset('assets/atas.png', fit: BoxFit.fitWidth),
            ),
          ),
          if (showAnimals)
            Align(
              alignment: Alignment.bottomCenter,
              child: Lottie.asset(
                'assets/animation/jerapah_animation.json',
                width: MediaQuery.of(context).size.width * 0.7,
              ),
            ),
        ],

        if (showAnimals)
          Align(
            alignment: Alignment.centerLeft,
            child: Lottie.asset(
              'assets/animation/bunglon_animation.json',
              width: MediaQuery.of(context).size.width * 0.35,
            ),
          ),

        if (child != null) child!,
      ],
    );
  }
}
