import '../../../core/models/live_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/city_providers.dart';
import '../../../core/utils/city_date_format.dart';

final whatsOnProvider = StreamProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, id) async* {
  var active = true;
  ref.onDispose(() => active = false);
  final api = ref.read(apiClientProvider);
  while (active) {
    try {
      final res = await api.get('/venues/$id/whats-on');
      if (!active) return;
      yield LiveInfo.entries(res.data);
    } on DioException catch (e) {
      if (!active) return;
      if (e.response?.statusCode == 404) {
        yield const [];
        return;
      }
      yield const [];
    }
    await Future<void>.delayed(const Duration(seconds: 15));
  }
});

class WhatsOnBanner extends ConsumerWidget {
  final String venueId;
  const WhatsOnBanner({super.key, required this.venueId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(whatsOnProvider(venueId)).valueOrNull ?? const [];
    final active = items
        .where((item) => LiveInfo.isVisible(item, DateTime.now()))
        .toList();
    if (active.isEmpty) return const SizedBox.shrink();
    final city = ref.watch(selectedCityProvider).valueOrNull;
    return Column(
        children: active.map((item) {
      final ends = DateTime.tryParse(
          (item['endsAt'] ?? item['expiresAt'])?.toString() ?? '');
      final details = item['details']?.toString();
      return Card(
          child: ListTile(
        leading: const Icon(Icons.bolt),
        title: Text((item['title'] ?? item['message']).toString()),
        subtitle: Text([
          if (details != null && details.isNotEmpty) details,
          if (ends != null)
            'Until ${CityDateFormat.dateTime(ends, city, Localizations.localeOf(context).toString())}',
        ].join('\n')),
      ));
    }).toList());
  }
}
