import 'package:intl/intl.dart';

String formatPrice(
    num? price, {
      bool withDecimal = false,
      String currency = '৳',
    }) {
  if (price == null) return '-';

  final formatter = NumberFormat.currency(
    locale: 'en_BD',
    symbol: currency,
    decimalDigits: withDecimal ? 2 : 0,
  );

  return formatter.format(price);
}
