import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui';
import '../widget/tema_background.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
  );
  bool _isProcessing = false;
  bool _isTorchOn = false;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing || !mounted) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue != null) {
      setState(() => _isProcessing = true);
      _cameraController.stop();
      HapticFeedback.lightImpact();

      final uri = Uri.tryParse(barcode!.rawValue!);

      if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
        await _showConfirmationDialog(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Kode QR tidak berisi link yang valid.')),
          );
        }
      }

      if (mounted) {
        setState(() => _isProcessing = false);
        _cameraController.start();
      }
    }
  }

  Future<void> _showConfirmationDialog(Uri uri) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Buka Link?',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/animation/qr_animation.json', height: 100),
              const SizedBox(height: 10),
              const Text('Anda akan membuka link detail hewan:',
                  textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(
                uri.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              child: const Text('Batal',
                  style: TextStyle(color: Colors.redAccent)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text('Buka'),
              onPressed: () async {
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tidak dapat membuka link: $uri')),
                    );
                  }
                }
                if (mounted) Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scannerSize = size.width * 0.8;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Scan QR Code Hewan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isTorchOn ? Icons.flash_off : Icons.flash_on),
            onPressed: () {
              setState(() => _isTorchOn = !_isTorchOn);
              _cameraController.toggleTorch();
            },
          ),
        ],
      ),
      body: TemaBackground(
        showAnimals: true,
        child: Stack(
          children: [
            // Background yang terlihat di semua sisi
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),

            // Area scanner di tengah
            Center(
              child: Container(
                width: scannerSize,
                height: scannerSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.2), width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: MobileScanner(
                    controller: _cameraController,
                    onDetect: _onDetect,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Overlay dengan efek frosted glass
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                ),
              ),
            ),

            // Bingkai scanner
            Center(
              child: CustomPaint(
                size: Size(scannerSize, scannerSize),
                painter: _ScannerBoxPainter(),
              ),
            ),

            // Animasi garis scan
            Center(
              child: SizedBox(
                width: scannerSize,
                height: scannerSize,
                child: Lottie.asset(
                  'assets/animation/scan.json',
                  fit: BoxFit.fill,
                ),
              ),
            ),

            // Petunjuk penggunaan
            Positioned(
              bottom: size.height * 0.15,
              left: 0,
              right: 0,
              child: const Column(
                children: [
                  Text(
                    'Arahkan kamera ke QR Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pastikan QR Code berada dalam bingkai',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.tealAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final cornerSize = 30.0;
    final cornerWidth = 5.0;

    // Top-left corner
    canvas.drawLine(Offset(0, cornerSize), Offset(0, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(cornerSize, 0), paint);

    // Top-right corner
    canvas.drawLine(
        Offset(size.width - cornerSize, 0), Offset(size.width, 0), paint);
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, cornerSize), paint);

    // Bottom-left corner
    canvas.drawLine(
        Offset(0, size.height - cornerSize), Offset(0, size.height), paint);
    canvas.drawLine(
        Offset(0, size.height), Offset(cornerSize, size.height), paint);

    // Bottom-right corner
    canvas.drawLine(Offset(size.width - cornerSize, size.height),
        Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width, size.height - cornerSize), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
