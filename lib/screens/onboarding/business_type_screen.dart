import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'intro_screen.dart';

class BusinessTypeScreen extends StatefulWidget {
  final String country;
  final String firstName;
  final String surname;
  final String? businessName;
  final String pin;

  const BusinessTypeScreen({
    super.key,
    required this.country,
    required this.firstName,
    required this.surname,
    this.businessName,
    required this.pin,
  });

  @override
  State<BusinessTypeScreen> createState() => _BusinessTypeScreenState();
}

class _BusinessTypeScreenState extends State<BusinessTypeScreen> {
  String? _selectedPrimary;
  String? _selectedSub;

  void _cancelRegistration() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Registration?'),
        content: const Text('Are you sure you want to cancel? You can register later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const IntroScreen()),
                (route) => false,
              );
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  final Map<String, Map<String, dynamic>> _categories = {
    'Food & Beverage': {
      'emoji': '🍲',
      'subs': ['Street Food (Rolex, Suya, Kelewele)', 'Restaurant/Canteen', 'Bakery', 'Fresh Produce', 'Grocery/Provisions']
    },
    'Fashion & Apparel': {
      'emoji': '✂️',
      'subs': ['Tailoring (Bespoke)', 'Ready-to-Wear', 'Footwear (Cobbler)', 'Jewelry & Accessories', 'Textile/Fabric Sales']
    },
    'Beauty & Wellness': {
      'emoji': '💇',
      'subs': ['Hair Salon', 'Barber Shop', 'Makeup Artist', 'Spa & Skincare', 'Gym/Personal Trainer']
    },
    'Technical & Trades': {
      'emoji': '🔧',
      'subs': ['Mechanic', 'Electrician', 'Plumber', 'Carpenter', 'Welder', 'Painter/Mason']
    },
    'Digital & Tech': {
      'emoji': '📱',
      'subs': ['Phone/Laptop Repair', 'Mobile Money Agent', 'Cyber Cafe/Printing', 'Software/Web Services']
    },
    'Retail & General': {
      'emoji': '🏪',
      'subs': ['Boutique', 'Electronics/Appliances', 'Stationery/Books', 'Hardware/Tools', 'General Provisions']
    },
    'Logistics & Transport': {
      'emoji': '🚚',
      'subs': ['Delivery Rider', 'Taxi/Private Hire', 'Moving Services', 'Warehouse/Storage']
    },
    'Creative & Events': {
      'emoji': '🎨',
      'subs': ['Photography/Video', 'Event Planning/Decor', 'Graphic Design', 'Music/DJ', 'Art & Crafts']
    },
    'Home & Professional': {
      'emoji': '🧼',
      'subs': ['Laundry/Dry Cleaning', 'Cleaning Services', 'Gardening/Landscaping', 'Security Services']
    },
    'Other': {
      'emoji': '📦',
      'subs': ['General']
    },
  };

  void _handleCreateAccount() {
    if (_selectedPrimary == null || _selectedSub == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both a primary and sub-category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final fullType = '$_selectedPrimary > $_selectedSub';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WelcomeScreen(
          country: widget.country,
          firstName: widget.firstName,
          surname: widget.surname,
          businessName: widget.businessName,
          pin: widget.pin,
          businessType: fullType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfaf8f5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2c3e50)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF7f8c8d)),
            onPressed: _cancelRegistration,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedPrimary == null ? 'What do you do?' : 'Tell us more',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2c3e50),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedPrimary == null 
                  ? 'Select your business category' 
                  : 'What specific type of $_selectedPrimary?',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7f8c8d),
                ),
              ),
              const SizedBox(height: 32),

              Expanded(
                child: _selectedPrimary == null 
                  ? _buildPrimaryGrid() 
                  : _buildSubList(),
              ),

              const SizedBox(height: 24),

              if (_selectedPrimary != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextButton(
                    onPressed: () => setState(() {
                      _selectedPrimary = null;
                      _selectedSub = null;
                    }),
                    child: const Text('← Go back to main categories', style: TextStyle(color: Color(0xFF27ae60))),
                  ),
                ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleCreateAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27ae60),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _selectedPrimary == null ? 'Select a Category' : 'Create Account',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final categoryName = _categories.keys.elementAt(index);
        final categoryData = _categories[categoryName]!;
        
        return InkWell(
          onTap: () => setState(() => _selectedPrimary = categoryName),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFe8e8e8), width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(categoryData['emoji']!, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    categoryName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2c3e50)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubList() {
    final subs = _categories[_selectedPrimary]!['subs'] as List<String>;
    return ListView.separated(
      itemCount: subs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final sub = subs[index];
        final isSelected = _selectedSub == sub;
        return InkWell(
          onTap: () => setState(() => _selectedSub = sub),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF27ae60).withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF27ae60) : const Color(0xFFe8e8e8),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    sub,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? const Color(0xFF27ae60) : const Color(0xFF2c3e50),
                    ),
                  ),
                ),
                if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF27ae60)),
              ],
            ),
          ),
        );
      },
    );
  }
}
