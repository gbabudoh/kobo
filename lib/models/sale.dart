class Sale {
  final int id;
  final int itemId;
  final String itemName;
  final int quantity;
  final int total;
  final DateTime dateTime; // Full date and time

  Sale({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.total,
    required this.dateTime,
  });

  // Helper to get formatted time string
  String get timeString {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$hour12:$minute $period';
  }

  // Helper to get formatted date string
  String get dateString {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  // Check if sale is from today
  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year && 
           dateTime.month == now.month && 
           dateTime.day == now.day;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'total': total,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id']?.toInt() ?? 0,
      itemId: map['itemId']?.toInt() ?? 0,
      itemName: map['itemName'] ?? '',
      quantity: map['quantity']?.toInt() ?? 0,
      total: map['total']?.toInt() ?? 0,
      dateTime: DateTime.parse(map['dateTime']),
    );
  }
}
