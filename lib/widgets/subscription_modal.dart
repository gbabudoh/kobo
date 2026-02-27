import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/subscription_service.dart';
import '../services/storage_service.dart';
import '../utils/currency_helper.dart';

class SubscriptionModal extends StatefulWidget {
  const SubscriptionModal({super.key});

  @override
  State<SubscriptionModal> createState() => _SubscriptionModalState();
}

class _SubscriptionModalState extends State<SubscriptionModal> {
  bool _isProcessing = false;
  String _koboId = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = await StorageService.getUser();
    if (user != null) {
      setState(() {
        _koboId = user.koboId;
      });
    }
  }

  Future<void> _handleUpgrade() async {
    setState(() => _isProcessing = true);
    
    final price = CurrencyHelper.getSubscriptionPrice('Nigeria');

    final success = await SubscriptionService.processUpgrade(
      context,
      email: '${_koboId.toLowerCase()}@kobo.app', 
      amount: price.toDouble(),
      currency: 'NGN',
    );
    
    if (mounted) {
      setState(() => _isProcessing = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome to KOBO Pro! Your account is now upgraded.'),
            backgroundColor: Color(0xFF27ae60),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment failed or cancelled. Please try again.'),
            backgroundColor: Color(0xFFe74c3c),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = CurrencyHelper.getSubscriptionPrice('Nigeria');
    final formattedPrice = CurrencyHelper.format(price, 'Nigeria');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Pro Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF27ae60), Color(0xFF1a5f2a)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.crown, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'KOBO PRO',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              'Upgrade Your Business',
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Get Pro features for just $formattedPrice/year',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Benefits
            _buildBenefitRow(
              LucideIcons.creditCard, 
              'Receive Payments', 
              'Setup Paystack, OPay, and bank transfer to receive payments from customers.',
              const Color(0xFF3498db),
            ),
            const SizedBox(height: 20),
            _buildBenefitRow(
              LucideIcons.fileText, 
              'KOBO-Vault', 
              'Download your trade history as PDF to get loans from banks and microfinance.',
              const Color(0xFF9b59b6),
            ),
            const SizedBox(height: 20),
            _buildBenefitRow(
              LucideIcons.cloudLightning, 
              'Cloud Backup', 
              'Never lose your records. Your data is safely backed up.',
              const Color(0xFF27ae60),
            ),
            const SizedBox(height: 20),
            _buildBenefitRow(
              LucideIcons.smartphone, 
              'Multi-device Sync', 
              'Access your business from any phone.',
              const Color(0xFFe67e22),
            ),
            
            const SizedBox(height: 32),

            // Price Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFf8f9fa),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF27ae60), width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    formattedPrice,
                    style: GoogleFonts.outfit(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF27ae60),
                    ),
                  ),
                  Text(
                    'per year',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27ae60).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Save ₦7,000 vs monthly',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF27ae60),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Upgrade Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _handleUpgrade,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27ae60),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isProcessing 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : Text(
                      'UPGRADE NOW',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Secure payment via Paystack',
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String title, String subtitle, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B), height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
