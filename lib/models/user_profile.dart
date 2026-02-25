class UserProfile {
  final String id;
  final String ownerName;
  final String shopName;
  final String phoneNumber;
  final String state;
  final String city;
  final String businessType;
  final String country;
  final String pin;
  final String koboId;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.ownerName,
    required this.shopName,
    required this.phoneNumber,
    required this.state,
    required this.city,
    required this.businessType,
    required this.country,
    required this.pin,
    required this.koboId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerName': ownerName,
      'shopName': shopName,
      'phoneNumber': phoneNumber,
      'state': state,
      'city': city,
      'businessType': businessType,
      'country': country,
      'pin': pin,
      'koboId': koboId,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      ownerName: map['ownerName'] ?? '',
      shopName: map['shopName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      state: map['state'] ?? '',
      city: map['city'] ?? '',
      businessType: map['businessType'] ?? '',
      country: map['country'] ?? '',
      pin: map['pin'] ?? '',
      koboId: map['koboId'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
    );
  }
}
