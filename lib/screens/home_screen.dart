import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/kobo_logo.dart';
import '../widgets/daily_summary_dialog.dart';
import '../widgets/notifications_sheet.dart';
import '../models/item.dart';
import '../models/sale.dart';
import '../models/app_notification.dart';
import 'home_tab.dart';
import 'items_tab.dart';
import 'sales_tab.dart';
import 'bank_tab.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Item> items = [];
  final List<Sale> sales = [];
  final List<AppNotification> notifications = [];

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void initState() {
    super.initState();
    _checkForNewDay();
    _addWelcomeNotification();
  }

  void _addWelcomeNotification() {
    _addNotification(
      type: NotificationType.welcome,
      title: 'Welcome back!',
      message: 'Ready to make sales today? Let\'s go!',
    );
  }

  void _addNotification({
    required NotificationType type,
    required String title,
    required String message,
  }) {
    setState(() {
      notifications.insert(0, AppNotification(
        id: DateTime.now().millisecondsSinceEpoch,
        type: type,
        title: title,
        message: message,
        dateTime: DateTime.now(),
      ));
    });
  }

  void _checkLowStock(Item item) {
    if (!item.isService && item.quantity <= 5 && item.quantity > 0) {
      _addNotification(
        type: NotificationType.lowStock,
        title: 'Low Stock Alert',
        message: '${item.name} has only ${item.quantity} left. Consider restocking.',
      );
    }
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationsSheet(
        notifications: notifications,
        onMarkAllRead: () {
          setState(() {
            for (var n in notifications) {
              n.isRead = true;
            }
          });
          Navigator.pop(context);
        },
        onClearAll: () {
          setState(() {
            notifications.clear();
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _checkForNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final lastOpenedDate = prefs.getString('lastOpenedDate');
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month}-${today.day}';

    if (lastOpenedDate != null && lastOpenedDate != todayString) {
      // It's a new day - show yesterday's summary
      final parts = lastOpenedDate.split('-');
      if (parts.length == 3) {
        final yesterdayDate = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );

        // Get yesterday's sales
        final yesterdaySales = sales.where((sale) {
          return sale.dateTime.year == yesterdayDate.year &&
                 sale.dateTime.month == yesterdayDate.month &&
                 sale.dateTime.day == yesterdayDate.day;
        }).toList();

        // Add daily summary notification
        _addNotification(
          type: NotificationType.dailySummary,
          title: 'Daily Summary Ready',
          message: 'Check your sales summary from yesterday.',
        );

        // Show dialog after build completes
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showDailySummary(yesterdaySales, yesterdayDate);
          });
        }
      }
    }

    // Save today's date
    await prefs.setString('lastOpenedDate', todayString);
  }

  void _showDailySummary(List<Sale> yesterdaySales, DateTime yesterdayDate) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DailySummaryDialog(
        yesterdaySales: yesterdaySales,
        yesterdayDate: yesterdayDate,
      ),
    );
  }

  String _formatCurrency(int amount) {
    return '₦${amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  void addSale(Sale sale) {
    setState(() {
      sales.insert(0, sale);
    });

    // Add sale confirmation notification
    _addNotification(
      type: NotificationType.saleConfirmation,
      title: 'Sale Recorded',
      message: '${sale.itemName} sold for ${_formatCurrency(sale.total)}',
    );

    // Check if item is now low stock
    final item = items.firstWhere((i) => i.id == sale.itemId, orElse: () => items.first);
    _checkLowStock(item);
  }

  void addItem(Item item) {
    setState(() {
      items.add(item);
    });
  }

  void updateItemQuantity(int itemId, int newQuantity) {
    setState(() {
      final item = items.firstWhere((i) => i.id == itemId);
      item.quantity = newQuantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      HomeTab(items: items, sales: sales, onSell: addSale, onUpdateQuantity: updateItemQuantity),
      ItemsTab(items: items, onAddItem: addItem, onSell: addSale, onUpdateQuantity: updateItemQuantity),
      SalesTab(sales: sales),
      BankTab(sales: sales),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a5f2a),
        elevation: 0,
        title: const KoboLogo(
          size: 24,
          color: Colors.white,
        ),
        centerTitle: false,
        actions: [
          // Notification Bell with Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.bell, color: Colors.white),
                onPressed: _showNotifications,
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFe74c3c),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(LucideIcons.user, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF27ae60),
          unselectedItemColor: const Color(0xFF7f8c8d),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.home, size: 22),
              activeIcon: Icon(LucideIcons.home, size: 24),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.package, size: 22),
              activeIcon: Icon(LucideIcons.package, size: 24),
              label: 'Items',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.clipboardList, size: 22),
              activeIcon: Icon(LucideIcons.clipboardList, size: 24),
              label: 'Sales',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.landmark, size: 22),
              activeIcon: Icon(LucideIcons.landmark, size: 24),
              label: 'Bank',
            ),
          ],
        ),
      ),
    );
  }
}
