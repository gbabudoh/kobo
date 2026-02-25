import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';
import '../widgets/kobo_logo.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _koboIdController = TextEditingController();
  final _pinController = TextEditingController(); // Using single field for PIN on web
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final koboId = _koboIdController.text.trim().toUpperCase();
    final pin = _pinController.text.trim();

    if (koboId.isEmpty || pin.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Please enter both ID and Password";
      });
      return;
    }

    try {
      final dbService = DatabaseService();
      final user = await dbService.login(koboId, pin);
      await dbService.close();

      if (user != null) {
        if (user.role == 'admin') {
          // Success: Admin
          await StorageService.saveUser(user);
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            );
          }
        } else {
          // Failed: Not Admin
          setState(() {
            _isLoading = false;
            _errorMessage = "Access Restricted: Admins Only";
          });
        }
      } else {
         setState(() {
            _isLoading = false;
            _errorMessage = "Invalid Credentials";
          });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Connection Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2c3e50), // Dark background for admin feel
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: KoboLogo(size: 48, showTagline: true),
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'KOBBO ADMIN',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2c3e50),
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Dashboard Login',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[100]!),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red[800], fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),

              TextField(
                controller: _koboIdController,
                decoration: InputDecoration(
                  labelText: 'Admin ID',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _pinController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password / PIN',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onSubmitted: (_) => _login(),
              ),
              const SizedBox(height: 30),
              
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2c3e50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'LOGIN TO DASHBOARD',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold, 
                            color: Colors.white
                          ),
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
