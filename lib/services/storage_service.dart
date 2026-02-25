import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/user_profile.dart';

class StorageService {
  static const String _userKey = 'current_user';
  static const String _isOnboardedKey = 'is_onboarded';
  static const String _isProKey = 'is_pro';
  static const String _vpsUrlKey = 'vps_url';
  static const String _bankNameKey = 'bank_name';
  static const String _accountNumberKey = 'account_number';
  static const String _accountNameKey = 'account_name';

  static SharedPreferences? _prefs;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized && _prefs != null) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // Ensure prefs is initialized before use
  static Future<SharedPreferences> _getPrefs() async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  static Future<void> saveUser(User user) async {
    await _prefs?.setString(_userKey, jsonEncode(user.toJson()));
    await _prefs?.setBool(_isOnboardedKey, true);
  }

  static Future<void> saveProfile(UserProfile profile) async {
    final user = User(
      koboId: profile.koboId,
      country: profile.country,
      firstName: profile.ownerName.split(' ').first,
      surname: profile.ownerName.split(' ').length > 1 ? profile.ownerName.split(' ').last : '',
      businessName: profile.shopName,
      pin: profile.pin,
      businessType: profile.businessType,
      createdAt: profile.createdAt,
    );
    await saveUser(user);
  }

  static Future<User?> getUser() async {
    final userJson = _prefs?.getString(_userKey);
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }

  // Synchronous version for simple getters
  static User? getUserSync() {
    try {
      final userJson = _prefs?.getString(_userKey);
      if (userJson == null) return null;
      return User.fromJson(jsonDecode(userJson));
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  static UserProfile? getUserProfile() {
    final user = getUserSync();
    if (user == null) return null;
    return UserProfile(
      id: user.koboId,
      ownerName: '${user.firstName} ${user.surname}',
      shopName: user.businessName ?? 'My Shop',
      phoneNumber: '',
      state: '',
      city: '',
      businessType: user.businessType,
      country: user.country,
      pin: user.pin,
      koboId: user.koboId,
      createdAt: user.createdAt,
    );
  }

  static bool getIsPro() => _prefs?.getBool(_isProKey) ?? false;
  static Future<void> setIsPro(bool value) async => await _prefs?.setBool(_isProKey, value);

  static String getVpsUrl() => _prefs?.getString(_vpsUrlKey) ?? 'http://109.205.181.195:3000';
  static Future<void> setVpsUrl(String url) async => await _prefs?.setString(_vpsUrlKey, url);

  static Map<String, String>? getBankDetails() {
    final bankName = _prefs?.getString(_bankNameKey);
    final accountNumber = _prefs?.getString(_accountNumberKey);
    final accountName = _prefs?.getString(_accountNameKey);
    
    if (bankName == null && accountNumber == null && accountName == null) return null;
    
    return {
      'bankName': bankName ?? '',
      'accountNumber': accountNumber ?? '',
      'accountName': accountName ?? '',
    };
  }

  static Future<void> saveBankDetails({
    required String bankName,
    required String accountNumber,
    required String accountName,
  }) async {
    await _prefs?.setString(_bankNameKey, bankName);
    await _prefs?.setString(_accountNumberKey, accountNumber);
    await _prefs?.setString(_accountNameKey, accountName);
  }

  // Legacy support for direct box access if needed (simulated)
  static BoxSettings get settingsBox => BoxSettings();

  // Placeholders for sync services
  static List<dynamic> getItems() => [];
  static List<dynamic> getSales() => [];

  static Future<bool> isOnboarded() async {
    return _prefs?.getBool(_isOnboardedKey) ?? false;
  }

  static Future<void> clearUser() async {
    await _prefs?.remove(_userKey);
    await _prefs?.setBool(_isOnboardedKey, false);
  }

  static String generateKoboId() {
    final random = DateTime.now().millisecondsSinceEpoch % 10000;
    return 'KOBO-${random.toString().padLeft(4, '0')}';
  }
}

class BoxSettings {
  dynamic get(String key, {dynamic defaultValue}) {
    if (key == 'vps_url') return StorageService.getVpsUrl();
    if (key == 'is_pro') return StorageService.getIsPro();
    return defaultValue;
  }

  Future<void> put(String key, dynamic value) async {
    if (key == 'vps_url') await StorageService.setVpsUrl(value.toString());
    if (key == 'is_pro') await StorageService.setIsPro(value == true);
  }
}
