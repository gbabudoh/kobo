class User {
  final String koboId;
  final String country;
  final String firstName;
  final String surname;
  final String? businessName;
  final String pin;
  final String businessType;
  final DateTime createdAt;
  final String role;
  final bool isPro;
  final String accountStatus;
  final DateTime? lastLogin;
  final Map<String, dynamic>? deviceInfo;
  final String? adminNotes;

  User({
    required this.koboId,
    required this.country,
    required this.firstName,
    required this.surname,
    this.businessName,
    required this.pin,
    required this.businessType,
    required this.createdAt,
    this.role = 'user',
    this.isPro = false,
    this.accountStatus = 'active',
    this.lastLogin,
    this.deviceInfo,
    this.adminNotes,
  });

  String get subscriptionStatus => isPro ? 'pro' : 'free';

  Map<String, dynamic> toJson() => {
    'koboId': koboId,
    'country': country,
    'firstName': firstName,
    'surname': surname,
    'businessName': businessName,
    'pin': pin,
    'businessType': businessType,
    'createdAt': createdAt.toIso8601String(),
    'role': role,
    'isPro': isPro,
    'accountStatus': accountStatus,
    'lastLogin': lastLogin?.toIso8601String(),
    'deviceInfo': deviceInfo,
    'adminNotes': adminNotes,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    koboId: json['koboId'],
    country: json['country'],
    firstName: json['firstName'],
    surname: json['surname'],
    businessName: json['businessName'],
    pin: json['pin'],
    businessType: json['businessType'],
    createdAt: DateTime.parse(json['createdAt']),
    role: json['role'] ?? 'user',
    isPro: json['isPro'] ?? false,
    accountStatus: json['accountStatus'] ?? 'active',
    lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
    deviceInfo: json['deviceInfo'],
    adminNotes: json['adminNotes'],
  );
}
