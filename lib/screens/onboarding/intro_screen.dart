import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'signup_screen.dart';
import '../login_screen.dart'; // Add this import
import 'package:lucide_icons/lucide_icons.dart';
import '../../widgets/kobo_logo.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfaf8f5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Logo
              const KoboLogo(size: 64, showTagline: true)
                  .animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              
              const SizedBox(height: 24),
              
              Text(
                'Welcome to KOBO',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2c3e50),
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn().slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 16),
              
              Text(
                'The easiest way to manage your business sales, track inventory, and grow your profits.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF7f8c8d),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 48),

              // Benefits List
              _buildBenefitItem(LucideIcons.banknote, 'Track daily sales easily'),
              const SizedBox(height: 16),
              _buildBenefitItem(LucideIcons.package, 'Manage your stock inventory'),
              const SizedBox(height: 16),
              _buildBenefitItem(LucideIcons.trendingUp, 'Grow your business with insights'),

              const Spacer(),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27ae60),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Text(
                        'Create Account',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: Text(
                  'Already have an account? Log In',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF27ae60),
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF27ae60).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF27ae60), size: 20),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF2c3e50),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideX();
  }
}
