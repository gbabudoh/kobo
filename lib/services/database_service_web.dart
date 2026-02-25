import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'database_service.dart';
import '../models/user.dart';

DatabaseService createDatabaseService() => DatabaseServiceWeb();

class DatabaseServiceWeb implements DatabaseService {
  @override
  Future<User?> login(String koboId, String pin) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.egobas.com/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'koboId': koboId, 'pin': pin}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final map = data['user'];
        
        return User(
          koboId: map['kobo_id'],
          firstName: map['first_name'] ?? '',
          surname: map['surname'] ?? '',
          businessName: map['business_name'],
          pin: map['pin'],
          country: map['country'] ?? 'Nigeria',
          businessType: map['business_type'] ?? 'Retail',
          createdAt: DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now(),
          role: map['role'] ?? 'user',
        );
      }
      return null;
    } catch (e) {
      debugPrint('Web Login error: $e');
      return null;
    }
  }

  @override
  Future<bool> registerUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.egobas.com/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'koboId': user.koboId,
          'firstName': user.firstName,
          'surname': user.surname,
          'businessName': user.businessName,
          'pin': user.pin,
          'country': user.country,
          'businessType': user.businessType,
          'createdAt': user.createdAt.toIso8601String(),
          'role': user.role,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Web Register error: $e');
      return false;
    }
  }

  @override
  Future<void> close() async {
    // No connection to close for HTTP
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAllUsers({
    String? search,
    String? country,
    String? category,
    String? status,
    String? tier,
    String? role,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (search != null) queryParams['search'] = search;
      if (country != null) queryParams['country'] = country;
      if (category != null) queryParams['category'] = category;
      if (status != null) queryParams['status'] = status;
      if (tier != null) queryParams['tier'] = tier;
      if (role != null) queryParams['role'] = role;

      final uri = Uri.parse('https://api.egobas.com/admin/users').replace(queryParameters: queryParams);
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('Web Fetch Users error: $e');
      return [];
    }
  }

  @override
  Future<bool> resetUserPin(String koboId, String newPin) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.egobas.com/admin/users/reset-pin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'koboId': koboId, 'newPin': newPin}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Web Reset PIN error: $e');
      return false;
    }
  }

  @override
  Future<bool> terminateUser(String koboId) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.egobas.com/admin/users/terminate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'koboId': koboId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Web Terminate User error: $e');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> fetchDetailedAnalytics() async {
    final response = await http.get(Uri.parse('https://api.egobas.com/admin/analytics'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> fetchAnalyticsV2() async {
    try {
      final response = await http.get(Uri.parse('https://api.egobas.com/admin/analytics/v2'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      debugPrint('Web Fetch Analytics V2 error: $e');
      return {};
    }
  }

  @override
  Future<Map<String, dynamic>> fetchUserDetails(String koboId) async {
    final response = await http.get(Uri.parse('https://api.egobas.com/admin/users/$koboId/details'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return {};
  }

  @override
  Future<List<Map<String, dynamic>>> fetchUserLoginHistory(String koboId) async {
    try {
      final response = await http.get(Uri.parse('https://api.egobas.com/admin/users/$koboId/login-history'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('Web Fetch Login History error: $e');
      return [];
    }
  }

  @override
  Future<bool> updateUserRole(String koboId, String role) async {
    final response = await http.post(
      Uri.parse('https://api.egobas.com/admin/users/update-role'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'koboId': koboId, 'role': role}),
    );
    return response.statusCode == 200;
  }

  @override
  Future<bool> toggleUserPro(String koboId, bool isPro) async {
    final response = await http.post(
      Uri.parse('https://api.egobas.com/admin/users/toggle-pro'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'koboId': koboId, 'isPro': isPro}),
    );
    return response.statusCode == 200;
  }
}
