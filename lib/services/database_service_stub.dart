import 'database_service.dart';
import '../models/user.dart';

DatabaseService createDatabaseService() => throw UnsupportedError('Cannot create a DatabaseService without dart:html or dart:io');

class DatabaseServiceStub implements DatabaseService {
  @override
  Future<User?> login(String koboId, String pin) => throw UnimplementedError();
  @override
  Future<void> close() => throw UnimplementedError();

  @override
  Future<List<Map<String, dynamic>>> fetchAllUsers({
    String? search,
    String? country,
    String? category,
    String? status,
    String? tier,
    String? role,
  }) => throw UnimplementedError();

  @override
  Future<bool> resetUserPin(String koboId, String newPin) => throw UnimplementedError();
  @override
  Future<bool> terminateUser(String koboId) => throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> fetchDetailedAnalytics() => throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> fetchUserDetails(String koboId) => throw UnimplementedError();

  @override
  Future<bool> updateUserRole(String koboId, String role) => throw UnimplementedError();

  @override
  Future<bool> toggleUserPro(String koboId, bool isPro) => throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> fetchAnalyticsV2() => throw UnimplementedError();

  @override
  Future<List<Map<String, dynamic>>> fetchUserLoginHistory(String koboId) => throw UnimplementedError();

  @override
  Future<bool> registerUser(User user) => throw UnimplementedError();
}
