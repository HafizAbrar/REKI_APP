import 'package:flutter/material.dart';
import '../../core/models/city.dart';

/// The same locale and direction policy is used by the app and widget tests.
class CityLocalization extends StatelessWidget {
  final City? city;
  final Widget child;
  const CityLocalization({super.key, required this.city, required this.child});

  static Locale localeFor(City? city) {
    if (city == null) return const Locale('en', 'GB');
    var tag =
        city.supportedLanguages.isEmpty ? 'en' : city.supportedLanguages.first;
    // Preserve legacy cities that explicitly prefer RTL but list English first.
    if (city.isRTL && !City.isRtlLanguage(tag)) {
      tag = city.supportedLanguages
          .firstWhere(City.isRtlLanguage, orElse: () => 'ar');
    }
    final parts = tag.replaceAll('_', '-').split('-');
    String? script;
    String? region;
    for (final part in parts.skip(1)) {
      if (part.length == 4) {
        script = part[0].toUpperCase() + part.substring(1).toLowerCase();
      } else if (part.length == 2 || part.length == 3) {
        region = part.toUpperCase();
      }
    }
    return Locale.fromSubtags(
        languageCode: parts.first.toLowerCase(),
        scriptCode: script,
        countryCode:
            region ?? (city.countryCode.isEmpty ? null : city.countryCode));
  }

  @override
  Widget build(BuildContext context) => Directionality(
      textDirection:
          city?.isRTL == true ? TextDirection.rtl : TextDirection.ltr,
      child: child);
}
