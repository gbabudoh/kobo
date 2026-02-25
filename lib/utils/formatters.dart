import 'package:intl/intl.dart';

class Formatters {
  static String formatNaira(int amount) {
    final formatter = NumberFormat('#,###', 'en_US');
    return '₦${formatter.format(amount)}';
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }
}
