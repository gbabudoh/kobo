import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/sale.dart';
import '../models/user.dart';
import '../utils/currency_helper.dart';

class BankTab extends StatelessWidget {
  final List<Sale> sales;
  final User? user;

  const BankTab({super.key, required this.sales, this.user});

  String _formatCurrency(int amount) {
    if (user == null) return '₦${amount.toString()}';
    return CurrencyHelper.format(amount, user!.country);
  }

  // Group sales by date
  Map<String, List<Sale>> get salesByDate {
    final Map<String, List<Sale>> grouped = {};
    for (final sale in sales) {
      final dateKey = sale.dateString;
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(sale);
    }
    return grouped;
  }

  // Get total for a list of sales
  int _getDayTotal(List<Sale> daySales) {
    return daySales.fold(0, (sum, sale) => sum + sale.total);
  }

  // Get all-time total
  int get allTimeTotal => sales.fold(0, (sum, sale) => sum + sale.total);

  @override
  Widget build(BuildContext context) {
    final groupedSales = salesByDate;
    final sortedDates = groupedSales.keys.toList();

    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              'Sales History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2c3e50),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // All-time Total Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2c3e50), Color(0xFF1a252f)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2c3e50).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(LucideIcons.landmark, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Total Earnings',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _formatCurrency(allTimeTotal),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${sales.length} total transactions • ${sortedDates.length} days',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Daily Breakdown
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              'Daily Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2c3e50),
              ),
            ),
          ),

          if (sortedDates.isEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFf8f9fa),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(LucideIcons.inbox, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'No sales recorded yet',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Start selling to see your history here',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          else
            ...sortedDates.map((date) {
              final daySales = groupedSales[date]!;
              final dayTotal = _getDayTotal(daySales);
              final isToday = daySales.first.isToday;

              return Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: isToday ? Border.all(color: const Color(0xFF27ae60), width: 2) : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isToday 
                            ? const Color(0xFF27ae60).withOpacity(0.1)
                            : const Color(0xFFf5f6fa),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        LucideIcons.calendar,
                        size: 20,
                        color: isToday ? const Color(0xFF27ae60) : const Color(0xFF7f8c8d),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2c3e50),
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF27ae60),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Today',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      '${daySales.length} sales',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF95a5a6)),
                    ),
                    trailing: Text(
                      _formatCurrency(dayTotal),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF27ae60),
                      ),
                    ),
                    children: daySales.map((sale) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf8f9fa),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sale.itemName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2c3e50),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Qty: ${sale.quantity} • ${sale.timeString}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF95a5a6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatCurrency(sale.total),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF27ae60),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              );
            }),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
