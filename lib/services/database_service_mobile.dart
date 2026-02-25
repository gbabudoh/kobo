import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'database_service.dart';
import '../models/user.dart';

DatabaseService createDatabaseService() => DatabaseServiceMobile();

class DatabaseServiceMobile implements DatabaseService {
  static const String _baseUrl = 'https://api.egobas.com';

  @override
  Future<User?> login(String koboId, String pin) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'koboId': koboId, 'pin': pin}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final u = data['user'];
          return User(
            koboId: u['kobo_id'] ?? '',
            firstName: u['first_name'] ?? '',
            surname: u['surname'] ?? '',
            businessName: u['business_name'],
            pin: pin,
            country: u['country'] ?? '',
            businessType: u['business_type'] ?? '',
            createdAt: DateTime.parse(u['created_at']),
            role: u['role'] ?? 'user',
          );
        }
      }
      return null;
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }

  @override
  Future<void> close() async {}

  @override
  Future<bool> registerUser(User user) async {
    try {
      debugPrint('Registering user: ${user.koboId} to $_baseUrl/auth/register');
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
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
          'role': user.role ?? 'user',
        }),
      );
      debugPrint('Register response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Register error: $e');
      return false;
    }
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
      final params = <String, String>{};
      if (search != null) params['search'] = search;
      if (country != null) params['country'] = country;
      if (category != null) params['category'] = category;
      if (status != null) params['status'] = status;
      if (tier != null) params['tier'] = tier;
      if (role != null) params['role'] = role;
      final uri = Uri.parse('$_baseUrl/admin/users').replace(queryParameters: params.isNotEmpty ? params : null);
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('Fetch Users error: $e');
      return [];
    }
  }

  @override
  Future<bool> resetUserPin(String koboId, String newPin) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/users/reset-pin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'koboId': koboId, 'newPin': newPin}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Reset PIN error: $e');
      return false;
    }
  }

  @override
  Future<bool> terminateUser(String koboId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/users/terminate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'koboId': koboId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Terminate User error: $e');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> fetchDetailedAnalytics() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/admin/analytics'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      debugPrint('Fetch Analytics error: $e');
      return {};
    }
  }

  @override
  Future<Map<String, dynamic>> fetchAnalyticsV2() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/admin/analytics/v2'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      debugPrint('Fetch Analytics V2 error: $e');
      return {};
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchUserLoginHistory(String koboId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/admin/users/$koboId/login-history'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('Fetch Login History error: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> fetchUserDetails(String koboId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/admin/users/$koboId/details'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      debugPrint('Fetch User Details error: $e');
      return {};
    }
  }

  @override
  Future<bool> updateUserRole(String koboId, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/users/update-role'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'koboId': koboId, 'role': role}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update Role error: $e');
      return false;
    }
  }

  @override
  Future<bool> toggleUserPro(String koboId, bool isPro) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/users/toggle-pro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'koboId': koboId, 'isPro': isPro}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Toggle Pro error: $e');
      return false;
    }
  }
}
