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

  // Monthly subscription prices centered around 1000 NGN
  static const Map<String, int> _subscriptionPrices = {
    'Nigeria': 1000,
    'Ghana': 40,
    'South Africa': 15,
    'Liberia': 150,
    'Tanzania': 1800,
    'Zambia': 15,
    'Namibia': 15,
  };

  static int getSubscriptionPrice(String country) {
    return _subscriptionPrices[country] ?? 1000;
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
