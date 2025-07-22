// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:myapp/screens/event_screen.dart';
import 'package:provider/provider.dart';
import 'providers/location_map_provider.dart';
import 'screens/peta_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/event_screen.dart';
import 'screens/info_screen.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(
    ChangeNotifierProvider(
      create: (context) => LocationProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const SplashScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  DateTime? _lastBackPressed;

  // PERBAIKAN: Gunakan PageStorageKey untuk membantu menjaga beberapa state sederhana
  final List<Widget> _pages = [
    PetaScreen(key: const PageStorageKey('PetaScreen')),
    const CameraScreen(key: PageStorageKey('CameraScreen')),
    const EventScreen(key: PageStorageKey('EventScreen')),
    const InfoScreen(key: PageStorageKey('InfoScreen')),
  ];

  // Bucket untuk menyimpan state scroll, dll.
  final PageStorageBucket _bucket = PageStorageBucket();

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);
  }

  void _handlePop() {
    DateTime now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tekan sekali lagi untuk keluar')),
      );
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handlePop();
      },
      child: Scaffold(
        // PERBAIKAN: Kembali ke cara sederhana, TANPA IndexedStack.
        // Ini akan memanggil `dispose` pada halaman yang tidak aktif,
        // melepaskan sumber daya kamera, GPS, dan kompas.
        body: PageStorage(
          bucket: _bucket,
          child: _pages[_currentIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                activeIcon: Icon(Icons.map),
                label: 'Peta'),
            BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt_outlined),
                activeIcon: Icon(Icons.camera_alt),
                label: 'Kamera'),
            BottomNavigationBarItem(
                icon: Icon(Icons.event_available),
                activeIcon: Icon(Icons.event),
                label: 'Event'),
            BottomNavigationBarItem(
                icon: Icon(Icons.info_outline),
                activeIcon: Icon(Icons.info),
                label: 'Tentang'),
          ],
          currentIndex: _currentIndex,
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.grey.shade600,
          backgroundColor: Colors.white,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          elevation: 10.0,
        ),
      ),
    );
  }
}
