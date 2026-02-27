import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/item.dart';
import '../models/sale.dart';
import '../widgets/sell_modal.dart';

class HomeTab extends StatelessWidget {
  final List<Item> items;
  final List<Sale> sales;
  final Function(Sale) onSell;
  final Function(int, int) onUpdateQuantity;

  const HomeTab({
    super.key,
    required this.items,
    required this.sales,
    required this.onSell,
    required this.onUpdateQuantity,
  });

  String _formatNaira(int amount) {
    return '₦${amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  // Only count today's sales
  int get todaySales => sales.where((s) => s.isToday).fold(0, (sum, sale) => sum + sale.total);
  // Only count products (not services) for total items
  int get totalItems => items.where((item) => !item.isService).fold(0, (sum, item) => sum + item.quantity);
  // Only show low stock for products (services don't track stock)
  int get lowStock => items.where((item) => !item.isService && item.quantity <= 5).length;

  // Get today's date formatted
  String get todayDate {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF27ae60), Color(0xFF1a5f2a)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF27ae60).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good day!',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Welcome to KOBBO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Let\'s make sales today 💪',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Stats
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: LucideIcons.trendingUp,
                        iconColor: const Color(0xFF27ae60),
                        label: 'Today\'s Sales',
                        value: _formatNaira(todaySales),
                        subtitle: todayDate,
                        color: const Color(0xFFd5f5e3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: LucideIcons.package,
                        iconColor: const Color(0xFFe67e22),
                        label: 'Total Items',
                        value: totalItems.toString(),
                        subtitle: todayDate,
                        color: const Color(0xFFfdebd0),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: LucideIcons.alertTriangle,
                        iconColor: const Color(0xFFe74c3c),
                        label: 'Low Stock',
                        value: '$lowStock items',
                        subtitle: null,
                        color: const Color(0xFFfadbd8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Quick Sell Section
                const Text(
                  'Quick Sell',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2c3e50)),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: items.length > 4 ? 4 : items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return InkWell(
                      onTap: () => _showSellModal(context, item),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFe8e8e8), width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2c3e50),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    _formatNaira(item.price),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF27ae60),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              // Show "Service" for services, quantity for products
                                item.isService
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF9b59b6).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'Service',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF9b59b6),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        '${item.quantity} left',
                                        style: const TextStyle(fontSize: 10, color: Color(0xFF95a5a6)),
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Recent Sales
                const Text(
                  'Recent Sales',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2c3e50)),
                ),
                const SizedBox(height: 12),
                ...sales.take(3).map((sale) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sale.itemName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2c3e50),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'x${sale.quantity} • ${sale.timeString}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF95a5a6)),
                          ),
                        ],
                      ),
                      Text(
                        _formatNaira(sale.total),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF27ae60),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? subtitle;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: Color(0xFF7f8c8d), fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2c3e50),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 8,
                color: iconColor.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
