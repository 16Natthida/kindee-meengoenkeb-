import 'package:intl/intl.dart';

extension CurrencyFormatting on num {
  /// 1234.5 -> "1,234.50"
  String toBaht({bool withSymbol = false}) {
    final formatter = NumberFormat.currency(
      locale: 'th_TH',
      symbol: withSymbol ? '฿' : '',
      decimalDigits: 2,
    );
    return formatter.format(this).trim();
  }
}

extension ThaiDateFormatting on DateTime {
  static const _thaiMonths = [
    'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
  ];

  String toThaiFull() {
    final buddhistYear = year + 543;
    return '$day ${_thaiMonths[month - 1]} $buddhistYear';
  }

  String toThaiShort() {
    final buddhistYear = (year + 543).toString().substring(2);
    return '$day/${month.toString().padLeft(2, '0')}/$buddhistYear';
  }
}
