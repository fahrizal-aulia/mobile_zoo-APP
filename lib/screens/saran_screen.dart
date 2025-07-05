import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SaranScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          // Right image

          // Lottie bunglon
          Positioned(
            left: 0,
            top: -20,
            right: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.height * 0.26,
                child: Lottie.network(
                  'https://lottie.host/0aa057e7-5060-4c1d-a1d5-7e7a7e9d35f4/dFHMXyFB64.json',
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Image.asset('assets/kiri2.png'),
          ),
          // Lottie jerapah
          Positioned(
            left: 0,
            top: 0,
            right: -80,
            bottom: -115,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.6,
                child: Lottie.network(
                  'https://lottie.host/26d0eab0-4de3-42d5-afc1-5c35794101f6/CEXXn69r83.json',
                ),
              ),
            ),
          ),
          // Center content
          Positioned(
            top: 0, // Move the entire content up
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment:
                    MainAxisAlignment.start, // Align the content to the top
                children: [
                  // Icon with adjusted size
                  Image.asset(
                    'assets/icon/logokbs1.png',
                    width: 150, // Adjust width
                    height: 150, // Adjust height
                  ),
                  SizedBox(
                    height: 20, // Space between icon and text
                  ),
                  // Text with adjusted font size and weight
                  Text(
                    'Selamat Datang Di Kebun Binatang Surabaya!',
                    style: TextStyle(
                      fontSize: 20, // Adjust font size
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Optional: change text color
                    ),
                    textAlign: TextAlign.center, // Center the text
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
