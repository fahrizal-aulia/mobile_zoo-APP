import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; // Import untuk SystemChrome
import 'package:back_button_interceptor/back_button_interceptor.dart'; // Import paket back_button_interceptor
import 'providers/location_map_provider.dart'; // Sesuaikan dengan file provider Anda
import 'screens/peta_screen.dart';
import 'screens/camera_screen.dart';
// import 'screens/saran_screen.dart';
// import 'screens/info_screen.dart';
import 'screens/splash_screen.dart'; // Tambahkan import untuk SplashScreen

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) =>
          LocationProvider(), // Mengasumsikan Anda memiliki LocationProvider
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Tampilkan SplashScreen saat aplikasi dibuka
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  DateTime? _lastBackPressed;

  final List<Widget> _pages = [
    PetaScreen(),
    CameraScreen(),
    // InfoScreen(),
    // SaranScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Aktifkan interceptor
    BackButtonInterceptor.add(_interceptBackButton);
    // Mengatur mode layar penuh tanpa menyembunyikan tombol navigasi
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    // Hapus interceptor saat widget dihancurkan
    BackButtonInterceptor.remove(_interceptBackButton);
    super.dispose();
  }

  /// Logika untuk double back press
  bool _interceptBackButton(bool stopDefaultButtonEvent, RouteInfo info) {
    DateTime now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > Duration(seconds: 2)) {
      _lastBackPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tekan dua kali untuk keluar')),
      );
      return true; // Blokir back button event
    }
    return false; // Izinkan back button untuk keluar
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mengatur status bar dan navigation bar menjadi transparan
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Status bar transparan
      systemNavigationBarColor: Colors.transparent, // Navigation bar transparan
      systemNavigationBarIconBrightness:
          Brightness.light, // Ikon di navigation bar
    ));

    return Scaffold(
      body: _pages[_currentIndex],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(2.0),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(1, 50, 51, 1),
                  Color.fromRGBO(1, 62, 63, 1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          centerTitle: true,
          elevation: 0, // Menghilangkan bayangan
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(1, 50, 51, 1),
          borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(1, 62, 63, 1),
              blurRadius: 0,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Peta',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera),
              label: 'Kamera',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.info),
            //   label: 'Info',
            // ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.info),
            //   label: 'Saran',
            // ),
          ],
          currentIndex: _currentIndex,
          selectedItemColor: const Color.fromRGBO(1, 117, 105, 1),
          unselectedItemColor: Colors.grey,
          backgroundColor:
              Colors.transparent, // Membuat latar belakang transparan
          elevation: 0, // Menghilangkan bayangan
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
