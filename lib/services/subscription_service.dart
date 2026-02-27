import 'package:flutter/material.dart';
import 'package:flutter_paystack_max/flutter_paystack_max.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'storage_service.dart';
import 'api_service.dart';

class SubscriptionService {
  static const int trialDays = 30;
  
  // ============================================
  // PAYSTACK KEYS - REPLACE WITH YOUR KEYS
  // ============================================
  static const String paystackPublicKey = 'pk_test_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
  static const String paystackSecretKey = 'sk_test_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
  // ============================================

  /// Returns true if the user has an active Pro subscription or is within their trial period.
  static bool get isPro {
    if (StorageService.getIsPro()) return true;

    final profile = StorageService.getUserProfile();
    if (profile == null) return false;

    final registrationDate = profile.createdAt;
    final trialEndDate = registrationDate.add(const Duration(days: trialDays));
    
    return DateTime.now().isBefore(trialEndDate);
  }

  static int get trialDaysRemaining {
    final profile = StorageService.getUserProfile();
    if (profile == null) return 0;

    final registrationDate = profile.createdAt;
    final trialEndDate = registrationDate.add(const Duration(days: trialDays));
    
    final remaining = trialEndDate.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  static String get statusText {
    if (StorageService.getIsPro()) {
      return 'KOBO Pro Active';
    }
    
    final remaining = trialDaysRemaining;
    if (remaining > 0) {
      return 'Trial: $remaining days left';
    }
    
    return 'Trial Expired';
  }

  /// Processes payment via Paystack and activates Pro status
  static Future<bool> processUpgrade(BuildContext context, {
    required String email,
    required double amount,
    required String currency,
  }) async {
    try {
      final request = PaystackTransactionRequest(
        reference: 'KOBO_${DateTime.now().millisecondsSinceEpoch}',
        secretKey: paystackSecretKey,
        email: email,
        amount: (amount * 100).toDouble(), // Paystack expects kobo (amount * 100)
        currency: PaystackCurrency.ngn,
        channel: [
          PaystackPaymentChannel.card, 
          PaystackPaymentChannel.bank,
          PaystackPaymentChannel.ussd,
          PaystackPaymentChannel.bankTransfer,
        ],
      );

      // 1. Initialize the transaction
      final initializedTransaction = await PaymentService.initializeTransaction(request);

      if (!initializedTransaction.status) {
        debugPrint("Initialization Error: ${initializedTransaction.message}");
        return false;
      }

      if (!context.mounted) return false;

      // 2. Show the payment modal
      await PaymentService.showPaymentModal(
        context,
        transaction: initializedTransaction,
        callbackUrl: 'https://kobo.app/payment/callback',
      );

      // 3. Verify status
      final verification = await PaymentService.verifyTransaction(
        paystackSecretKey: paystackSecretKey,
        initializedTransaction.data?.reference ?? request.reference,
      );

      if (verification.status == true) {
        await activatePro();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Payment Error: $e');
      return false;
    }
  }

  /// Activates Pro status and syncs with backend
  static Future<void> activatePro() async {
    final profile = StorageService.getUserProfile();
    if (profile != null) {
      try {
        // Update Backend
        await http.post(
          Uri.parse('${ApiService.baseUrl}/subscription/activate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'koboId': profile.id,
            'plan': 'pro_annual',
            'amount': 5000,
            'currency': 'NGN',
          }),
        );
      } catch (e) {
        debugPrint('Backend activation error: $e');
      }
    }

    // Persist Locally
    await StorageService.setIsPro(true);
  }
}
