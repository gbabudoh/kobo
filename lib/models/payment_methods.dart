class PaymentMethods {
  final String? paystackEmail;
  final String? opayNumber;
  final String? bankName;
  final String? accountNumber;
  final String? accountName;

  PaymentMethods({
    this.paystackEmail,
    this.opayNumber,
    this.bankName,
    this.accountNumber,
    this.accountName,
  });

  bool get hasPaystack => paystackEmail != null && paystackEmail!.isNotEmpty;
  bool get hasOpay => opayNumber != null && opayNumber!.isNotEmpty;
  bool get hasBank => bankName != null && accountNumber != null && accountName != null &&
                      bankName!.isNotEmpty && accountNumber!.isNotEmpty && accountName!.isNotEmpty;
  bool get hasAnyMethod => hasPaystack || hasOpay || hasBank;

  Map<String, dynamic> toJson() => {
    'paystackEmail': paystackEmail,
    'opayNumber': opayNumber,
    'bankName': bankName,
    'accountNumber': accountNumber,
    'accountName': accountName,
  };

  factory PaymentMethods.fromJson(Map<String, dynamic> json) => PaymentMethods(
    paystackEmail: json['paystackEmail'],
    opayNumber: json['opayNumber'],
    bankName: json['bankName'],
    accountNumber: json['accountNumber'],
    accountName: json['accountName'],
  );

  PaymentMethods copyWith({
    String? paystackEmail,
    String? opayNumber,
    String? bankName,
    String? accountNumber,
    String? accountName,
  }) => PaymentMethods(
    paystackEmail: paystackEmail ?? this.paystackEmail,
    opayNumber: opayNumber ?? this.opayNumber,
    bankName: bankName ?? this.bankName,
    accountNumber: accountNumber ?? this.accountNumber,
    accountName: accountName ?? this.accountName,
  );
}
