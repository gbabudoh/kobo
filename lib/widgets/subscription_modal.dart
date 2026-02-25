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
  String _country = 'Nigeria';
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
        _country = user.country;
        _koboId = user.koboId;
      });
    }
  }

  Future<void> _handleUpgrade() async {
    setState(() => _isProcessing = true);
    
    final price = CurrencyHelper.getSubscriptionPrice(_country);
    
    // Paystack currency codes
    String currencyCode = 'NGN';
    if (_country == 'Ghana') currencyCode = 'GHS';
    if (_country == 'South Africa') currencyCode = 'ZAR';

    final success = await SubscriptionService.processUpgrade(
      context,
      email: '${_koboId.toLowerCase()}@kobo.com', 
      amount: price.toDouble(),
      currency: currencyCode,
    );
    
    if (mounted) {
      setState(() => _isProcessing = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome to Kobbo Pro! Cloud Sync Activated.'),
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
    final price = CurrencyHelper.getSubscriptionPrice(_country);
    final formattedPrice = CurrencyHelper.format(price, _country);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.all(32),
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
          const SizedBox(height: 32),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF27ae60).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.crown, size: 16, color: Color(0xFF27ae60)),
                const SizedBox(width: 8),
                Text(
                  'Kobbo Pro',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF27ae60),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            'Keep Your Business Safe',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Get 1 Month of Cloud Backup and Multi-device sync for just $formattedPrice.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          _buildBenefitRow(LucideIcons.cloudLightning, 'Unlimited Cloud Backup', 'Never lose your records if you lose your phone.'),
          const SizedBox(height: 24),
          _buildBenefitRow(LucideIcons.smartphone, 'Multi-device Sync', 'Manage your shop from any phone simultaneously.'),
          const SizedBox(height: 24),
          _buildBenefitRow(LucideIcons.lock, 'Business Security', 'Secure PostgreSQL storage on your private VPS.'),
          
          const SizedBox(height: 48),

          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _handleUpgrade,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27ae60),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: _isProcessing 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                : Text(
                    'UPGRADE FOR $formattedPrice / MONTH',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Cancel anytime. 1 month free trial included for all new users.',
            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF27ae60), size: 24),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
