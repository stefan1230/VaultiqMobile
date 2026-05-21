import 'package:intl/intl.dart';

final _lkr = NumberFormat.currency(
  locale: 'en_LK',
  symbol: 'LKR ',
  decimalDigits: 0,
);

String formatLKR(num value) => _lkr.format(value);

String formatLKRCompact(num value) {
  if (value.abs() >= 1000000) {
    return 'LKR ${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value.abs() >= 1000) {
    return 'LKR ${(value / 1000).toStringAsFixed(1)}K';
  }
  return formatLKR(value);
}

String formatMonthLabel(String yyyyMm) {
  try {
    final parts = yyyyMm.split('-');
    if (parts.length == 2) {
      final d = DateTime(int.parse(parts[0]), int.parse(parts[1]));
      return DateFormat('MMM yyyy').format(d);
    }
  } catch (_) {}
  return yyyyMm;
}

String currentMonthKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}';
}

double parseCurrencyInput(String raw) {
  final cleaned = raw.replaceAll(RegExp(r'[^\d.]'), '');
  if (cleaned.isEmpty) return 0;
  return double.tryParse(cleaned) ?? 0;
}

String formatCurrencyInput(String raw) {
  if (raw.isEmpty) return '';
  final parts = raw.split('.');
  final intPart = parts[0].replaceAll(RegExp(r'\D'), '');
  if (intPart.isEmpty && !raw.contains('.')) return '';
  final formatted = intPart.isEmpty
      ? ''
      : int.parse(intPart).toString().replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );
  if (parts.length > 1) {
    final dec = parts.sublist(1).join().replaceAll(RegExp(r'\D'), '');
    return '$formatted.${dec.length > 2 ? dec.substring(0, 2) : dec}';
  }
  if (raw.endsWith('.')) return '$formatted.';
  return formatted;
}
