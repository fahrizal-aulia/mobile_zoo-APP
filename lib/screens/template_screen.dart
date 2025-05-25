import 'package:flutter/material.dart';

class TemplateScreen extends StatelessWidget {
  final Widget body;

  const TemplateScreen({Key? key, required this.body}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/bg_gabung.png',
              fit: BoxFit.cover,
            ),
          ),
          // Left image
          Positioned(
            bottom: 0,
            left: 0,
            width: 800,
            height: 800,
            child: Image.asset('assets/bawah.png'),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Image.asset('assets/pohon_kanan_2.png'),
          ),
          // Center content
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: MediaQuery.of(context)
                    .size
                    .height, // Pastikan memiliki tinggi
                child: body, // Use the body passed to the template
              ),
            ),
          ),
        ],
      ),
    );
  }
}
