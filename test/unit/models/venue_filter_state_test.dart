import 'package:flutter_test/flutter_test.dart';
import 'package:reki_mvp/features/venues/data/venue_management_provider.dart';

void main() {
  test('budget selections activate and copy through venue filters', () {
    const initial = FilterState();
    expect(initial.isActive, isFalse);

    final filtered = initial.copyWith(priceLevels: {1, 2});
    expect(filtered.isActive, isTrue);
    expect(filtered.priceLevels, {1, 2});
  });

  test('filter notifier resets selected budget levels', () {
    final notifier = FilterNotifier();
    notifier.update(priceLevels: {3, 4});
    expect(notifier.state.priceLevels, {3, 4});

    notifier.reset();
    expect(notifier.state.priceLevels, isEmpty);
    expect(notifier.state.isActive, isFalse);
  });
}
