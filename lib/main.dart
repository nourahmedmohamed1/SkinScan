import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/welcome_screen.dart'; // Import the new Welcome Screen
import 'services/scan_history_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide ScanHistory state to the entire app
    return ChangeNotifierProvider(
      create: (context) => ScanHistoryProvider(),
      child: MaterialApp(
        title: 'SkinCareScan',
        debugShowCheckedModeBanner: false,

        // Define Global App Theme
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0B5FA5),
            primary: const Color(0xFF0B5FA5),
            secondary: const Color(0xFF2A85D8),
            surface: const Color(0xFFEAF4FF),
          ),

          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0B5FA5),
            foregroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B5FA5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),

        // Launch the WelcomeScreen first as per project requirements
        home: const WelcomeScreen(),
      ),
    );
  }
}