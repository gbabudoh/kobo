import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/user.dart';
import '../../services/storage_service.dart';
import '../../services/database_service.dart';
import '../home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  final String country;
  final String firstName;
  final String surname;
  final String? businessName;
  final String pin;
  final String businessType;

  const WelcomeScreen({
    super.key,
    required this.country,
    required this.firstName,
    required this.surname,
    this.businessName,
    required this.pin,
    required this.businessType,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late String koboId;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    koboId = StorageService.generateKoboId();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _copyKoboId() {
    Clipboard.setData(ClipboardData(text: koboId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kobo ID copied to clipboard!'),
        backgroundColor: Color(0xFF27ae60),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _enterKobo() async {
    final user = User(
      koboId: koboId,
      country: widget.country,
      firstName: widget.firstName,
      surname: widget.surname,
      businessName: widget.businessName,
      pin: widget.pin,
      businessType: widget.businessType,
      createdAt: DateTime.now(),
    );

    await StorageService.saveUser(user);
    
    // Sync with backend
    try {
      final success = await DatabaseService().registerUser(user);
      if (!success) {
        debugPrint('Failed to sync user with backend');
        // We still proceed since it's saved locally, but ideally we'd want to retry or alert
      }
    } catch (e) {
      debugPrint('Error syncing user: $e');
    }

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }
  }

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

              // Success Animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF27ae60).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '🎉',
                      style: TextStyle(fontSize: 64),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const Text(
                      'Welcome!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your account is ready!',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF7f8c8d),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Kobo ID Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF27ae60), Color(0xFF1a5f2a)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF27ae60).withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Your Kobo ID',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            koboId,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _copyKoboId,
                            icon: const Icon(Icons.copy, size: 18),
                            label: const Text('Copy ID'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Important Note
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFfff3cd),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFffc107),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text('⚠️', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Write this down or screenshot it. You\'ll need it to log in.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.brown[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Enter Kobo Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _enterKobo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27ae60),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Enter Kobo',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
