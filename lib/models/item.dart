class Item {
  final int id;
  final String name;
  final int price;
  int quantity;
  final String category;
  final bool isService;

  Item({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.category,
    this.isService = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'category': category,
      'isService': isService,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      price: map['price']?.toInt() ?? 0,
      quantity: map['quantity']?.toInt() ?? 0,
      category: map['category'] ?? 'General',
      isService: map['isService'] ?? false,
    );
  }
}
