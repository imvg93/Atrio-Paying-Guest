import 'package:intl/intl.dart';

/// All money crosses the wire as **integer paise** (CLAUDE.md 3.7) — never a
/// float, never a formatted string. This is the only place paise becomes
/// something a human reads.
///
/// ₹8,500 is transported as `850000`.
class Money {
  const Money._();

  static final NumberFormat _rupees = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _rupeesWithPaise = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// `850000` → `₹8,500`. Rounds to whole rupees, which is what rent always is.
  static String format(int paise) => _rupees.format(paise / 100);

  /// `850050` → `₹8,500.50`. Use where paise genuinely matter, e.g. fines.
  static String formatExact(int paise) => _rupeesWithPaise.format(paise / 100);

  /// Rent-range label for a search card. Collapses to one value when equal.
  static String range(int? minPaise, int? maxPaise) {
    if (minPaise == null && maxPaise == null) return 'Price on request';
    if (minPaise == null) return 'Up to ${format(maxPaise!)}';
    if (maxPaise == null || minPaise == maxPaise) return format(minPaise);
    return '${format(minPaise)} – ${format(maxPaise)}';
  }

  /// Converts user input in rupees to the paise the API expects.
  static int rupeesToPaise(num rupees) => (rupees * 100).round();

  static double paiseToRupees(int paise) => paise / 100;
}
