import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui'; // Diperlukan untuk ImageFilter
import '../widget/tema_background.dart'; // Pastikan path ini benar

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final MobileScannerController _cameraController = MobileScannerController(
    // Optimasi untuk deteksi barcode yang lebih cepat
    detectionSpeed: DetectionSpeed.normal,
  );
  bool _isProcessing = false;

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Kode QR tidak berisi link yang valid.')),
        );
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
              Lottie.asset('assets/animations/qr_anim.json', height: 100),
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
    return Scaffold(
      // PERBAIKAN: Latar belakang dibuat transparan agar TemaBackground terlihat
      backgroundColor: Colors.transparent,
      // Hapus AppBar agar lebih imersif
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Scan QR Code Hewan'),
        backgroundColor: Colors.transparent, // AppBar transparan
        elevation: 0, // Hilangkan bayangan
        actions: [
          IconButton(
              tooltip: 'Nyalakan Flash',
              icon: const Icon(Icons.flash_on),
              onPressed: () => _cameraController.toggleTorch()),
        ],
      ),
      body: TemaBackground(
        // Gunakan tema latar belakang tanpa hewan agar tidak terlalu ramai
        showAnimals: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // PERBAIKAN: Kamera di-clip agar sesuai bentuk
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: MobileScanner(
                controller: _cameraController,
                onDetect: _onDetect,
              ),
            ),
            // PERBAIKAN: Desain ulang overlay dengan Frosted Glass
            _ScannerOverlay(
              boxSize: MediaQuery.of(context).size.width * 0.7,
            )
          ],
        ),
      ),
    );
  }
}

// Widget kustom untuk overlay dengan bingkai sudut
class _ScannerOverlay extends StatelessWidget {
  final double boxSize;
  const _ScannerOverlay({required this.boxSize});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // PERBAIKAN: Menggunakan ClipRRect dan BackdropFilter untuk efek "Frosted Glass"
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                width: boxSize,
                height: boxSize,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),

        // Bingkai sudut
        Align(
          alignment: Alignment.center,
          child: CustomPaint(
            size: Size(boxSize, boxSize),
            painter: _ScannerBoxPainter(),
          ),
        ),

        // Animasi garis scan
        Align(
          alignment: Alignment.center,
          child: Lottie.asset(
            'assets/animation/scan.json', // Menggunakan animasi baru
            width: boxSize,
          ),
        ),

        const Align(
          alignment: Alignment(0, 0.55),
          child: Text(
            'Arahkan kamera ke QR Code',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                shadows: [Shadow(blurRadius: 4, color: Colors.black54)]),
          ),
        ),
      ],
    );
  }
}

// BARU: Kustom painter untuk menggambar bingkai sudut
class _ScannerBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.tealAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final cornerSize = 30.0;

    // Top-left
    canvas.drawPath(
        Path()
          ..moveTo(0, cornerSize)
          ..lineTo(0, 0)
          ..lineTo(cornerSize, 0),
        paint);

    // Top-right
    canvas.drawPath(
        Path()
          ..moveTo(size.width - cornerSize, 0)
          ..lineTo(size.width, 0)
          ..lineTo(size.width, cornerSize),
        paint);

    // Bottom-left
    canvas.drawPath(
        Path()
          ..moveTo(0, size.height - cornerSize)
          ..lineTo(0, size.height)
          ..lineTo(cornerSize, size.height),
        paint);

    // Bottom-right
    canvas.drawPath(
        Path()
          ..moveTo(size.width - cornerSize, size.height)
          ..lineTo(size.width, size.height)
          ..lineTo(size.width, size.height - cornerSize),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
