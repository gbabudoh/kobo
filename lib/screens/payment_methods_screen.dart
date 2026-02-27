import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/payment_methods.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final _paystackController = TextEditingController();
  final _opayController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('payment_methods');
    if (json != null) {
      final methods = PaymentMethods.fromJson(jsonDecode(json));
      _paystackController.text = methods.paystackEmail ?? '';
      _opayController.text = methods.opayNumber ?? '';
      _bankNameController.text = methods.bankName ?? '';
      _accountNumberController.text = methods.accountNumber ?? '';
      _accountNameController.text = methods.accountName ?? '';
    }
    setState(() => _isLoading = false);
  }

  Future<void> _savePaymentMethods() async {
    setState(() => _isSaving = true);
    
    final methods = PaymentMethods(
      paystackEmail: _paystackController.text.trim(),
      opayNumber: _opayController.text.trim(),
      bankName: _bankNameController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
      accountName: _accountNameController.text.trim(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('payment_methods', jsonEncode(methods.toJson()));

    setState(() => _isSaving = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment methods saved!'),
          backgroundColor: Color(0xFF27ae60),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a5f2a),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment Methods',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF27ae60)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3498db).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF3498db).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.info, color: Color(0xFF3498db), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Add your payment details so customers can pay you directly.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFF3498db),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Paystack Section
                  _buildSectionHeader(
                    icon: LucideIcons.creditCard,
                    title: 'Paystack',
                    subtitle: 'Receive card payments',
                    color: const Color(0xFF00C3F7),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _paystackController,
                    label: 'Paystack Email',
                    hint: 'email@example.com',
                    icon: LucideIcons.mail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),

                  // OPay Section
                  _buildSectionHeader(
                    icon: LucideIcons.smartphone,
                    title: 'OPay',
                    subtitle: 'Receive mobile payments',
                    color: const Color(0xFF1DC96C),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _opayController,
                    label: 'OPay Phone Number',
                    hint: '08012345678',
                    icon: LucideIcons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),

                  // Bank Transfer Section
                  _buildSectionHeader(
                    icon: LucideIcons.landmark,
                    title: 'Bank Transfer',
                    subtitle: 'Receive direct transfers',
                    color: const Color(0xFF8B5CF6),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _bankNameController,
                    label: 'Bank Name',
                    hint: 'e.g. GTBank, First Bank',
                    icon: LucideIcons.building,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _accountNumberController,
                    label: 'Account Number',
                    hint: '0123456789',
                    icon: LucideIcons.hash,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _accountNameController,
                    label: 'Account Name',
                    hint: 'Your account name',
                    icon: LucideIcons.user,
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _savePaymentMethods,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27ae60),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'Save Payment Methods',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2c3e50),
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF7f8c8d),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF7f8c8d)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFe8e8e8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFe8e8e8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF27ae60), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  @override
  void dispose() {
    _paystackController.dispose();
    _opayController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }
}
