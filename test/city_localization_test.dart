import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reki_mvp/core/models/city.dart';
import 'package:reki_mvp/shared/widgets/city_localization.dart';

void main() {
  City city(Map<String, dynamic> values) =>
      City.fromJson({'id': 'test', ...values});

  test('server locale infers RTL and overrides language-list ordering', () {
    final arabic = city({
      'defaultLocale': 'ar-AE',
      'supportedLanguages': ['en', 'ar']
    });
    expect(arabic.isRTL, isTrue);
    expect(CityLocalization.localeFor(arabic), const Locale('ar', 'AE'));
    expect(City.fromJson(arabic.toJson()).isRTL, isTrue);
  });
  test('explicit direction remains authoritative', () {
    expect(city({'defaultLocale': 'ar-AE', 'isRTL': false}).isRTL, isFalse);
    expect(city({'defaultLocale': 'ar-AE', 'is_rtl': false}).isRTL, isFalse);
  });
  test('RTL locale keeps its language instead of always becoming Arabic', () {
    for (final language in ['fa', 'he', 'ur']) {
      final value = city({'defaultLocale': language});
      expect(value.isRTL, isTrue);
      expect(CityLocalization.localeFor(value).languageCode, language);
    }
  });
  test('locale normalization preserves script and country subtags', () {
    final value = city({'defaultLocale': 'zh_Hant_TW'});
    expect(
        CityLocalization.localeFor(value),
        const Locale.fromSubtags(
            languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'));
    expect(city({'supportedLanguages': []}).isRTL, isFalse);
  });
  testWidgets(
      'production direction wrapper changes RTL to LTR when city changes',
      (tester) async {
    const childKey = Key('localized-child');
    Future<void> show(City value) => tester.pumpWidget(
        CityLocalization(city: value, child: const SizedBox(key: childKey)));
    await show(city({'defaultLocale': 'ar-AE'}));
    expect(Directionality.of(tester.element(find.byKey(childKey))),
        TextDirection.rtl);
    await show(city({'defaultLocale': 'en-GB'}));
    expect(Directionality.of(tester.element(find.byKey(childKey))),
        TextDirection.ltr);
    await show(city({'defaultLocale': 'ar-AE', 'isRTL': false}));
    expect(Directionality.of(tester.element(find.byKey(childKey))),
        TextDirection.ltr);
  });
}
