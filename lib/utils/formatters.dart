import 'package:intl/intl.dart';

String formatCurrency(double amount) {
  final formatter = NumberFormat.currency(
    locale: 'it_IT',
    symbol: '€ ',
    decimalDigits: 2,
  );
  return formatter.format(amount);
}