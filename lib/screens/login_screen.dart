import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../services/database_service.dart';
import 'home_screen.dart';
import 'onboarding/intro_screen.dart';
import 'admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _koboIdController = TextEditingController();
  final List<TextEditingController> _pinControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _pinFocusNodes = List.generate(4, (_) => FocusNode());
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _koboIdController.dispose();
    for (var c in _pinControllers) {
      c.dispose();
    }
    for (var f in _pinFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate network delay for better UX
    await Future.delayed(const Duration(milliseconds: 800));

    // Try Local Login first
  User? user = await StorageService.getUser();
  
  final enteredPin = _pinControllers.map((c) => c.text).join();
  final cleanKoboId = _koboIdController.text.trim().toUpperCase();

  // If local user exists and matches, login
  if (user != null && user.koboId == cleanKoboId && user.pin == enteredPin) {
      if (context.mounted) {
        if (user.role == 'admin') {
           Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
        } else {
           Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
      return;
  }

  // If local failed, try Remote DB (e.g. for Admin or new device login)
  try {
    debugPrint("Attempting remote login for ID: $cleanKoboId");
    final dbService = DatabaseService();
    final remoteUser = await dbService.login(cleanKoboId, enteredPin);
    await dbService.close();

    debugPrint("Remote login result: ${remoteUser?.koboId}");

    if (remoteUser != null) {
      // Success! Cache user locally and login
      await StorageService.saveUser(remoteUser);
      
      if (context.mounted) {
        if (remoteUser.role == 'admin') {
           Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
        } else {
           Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
      return;
    } else {
      debugPrint("Remote login returned null (invalid credentials or user not found)");
    }
  } catch (e) {
    // Ignore DB errors for now, fall through to error message
    debugPrint("Remote login failed with exception: $e");
  }

  if (context.mounted) {
    setState(() {
      _isLoading = false;
      _errorMessage = "Invalid Kobo ID or PIN";
    });
  }
}

  void _onPinChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _pinFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _pinFocusNodes[index - 1].requestFocus();
    }
    
    // Always rebuild to update the button state
    setState(() {
      if (_errorMessage != null) {
        _errorMessage = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isPinComplete = _pinControllers.every((c) => c.text.isNotEmpty);
    bool isIdNotEmpty = _koboIdController.text.isNotEmpty;
    bool canLogin = isPinComplete && isIdNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
           Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                              BoxShadow(
                              color: const Color(0xFF27ae60).withOpacity(0.15),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                              ),
                          ],
                        ),
                        child: const Icon(LucideIcons.lock, color: Color(0xFF27ae60), size: 32),
                      ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Center(
                      child: Text(
                        "Welcome Back",
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ).animate().fadeIn().slideY(begin: 0.3, end: 0),
                    ),
                    
                    const SizedBox(height: 8),
                     Center(
                       child: Text(
                        "Enter your Kobo ID and PIN to login",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
                        ),
                                           ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
                     ),

                    const SizedBox(height: 48),

                    // Kobo ID Input
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Padding(
                                padding: const EdgeInsets.only(left: 4, bottom: 8),
                                child: Text(
                                    "KOBO ID",
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF94A3B8),
                                        letterSpacing: 1.2,
                                    ),
                                ),
                            ),
                            TextField(
                                controller: _koboIdController,
                                onChanged: (val) => setState(() => _errorMessage = null),
                                style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1E293B),
                                    letterSpacing: 1.2,
                                ),
                                decoration: InputDecoration(
                                    hintText: "KOBO-XXXX",
                                    hintStyle: GoogleFonts.outfit(color: const Color(0xFFCBD5E1)),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(color: Color(0xFF27ae60), width: 2),
                                    ),
                                ),
                            ),
                        ],
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 24),

                    // PIN Input
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Padding(
                                padding: const EdgeInsets.only(left: 4, bottom: 12),
                                child: Text(
                                    "ENTER 4-DIGIT PIN",
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF94A3B8),
                                        letterSpacing: 1.2,
                                    ),
                                ),
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(4, (index) {
                                  return SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: TextField(
                                      controller: _pinControllers[index],
                                      focusNode: _pinFocusNodes[index],
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      maxLength: 1,
                                      obscureText: true,
                                      obscuringCharacter: '●',
                                      onChanged: (value) => _onPinChanged(index, value),
                                      style: GoogleFonts.outfit(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1E293B),
                                      ),
                                      decoration: InputDecoration(
                                        counterText: "",
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: const BorderSide(color: Color(0xFF27ae60), width: 2),
                                        ),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                    ),
                                  );
                                }),
                            ),
                        ],
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

                    if (_errorMessage != null)
                        Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    const Icon(LucideIcons.alertCircle, color: Colors.red, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                        _errorMessage!,
                                        style: GoogleFonts.inter(
                                            color: Colors.red,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                        ),
                                    ),
                                ],
                            ).animate().fadeIn().shake(),
                        ),

                    const SizedBox(height: 48),

                    SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                            onPressed: canLogin && !_isLoading ? _login : null,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF27ae60),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                ),
                            ),
                            child: _isLoading 
                                ? const SizedBox(
                                    width: 24, 
                                    height: 24, 
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                  )
                                : Text(
                                    "LOGIN",
                                    style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2.0,
                                    ),
                                  ),
                        ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 24),
                    
                    TextButton(
                      onPressed: () async {
                        await StorageService.clearUser();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                             MaterialPageRoute(
                               builder: (_) => const IntroScreen(),
                             ), 
                          );
                        }
                      }, 
                      child: Text(
                        "Reset App (Debug)",
                        style: GoogleFonts.inter(
                          color: Colors.red.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      )
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
