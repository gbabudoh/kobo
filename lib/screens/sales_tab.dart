import 'package:flutter/material.dart';
import '../models/sale.dart';

import '../models/user.dart'; // Add this
import '../utils/currency_helper.dart';

class SalesTab extends StatelessWidget {
  final List<Sale> sales;
  final User? user; // Added user

  const SalesTab({super.key, required this.sales, this.user});

  String _formatCurrency(int amount) {
    if (user == null) return '₦${amount.toString()}';
    return CurrencyHelper.format(amount, user!.country);
  }

  int get todaySales => sales.fold(0, (sum, sale) => sum + sale.total);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: const Text(
              'Today\'s Sales',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2c3e50),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Total Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const Text(
                  'Total Earned Today',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatCurrency(todaySales),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${sales.length} transactions',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sales List
          ...sales.map((sale) => Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
            padding: const EdgeInsets.all(16),
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
                      'Qty: ${sale.quantity} • ${sale.time}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF95a5a6),
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatCurrency(sale.total),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF27ae60),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
