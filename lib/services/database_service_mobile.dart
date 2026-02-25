import 'package:postgres/postgres.dart';
import 'package:flutter/foundation.dart';
import 'database_service.dart';
import '../models/user.dart';

DatabaseService createDatabaseService() => DatabaseServiceMobile();

class DatabaseServiceMobile implements DatabaseService {
  static const String _host = '109.205.181.195';
  static const int _port = 5432;
  static const String _databaseName = 'kobo';
  static const String _username = 'postgres';
  static const String _password = 'LetMeGetaces232823';

  Connection? _connection;

  Future<void> _connect() async {
    if (_connection != null && _connection!.isOpen) return;

    try {
      _connection = await Connection.open(
        Endpoint(
          host: _host,
          port: _port,
          database: _databaseName,
          username: _username,
          password: _password,
        ),
        settings: const ConnectionSettings(
          sslMode: SslMode.disable,
        ),
      );
    } catch (e) {
      debugPrint('Database connection error: $e');
      rethrow;
    }
  }

  @override
  Future<User?> login(String koboId, String pin) async {
    try {
      await _connect();
      
      final result = await _connection!.execute(
        Sql.named('SELECT * FROM users WHERE kobo_id = @koboId AND pin = @pin'),
        parameters: {'koboId': koboId, 'pin': pin},
      );

      if (result.isEmpty) return null;

      final row = result.first;
      final map = row.toColumnMap();

      return User(
        koboId: map['kobo_id'] as String,
        firstName: map['first_name'] as String,
        surname: map['surname'] as String,
        businessName: map['business_name'] as String?,
        pin: map['pin'] as String, 
        country: map['country'] as String,
        businessType: map['business_type'] as String,
        createdAt: map['created_at'] as DateTime,
        role: map['role'] as String? ?? 'user',
      );
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }

  @override
  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }

  @override
  Future<bool> registerUser(User user) async {
    try {
      await _connect();
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      await _connection!.execute(
        Sql.named('''
          INSERT INTO users (id, kobo_id, first_name, surname, business_name, pin, country, business_type, created_at, role)
          VALUES (@id, @koboId, @firstName, @surname, @businessName, @pin, @country, @businessType, @createdAt, @role)
        '''),
        parameters: {
          'id': id,
          'koboId': user.koboId,
          'firstName': user.firstName,
          'surname': user.surname,
          'businessName': user.businessName,
          'pin': user.pin,
          'country': user.country,
          'businessType': user.businessType,
          'createdAt': user.createdAt,
          'role': user.role,
        },
      );
      return true;
    } catch (e) {
      debugPrint('Register User error: $e');
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
      await _connect();
      // For mobile, we just fetch all for now, but signature must match
      final result = await _connection!.execute('SELECT * FROM users ORDER BY created_at DESC');
      return result.map((row) => row.toColumnMap()).toList();
    } catch (e) {
      debugPrint('Mobile Fetch Users error: $e');
      return [];
    }
  }

  @override
  Future<bool> resetUserPin(String koboId, String newPin) async {
    try {
      await _connect();
      await _connection!.execute(
        Sql.named('UPDATE users SET pin = @newPin WHERE kobo_id = @koboId'),
        parameters: {'newPin': newPin, 'koboId': koboId},
      );
      return true;
    } catch (e) {
      debugPrint('Mobile Reset PIN error: $e');
      return false;
    }
  }

