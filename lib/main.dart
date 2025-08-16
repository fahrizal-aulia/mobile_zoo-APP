import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'model/event_model.dart';
import 'model/markers.dart';
import 'model/spot_foto_model.dart';
import 'model/souvenir_model.dart';
import 'model/paket_model.dart';
import 'model/tiket_model.dart';
import 'model/latlng_adapter.dart';

import 'providers/location_map_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/app_shell.dart'; // Pastikan Anda sudah memiliki file ini

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  await initializeDateFormatting('id_ID', null);
  Hive.registerAdapter(EventModelAdapter());
  Hive.registerAdapter(MarkerModelAdapter());
  Hive.registerAdapter(SpotFotoModelAdapter());
  Hive.registerAdapter(SouvenirModelAdapter());
  Hive.registerAdapter(PaketModelAdapter());
  Hive.registerAdapter(TiketModelAdapter());
  Hive.registerAdapter(LatLngAdapter());

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
      title: 'KBS Mobile App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
    );
  }
}
