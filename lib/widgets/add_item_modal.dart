import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/user.dart';
import '../utils/currency_helper.dart';

class AddItemModal extends StatefulWidget {
  final Function(Item) onAddItem;
  final User? user;

  const AddItemModal({super.key, required this.onAddItem, this.user});

  @override
  State<AddItemModal> createState() => _AddItemModalState();
}

class _AddItemModalState extends State<AddItemModal> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  String _category = 'provisions';
  bool _isService = false;

  // Determine default based on business type
  @override
  void initState() {
    super.initState();
    _setDefaultsFromBusinessType();
  }

  void _setDefaultsFromBusinessType() {
    final businessType = widget.user?.businessType?.toLowerCase() ?? '';
    
    // Service-based businesses default to service mode
    if (businessType.contains('salon') ||
        businessType.contains('barber') ||
        businessType.contains('makeup') ||
        businessType.contains('beauty') ||
        businessType.contains('spa') ||
        businessType.contains('tailor') ||
        businessType.contains('fashion design') ||
        businessType.contains('mechanic') ||
        businessType.contains('electrician') ||
        businessType.contains('plumber') ||
        businessType.contains('technical') ||
        businessType.contains('delivery') ||
        businessType.contains('photography') ||
        businessType.contains('event') ||
        businessType.contains('cleaning') ||
        businessType.contains('laundry')) {
      setState(() {
        _isService = true;
        _category = 'salon_barber';
      });
    }
    // Food businesses - mixed (can have both)
    else if (businessType.contains('restaurant') ||
             businessType.contains('food') ||
             businessType.contains('canteen') ||
             businessType.contains('buka') ||
             businessType.contains('chop')) {
      setState(() {
        _isService = true; // Food items typically don't track stock
        _category = 'cooked_food';
      });
    }
  }

  final Map<String, List<Map<String, String>>> _categories = {
    '📦 Physical Goods': [
      {'id': 'provisions', 'name': 'Provisions', 'desc': 'Dry groceries, tinned goods, sachets', 'icon': '🥫'},
      {'id': 'market_fresh', 'name': 'Market Fresh', 'desc': 'Vegetables, fruits, tubers, peppers', 'icon': '🥬'},
      {'id': 'meat_fish', 'name': 'Meat & Fish', 'desc': 'Butchery, poultry, dried/fresh fish', 'icon': '🥩'},
      {'id': 'drinks', 'name': 'Drinks', 'desc': 'Water, minerals, local brews, juices', 'icon': '🥤'},
      {'id': 'boutique_fabric', 'name': 'Boutique & Fabric', 'desc': 'Ready-made clothes, Ankara/Kente', 'icon': '👗'},
      {'id': 'gadgets', 'name': 'Gadgets', 'desc': 'Phone accessories, chargers', 'icon': '🔌'},
      {'id': 'home_care', 'name': 'Home Care', 'desc': 'Cleaning supplies, buckets', 'icon': '🧼'},
      {'id': 'beauty_products', 'name': 'Beauty Products', 'desc': 'Hair extensions, creams, soaps', 'icon': '💄'},
    ],
    '🛠️ Services': [
      {'id': 'cooked_food', 'name': 'Cooked Food', 'desc': 'Bukas, Chop bars, Kibandas', 'icon': '🍳'},
      {'id': 'fashion_design', 'name': 'Fashion Design', 'desc': 'Bespoke tailoring, mending', 'icon': '✂️'},
      {'id': 'salon_barber', 'name': 'Salon & Barber', 'desc': 'Braiding, styling, grooming', 'icon': '💇'},
      {'id': 'technical_work', 'name': 'Technical Work', 'desc': 'Mechanic, wiring, plumbing', 'icon': '🔧'},
      {'id': 'delivery', 'name': 'Delivery', 'desc': 'Boda-Boda, Okada, small-scale haulage', 'icon': '🚚'},
      {'id': 'artisan_crafts', 'name': 'Artisan Crafts', 'desc': 'Beadwork, pottery, carpentry', 'icon': '🎨'},
      {'id': 'cash_transfer', 'name': 'Cash & Transfer', 'desc': 'Mobile Money, POS, agent banking', 'icon': '💸'},
      {'id': 'other_service', 'name': 'Other Service', 'desc': 'Specialty micro-services', 'icon': '📦'},
    ],
  };

  String _getCategoryLabel(String id) {
    for (var group in _categories.values) {
      for (var item in group) {
        if (item['id'] == id) {
          return '${item['icon']} ${item['name']}';
        }
      }
    }
    return id;
  }

  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text(
                    'Select Category',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _categories.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF95a5a6),
                          ),
                        ),
                      ),
                      ...entry.value.map((item) => ListTile(
                        onTap: () {
                          setState(() => _category = item['id']!);
                          Navigator.pop(context);
                        },
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFf5f6fa),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(item['icon']!, style: const TextStyle(fontSize: 20)),
                        ),
                        title: Text(
                          item['name']!,
                          style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2c3e50)),
                        ),
                        subtitle: Text(
                          item['desc']!,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF7f8c8d)),
                        ),
                        trailing: _category == item['id']
                            ? const Icon(Icons.check_circle, color: Color(0xFF27ae60))
                            : null,
                      )),
                      const Divider(),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAddItem() {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill name and price')),
      );
      return;
    }

    // For services, quantity is not required (defaults to unlimited/999999)
    final quantity = _isService 
        ? 999999 
        : int.tryParse(_quantityController.text) ?? 0;

    if (!_isService && quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    final item = Item(
      id: DateTime.now().millisecondsSinceEpoch,
      name: _nameController.text,
      price: int.parse(_priceController.text),
      quantity: quantity,
      category: _category,
      isService: _isService,
    );

    widget.onAddItem(item);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Add New Item',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2c3e50),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Service/Product Toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFf5f6fa),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isService = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isService ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: !_isService ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ] : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 18,
                              color: !_isService ? const Color(0xFF27ae60) : const Color(0xFF95a5a6),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Product',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: !_isService ? const Color(0xFF27ae60) : const Color(0xFF95a5a6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isService = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isService ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _isService ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ] : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.handyman_outlined,
                              size: 18,
                              color: _isService ? const Color(0xFF27ae60) : const Color(0xFF95a5a6),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Service',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _isService ? const Color(0xFF27ae60) : const Color(0xFF95a5a6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            Center(
              child: Text(
                _isService 
                    ? 'Services don\'t track stock (e.g., haircut, repair)'
                    : 'Products track inventory quantity',
                style: const TextStyle(fontSize: 11, color: Color(0xFF95a5a6)),
              ),
            ),
            const SizedBox(height: 16),

            // Item Name
            Text(
              _isService ? 'Service Name' : 'Item Name',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7f8c8d),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: _isService ? 'e.g. Braiding, Oil Change' : 'e.g. Rice (bag)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFe8e8e8), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFe8e8e8), width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF27ae60), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),

            // Price
            Text(
              'Price (${CurrencyHelper.getCurrencySymbol(widget.user?.country ?? 'Nigeria')})',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7f8c8d),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 5000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFe8e8e8), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFe8e8e8), width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF27ae60), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),

            // Quantity (only for products)
            if (!_isService) ...[
              const Text(
                'Quantity in Stock',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7f8c8d),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 10',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFe8e8e8), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFe8e8e8), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF27ae60), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Category
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7f8c8d),
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () => _showCategoryPicker(context),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFe8e8e8), width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _getCategoryLabel(_category),
                        style: const TextStyle(fontSize: 16, color: Color(0xFF2c3e50)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Color(0xFF7f8c8d)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFe8e8e8), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7f8c8d),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleAddItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27ae60),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      _isService ? 'Add Service +' : 'Add Item +',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}