  @override
  Future<bool> terminateUser(String koboId) async {
    try {
      await _connect();
      // Need to delete related data first
      final userRes = await _connection!.execute(
        Sql.named('SELECT id FROM users WHERE kobo_id = @koboId'),
        parameters: {'koboId': koboId},
      );
      if (userRes.isEmpty) return false;
      final uuid = userRes.first[0];

      await _connection!.execute(Sql.named('DELETE FROM sales WHERE user_id = @id'), parameters: {'id': uuid});
      await _connection!.execute(Sql.named('DELETE FROM items WHERE user_id = @id'), parameters: {'id': uuid});
      await _connection!.execute(Sql.named('DELETE FROM users WHERE id = @id'), parameters: {'id': uuid});
      
      return true;
    } catch (e) {
      debugPrint('Mobile Terminate User error: $e');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> fetchDetailedAnalytics() async {
    try {
      await _connect();
      
      final statsRes = await _connection!.execute('''
        SELECT 
            (SELECT COUNT(*) FROM users) as total_users,
            (SELECT COALESCE(SUM(total), 0) FROM sales) as total_revenue,
            (SELECT COUNT(*) FROM sales) as total_sales,
            (SELECT COUNT(*) FROM items) as total_items
      ''');
      
      final historyRes = await _connection!.execute('''
        SELECT DATE_TRUNC('day', created_at) as day, SUM(total) as daily_total
        FROM sales
        GROUP BY day
        ORDER BY day DESC
        LIMIT 7
      ''');

      final stats = statsRes.first.toColumnMap();
      
      return {
        'summary': {
          'totalUsers': stats['total_users'],
          'totalRevenue': stats['total_revenue'],
          'totalSales': stats['total_sales'],
          'totalItems': stats['total_items'],
        },
        'salesHistory': historyRes.map((r) => r.toColumnMap()).toList(),
      };
    } catch (e) {
      debugPrint('Mobile Fetch Analytics error: $e');
      return {};
    }
  }

  @override
  Future<Map<String, dynamic>> fetchAnalyticsV2() async {
    return fetchDetailedAnalytics(); // Fallback for mobile
  }

  @override
  Future<List<Map<String, dynamic>>> fetchUserLoginHistory(String koboId) async {
    try {
      await _connect();
      final userRes = await _connection!.execute(
        Sql.named('SELECT id FROM users WHERE kobo_id = @koboId'),
        parameters: {'koboId': koboId},
      );
      if (userRes.isEmpty) return [];
      final uuid = userRes.first[0];

      final historyRes = await _connection!.execute(
        Sql.named('SELECT * FROM login_history WHERE user_id = @id ORDER BY timestamp DESC LIMIT 50'),
        parameters: {'id': uuid},
      );
      return historyRes.map((r) => r.toColumnMap()).toList();
    } catch (e) {
      debugPrint('Mobile Fetch Login History error: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> fetchUserDetails(String koboId) async {
    try {
      await _connect();
      final userRes = await _connection!.execute(
        Sql.named('SELECT id FROM users WHERE kobo_id = @koboId'),
        parameters: {'koboId': koboId},
      );
      if (userRes.isEmpty) return {};
      final uuid = userRes.first[0];

      final itemsRes = await _connection!.execute(
        Sql.named('SELECT * FROM items WHERE user_id = @id'),
        parameters: {'id': uuid},
      );
      final salesRes = await _connection!.execute(
        Sql.named('SELECT * FROM sales WHERE user_id = @id ORDER BY created_at DESC LIMIT 50'),
        parameters: {'id': uuid},
      );

      return {
        'items': itemsRes.map((r) => r.toColumnMap()).toList(),
        'sales': salesRes.map((r) => r.toColumnMap()).toList(),
      };
    } catch (e) {
      debugPrint('Mobile Fetch User Details error: $e');
      return {};
    }
  }

  @override
  Future<bool> updateUserRole(String koboId, String role) async {
    try {
      await _connect();
      await _connection!.execute(
        Sql.named('UPDATE users SET role = @role WHERE kobo_id = @koboId'),
        parameters: {'role': role, 'koboId': koboId},
      );
      return true;
    } catch (e) {
      debugPrint('Mobile Update User Role error: $e');
      return false;
    }
  }

  @override
  Future<bool> toggleUserPro(String koboId, bool isPro) async {
    try {
      await _connect();
      await _connection!.execute(
        Sql.named('UPDATE users SET is_pro = @isPro WHERE kobo_id = @koboId'),
        parameters: {'isPro': isPro, 'koboId': koboId},
      );
      return true;
    } catch (e) {
      debugPrint('Mobile Toggle User Pro error: $e');
      return false;
    }
  }
}
