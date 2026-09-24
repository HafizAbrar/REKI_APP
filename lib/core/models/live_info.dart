/// Normalizes the live API list and legacy response envelopes.
class LiveInfo {
  static List<Map<String, dynamic>> entries(dynamic body) {
    final raw = body is Map ? body['data'] ?? body['items'] ?? body : body;
    final list = raw is List
        ? raw
        : raw is Map
            ? [raw]
            : const [];
    return list
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static bool isVisible(Map<String, dynamic> item, DateTime now) {
    final title = item['title'] ?? item['message'];
    final starts = DateTime.tryParse(item['startsAt']?.toString() ?? '');
    final ends = DateTime.tryParse(
        (item['endsAt'] ?? item['expiresAt'])?.toString() ?? '');
    return item['isActive'] != false &&
        title is String &&
        title.trim().isNotEmpty &&
        (starts == null || !starts.isAfter(now)) &&
        (ends == null || ends.isAfter(now));
  }

  static Map<String, dynamic> publishPayload(
          String title, String type, DateTime endsAt) =>
      {
        'type': type,
        'title': title.trim(),
        'endsAt': endsAt.toUtc().toIso8601String(),
        'isActive': true,
      };
}
