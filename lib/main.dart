import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/onboarding/intro_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'services/storage_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage BEFORE running the app
  try {
    await StorageService.init();
  } catch (e) {
    debugPrint('StorageService init error: $e');
  }
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF1a5f2a),
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const KoboApp());
}

class KoboApp extends StatelessWidget {
  const KoboApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kobo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF388E3C)),
        useMaterial3: true,
        textTheme: GoogleFonts.outfitTextTheme(),
      ),
      home: kIsWeb ? _getWebHome() : const SplashScreen(),
    );
  }

  Widget _getWebHome() {
    final user = StorageService.getUserSync();
    if (user != null && user.role == 'admin') {
      return const AdminDashboardScreen();
    }
    return const AdminLoginScreen();
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleInitialNavigation();
  }

  Future<void> _handleInitialNavigation() async {
    // Only used for Mobile
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    // Always show Intro Screen on startup, even if onboarded
    _navigate(const IntroScreen());
  }

  void _navigate(Widget screen) {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => screen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF27ae60),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🛒', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            const Text(
              'KOBBO',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Market Vendor App',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
