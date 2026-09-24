import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as data;
import 'package:timezone/timezone.dart' as tz;
import '../models/city.dart';

class CityDateFormat {
  static bool _initialized = false;
  static DateTime inCity(DateTime value, City? city) {
    if (!_initialized) {
      data.initializeTimeZones();
      _initialized = true;
    }
    try {
      return tz.TZDateTime.from(
          value.toUtc(), tz.getLocation(city?.timezone ?? 'Europe/London'));
    } catch (_) {
      return value.toUtc();
    }
  }

  static String date(DateTime value, City? city, String locale) =>
      DateFormat.yMMMd(locale).format(inCity(value, city));
  static String dateTime(DateTime value, City? city, String locale) =>
      DateFormat.yMMMd(locale).add_jm().format(inCity(value, city));
}
