import 'package:intl/intl.dart';

//fungsi untuk konversi angka menjadi rupiah
class NumberHelper {
  static String convertToIdrWithSymbol(
      {required dynamic count, required int decimalDigit}) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: decimalDigit,
    );
    return currencyFormatter.format(count);
  }

  static String convertToIdrWithoutSymbol(
      {required dynamic count, required int decimalDigit}) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: '',
      decimalDigits: decimalDigit,
    );
    return currencyFormatter.format(count);
  }
}
