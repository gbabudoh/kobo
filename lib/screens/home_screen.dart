import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/kobo_logo.dart';
import '../models/item.dart';
import '../models/sale.dart';
import 'home_tab.dart';
import 'items_tab.dart';
import 'sales_tab.dart';
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

  void addSale(Sale sale) {
    setState(() {
      sales.insert(0, sale);
    });
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
          IconButton(
            icon: const Icon(LucideIcons.bell, color: Colors.white),
            onPressed: () {},
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
          selectedFontSize: 12,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Text('🏠', style: TextStyle(fontSize: 22)), label: 'Home'),
            BottomNavigationBarItem(icon: Text('📦', style: TextStyle(fontSize: 22)), label: 'Items'),
            BottomNavigationBarItem(icon: Text('📊', style: TextStyle(fontSize: 22)), label: 'Sales'),
          ],
        ),
      ),
    );
  }
}
