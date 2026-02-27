import 'package:intl/intl.dart';

class CurrencyHelper {
  static const Map<String, String> _countryCurrencies = {
    'Nigeria': '₦',
    'Ghana': 'GH₵',
    'South Africa': 'R',
    'Liberia': 'L\$',
    'Tanzania': 'TSh',
    'Zambia': 'ZK',
    'Namibia': 'N\$',
  };

  // Annual subscription price - Nigeria only for now
  static const int subscriptionPriceNGN = 5000; // ₦5,000/year

  static int getSubscriptionPrice(String country) {
    // For now, Nigeria only at ₦5,000/year
    return subscriptionPriceNGN;
  }

  static String getCurrencySymbol(String country) {
    return _countryCurrencies[country] ?? '₦'; // Default to Naira
  }

  static String format(int amount, String country) {
    final symbol = getCurrencySymbol(country);
    final formattedAmount = NumberFormat('#,###').format(amount);
    return '$symbol$formattedAmount';
  }
}
