import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../services/subscription_service.dart';
import 'subscription_modal.dart';

class SettingsModal extends StatefulWidget {
  const SettingsModal({super.key});

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _vpsUrlController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    final details = StorageService.getBankDetails();
    if (details != null) {
      _bankNameController.text = details['bankName'] ?? '';
      _accountNumberController.text = details['accountNumber'] ?? '';
      _accountNameController.text = details['accountName'] ?? '';
    }
    _vpsUrlController.text = StorageService.settingsBox.get('vps_url', defaultValue: 'http://your-vps-ip:3000');
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    
    // Save Bank Details
    await StorageService.saveBankDetails(
      bankName: _bankNameController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
      accountName: _accountNameController.text.trim(),
    );

    // Save VPS URL
    await StorageService.settingsBox.put('vps_url', _vpsUrlController.text.trim());
    
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully!')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _triggerSync() async {
    setState(() => _isSyncing = true);
    await ApiService.syncAllData();
    if (mounted) {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sync attempted! Check your VPS logs.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Settings',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Subscription Status Card
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const SubscriptionModal(),
                ).then((_) => setState(() {}));
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF27ae60).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF27ae60).withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.crown, color: Color(0xFF27ae60), size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            SubscriptionService.statusText,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            SubscriptionService.isPro ? 'Enjoying Pro Features' : 'Upgrade to keep data safe',
                            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(LucideIcons.chevronRight, size: 16, color: Color(0xFF94A3B8)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Bank Section
            Text(
              'Business Bank Details',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Bank Name',
              hint: 'e.g. Zenith Bank',
              controller: _bankNameController,
              icon: LucideIcons.building2,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Account Number',
              hint: '10 digits',
              controller: _accountNumberController,
              icon: LucideIcons.hash,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Account Name',
              hint: 'John Doe Enterprise',
              controller: _accountNameController,
              icon: LucideIcons.user,
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            // Cloud Sync Section (GATED)
            Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cloud Sync (PostgreSQL)',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4B5563),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: (SubscriptionService.isPro && !_isSyncing) ? _triggerSync : null,
                          icon: _isSyncing 
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(LucideIcons.refreshCcw, size: 14),
                          label: Text(_isSyncing ? 'Syncing...' : 'Sync Now'),
                          style: TextButton.styleFrom(
                            foregroundColor: SubscriptionService.isPro ? const Color(0xFF27ae60) : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'VPS API URL',
                      hint: 'http://your-vps-ip:3000',
                      controller: _vpsUrlController,
                      icon: LucideIcons.globe,
                      keyboardType: TextInputType.url,
                      enabled: SubscriptionService.isPro,
                    ),
                  ],
                ),
                if (!SubscriptionService.isPro)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                         showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const SubscriptionModal(),
                          ).then((_) => setState(() {}));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.lock, color: Colors.white, size: 14),
                                const SizedBox(width: 8),
                                Text(
                                  'Upgrade to Pro to Sync',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27ae60),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      'Save All Settings',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: enabled ? const Color(0xFF6B7280) : Colors.grey[400],
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: enabled ? Colors.black : Colors.grey[400],
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18, color: enabled ? Colors.grey[400] : Colors.grey[200]),
            filled: true,
            fillColor: enabled ? const Color(0xFFF9FAFB) : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF27ae60), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
