import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'storage_service.dart';
import 'subscription_service.dart';
import '../models/user_profile.dart';

class ApiService {
  // The user will need to update this URL in the app settings later
  // Defaulting to a placeholder or a common local dev URL
  static String get baseUrl => StorageService.getVpsUrl();

  static Future<bool> isConnected() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult.isNotEmpty && !connectivityResult.contains(ConnectivityResult.none);
  }

  static Future<void> syncProfile(UserProfile profile) async {
    if (!await isConnected()) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sync/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(profile.toMap()),
      );

      if (response.statusCode != 200) {
        debugPrint('Profile sync failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Profile sync error: $e');
    }
  }

  static Future<void> syncAllData() async {
    if (!SubscriptionService.isPro) {
      debugPrint('Sync skipped: User is not on Pro or Trial plan.');
      return;
    }

    if (!await isConnected()) return;

    final profile = StorageService.getUserProfile();
    if (profile == null) return;

    final items = StorageService.getItems();
    final sales = StorageService.getSales();

    try {
      // 1. Sync Profile
      await syncProfile(profile);

      // 2. Sync Items
      await http.post(
        Uri.parse('$baseUrl/sync/items'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': profile.id,
          'items': items.map((i) => i.toMap()).toList(),
        }),
      );

      // 3. Sync Sales
      await http.post(
        Uri.parse('$baseUrl/sync/sales'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': profile.id,
          'sales': sales.map((s) => s.toMap()).toList(),
        }),
      );

      debugPrint('Cloud sync completed successfully');
    } catch (e) {
      debugPrint('Sync error: $e');
    }
  }
}
