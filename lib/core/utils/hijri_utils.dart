import 'package:hijri/hijri_calendar.dart';

class HijriUtils {
  /// Returns the Hijri date adjusted for the Indian region.
  /// In India, the Hijri date is typically 1 day behind the Middle East (Saudi) date.
  static HijriCalendar getAdjustedHijri(DateTime date) {
    // Saudi (ME) default: HijriCalendar.fromDate(date)
    // India: Subtract 1 day from the Gregorian date to get the correct Hijri date for India.
    final adjustedDate = date.subtract(const Duration(days: 1));
    return HijriCalendar.fromDate(adjustedDate);
  }

  /// Returns the current Hijri date adjusted for India.
  static HijriCalendar now() {
    return getAdjustedHijri(DateTime.now());
  }

  /// Formats the Hijri date as a string (e.g., "1 Shawwal 1447").
  static String format(HijriCalendar hDate) {
    return "${hDate.hDay} ${hDate.longMonthName} ${hDate.hYear}";
  }
}
