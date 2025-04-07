import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
//import 'screens/login_page.dart';
import 'screens/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/app_provider.dart';
import 'services/mysql_database_service.dart';
import 'services/auth_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize MySQL database
  final mysqlService = ApiDatabaseService();

  // Uncomment to create database schema on first run
  // await mysqlService.createDatabaseSchema();

  // Initialize auth service
  final authService = AuthService(mysqlService);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: mysqlService),
        Provider.value(value: authService),
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(create: (_) => AppProvider(mysqlService)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BTRACK - Bus Tracking System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF9D7BB0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9D7BB0),
          primary: const Color(0xFF9D7BB0),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9D7BB0),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
