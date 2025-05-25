import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  MobileScannerController cameraController = MobileScannerController();
  String? scannedData;
  bool isDialogOpen = false;

  void _showConfirmationDialog(String url) {
    setState(() {
      isDialogOpen = true;
    });

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title:
              Text('Buka Link?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Lottie.network(
                    'https://lottie.host/97f25c00-1e99-43bd-8911-359c486931b1/yd6EmYwqFc.json',
                    height: 120),
                SizedBox(height: 10),
                Text('Anda akan diarahkan ke:'),
                Text(url,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Batal', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isDialogOpen = false;
                });
                cameraController.start();
              },
            ),
            TextButton(
              child: Text('Buka', style: TextStyle(color: Colors.blueAccent)),
              onPressed: () async {
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tidak dapat membuka link')),
                  );
                }
                Navigator.of(context).pop();
                setState(() {
                  isDialogOpen = false;
                });
                cameraController.start();
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
      appBar: AppBar(
        title: Text('Scan Barcode'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty && !isDialogOpen) {
                      setState(() {
                        scannedData = barcodes.first.rawValue;
                      });
                      if (scannedData != null) {
                        cameraController.stop();
                        _showConfirmationDialog(scannedData!);
                      }
                    }
                  },
                ),
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.network(
                          'https://lottie.host/97f25c00-1e99-43bd-8911-359c486931b1/yd6EmYwqFc.json',
                          height: 120),
                      Text(
                        'Arahkan kamera ke barcode',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  scannedData = null;
                });
                cameraController.start();
              },
              icon: Icon(Icons.refresh, color: Colors.white),
              label: Text('Mulai Ulang Scan', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
