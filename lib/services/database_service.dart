import '../models/user.dart';
import 'database_service_stub.dart'
    if (dart.library.io) 'database_service_mobile.dart'
    if (dart.library.html) 'database_service_web.dart';

abstract class DatabaseService {
  factory DatabaseService() => createDatabaseService();
  Future<User?> login(String koboId, String pin);
  Future<bool> registerUser(User user);
  Future<void> close();

  // Admin Methods
  Future<List<Map<String, dynamic>>> fetchAllUsers({
    String? search,
    String? country,
    String? category,
    String? status,
    String? tier,
    String? role,
  });
  Future<bool> resetUserPin(String koboId, String newPin);
  Future<bool> terminateUser(String koboId);
  Future<Map<String, dynamic>> fetchDetailedAnalytics();
  Future<Map<String, dynamic>> fetchAnalyticsV2();
  Future<Map<String, dynamic>> fetchUserDetails(String koboId);
  Future<List<Map<String, dynamic>>> fetchUserLoginHistory(String koboId);
  Future<bool> updateUserRole(String koboId, String role);
  Future<bool> toggleUserPro(String koboId, bool isPro);
}
