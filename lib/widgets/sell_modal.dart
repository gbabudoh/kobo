import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/sale.dart';
import '../models/user.dart';
import '../utils/currency_helper.dart';

class SellModal extends StatefulWidget {
  final Item item;
  final Function(Sale) onSell;
  final Function(int, int) onUpdateQuantity;
  final User? user; // Added user

  const SellModal({
    super.key,
    required this.item,
    required this.onSell,
    required this.onUpdateQuantity,
    this.user, // Added user
  });

  @override
  State<SellModal> createState() => _SellModalState();
}

class _SellModalState extends State<SellModal> {
  int quantity = 1;
  bool _isSubmitting = false; // Prevent double-tap

  String _formatCurrency(int amount) {
    if (widget.user == null) return '₦${amount.toString()}';
    return CurrencyHelper.format(amount, widget.user!.country);
  }

  void _handleSell() {
    // Prevent double-tap
    if (_isSubmitting) return;
    
    // For services, no quantity limit check (unlimited)
    if (!widget.item.isService && (quantity < 1 || quantity > widget.item.quantity)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid quantity!')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final sale = Sale(
      id: DateTime.now().millisecondsSinceEpoch,
      itemId: widget.item.id,
      itemName: widget.item.name,
      quantity: quantity,
      total: widget.item.price * quantity,
      dateTime: DateTime.now(),
    );

    widget.onSell(sale);
    // Only decrement quantity for products, not services
    if (!widget.item.isService) {
      widget.onUpdateQuantity(widget.item.id, widget.item.quantity - quantity);
    }
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Record Sale',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 20),

          // Item Info
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFf8f9fa),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2c3e50),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.item.isService) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9b59b6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Service',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9b59b6),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatCurrency(widget.item.price)} each',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF27ae60),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.item.isService ? 'Unlimited availability' : '${widget.item.quantity} available',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF95a5a6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quantity Control
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (quantity > 1) {
                    setState(() => quantity--);
                  }
                },
                icon: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF27ae60), width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      '−',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF27ae60),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Text(
                quantity.toString(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2c3e50),
                ),
              ),
              const SizedBox(width: 20),
              IconButton(
                onPressed: () {
                  // For services, no upper limit; for products, limit to available quantity
                  if (widget.item.isService || quantity < widget.item.quantity) {
                    setState(() => quantity++);
                  }
                },
                icon: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF27ae60), width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      '+',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF27ae60),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Total
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFe8f8f0),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                Text(
                  _formatCurrency(widget.item.price * quantity),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF27ae60),
                  ),
                ),
              ],
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
                  onPressed: _isSubmitting ? null : _handleSell,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27ae60),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    disabledBackgroundColor: const Color(0xFF27ae60).withOpacity(0.5),
                  ),
                  child: Text(
                    _isSubmitting ? 'Recording...' : 'Confirm Sale ✓',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
