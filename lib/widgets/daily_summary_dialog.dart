import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/sale.dart';
import '../models/user.dart';
import '../utils/currency_helper.dart';

class DailySummaryDialog extends StatelessWidget {
  final List<Sale> yesterdaySales;
  final DateTime yesterdayDate;
  final User? user;

  const DailySummaryDialog({
    super.key,
    required this.yesterdaySales,
    required this.yesterdayDate,
    this.user,
  });

  String _formatCurrency(int amount) {
    if (user == null) return '₦${amount.toString()}';
    return CurrencyHelper.format(amount, user!.country);
  }

  String get _dateString {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${yesterdayDate.day} ${months[yesterdayDate.month - 1]} ${yesterdayDate.year}';
  }

  int get _totalSales => yesterdaySales.fold(0, (sum, sale) => sum + sale.total);
  int get _totalItems => yesterdaySales.fold(0, (sum, sale) => sum + sale.quantity);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF27ae60).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.calendarCheck,
                size: 32,
                color: Color(0xFF27ae60),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'Yesterday\'s Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _dateString,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF95a5a6),
              ),
            ),
            const SizedBox(height: 24),

            // Stats
            if (yesterdaySales.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFf8f9fa),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(LucideIcons.inbox, size: 32, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'No sales recorded',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  // Total Earned
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF27ae60), Color(0xFF1a5f2a)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Total Earned',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(_totalSales),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFf8f9fa),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(LucideIcons.shoppingBag, size: 20, color: const Color(0xFF3498db)),
                              const SizedBox(height: 8),
                              Text(
                                '${yesterdaySales.length}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2c3e50),
                                ),
                              ),
                              const Text(
                                'Sales',
                                style: TextStyle(fontSize: 11, color: Color(0xFF95a5a6)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFf8f9fa),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(LucideIcons.package, size: 20, color: const Color(0xFFe67e22)),
                              const SizedBox(height: 8),
                              Text(
                                '$_totalItems',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2c3e50),
                                ),
                              ),
                              const Text(
                                'Items Sold',
                                style: TextStyle(fontSize: 11, color: Color(0xFF95a5a6)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27ae60),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Start New Day',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
