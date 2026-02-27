import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/sale.dart';
import '../widgets/add_item_modal.dart';
import '../widgets/sell_modal.dart';

import '../models/user.dart'; // Add this if not present
import '../utils/currency_helper.dart';

class ItemsTab extends StatelessWidget {
  final List<Item> items;
  final Function(Item) onAddItem;
  final Function(Sale) onSell;
  final Function(int, int) onUpdateQuantity;
  final User? user; // Added user

  const ItemsTab({
    super.key,
    required this.items,
    required this.onAddItem,
    required this.onSell,
    required this.onUpdateQuantity,
    this.user, // Added user
  });

  String _formatCurrency(int amount) {
    if (user == null) return '₦${amount.toString()}';
    return CurrencyHelper.format(amount, user!.country);
  }

  void _showAddItemModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddItemModal(onAddItem: onAddItem, user: user),
    );
  }

  void _showSellModal(BuildContext context, Item item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SellModal(
        item: item,
        onSell: onSell,
        onUpdateQuantity: onUpdateQuantity,
        user: user,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Items',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2c3e50),
                ),
              ),
              ElevatedButton(
                onPressed: () => _showAddItemModal(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27ae60),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                child: const Text(
                  '+ Add Item',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: item.category == 'produce'
                            ? const Color(0xFF27ae60)
                            : const Color(0xFFe67e22),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2c3e50),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatCurrency(item.price),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF27ae60),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Show "Service" badge for services, stock count for products
                    if (item.isService)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9b59b6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '🛠️ Service',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9b59b6),
                          ),
                        ),
                      )
                    else
                      Text(
                        '${item.quantity} in stock',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: item.quantity <= 5
                              ? const Color(0xFFe74c3c)
                              : const Color(0xFF2c3e50),
                        ),
                      ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _showSellModal(context, item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFe8f8f0),
                        foregroundColor: const Color(0xFF27ae60),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text(
                        'Sell',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
