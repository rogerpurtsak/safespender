import 'package:intl/intl.dart';

String formatCurrency(
  double value, {
  String currencySymbol = '€',
}) {
  final format = NumberFormat('#,##0.00', 'et_EE');
  return '${format.format(value)} $currencySymbol';
}
