import 'dart:convert';

class VoucherScan {
  static Map<String, String> redemptionPayload(String code) =>
      {code.contains('.') ? 'qrCodeData' : 'voucherCode': code};

  static String? parse(String raw) {
    var value = raw.trim();
    if (value.isEmpty || value.length > 2048) return null;
    if (value.startsWith('{')) {
      try {
        final data = jsonDecode(value);
        if (data is! Map) return null;
        final code = data['qrCodeData'] ??
            data['voucherCode'] ??
            data['code'] ??
            data['voucher_code'];
        if (code is! String) return null;
        value = code.trim();
      } catch (_) {
        return null;
      }
    } else if (value.contains('://')) {
      final uri = Uri.tryParse(value);
      if (uri == null ||
          !(uri.scheme == 'reki' ||
              (uri.scheme == 'https' &&
                  const ['reki.uk', 'www.reki.uk', 'api.reki.uk']
                      .contains(uri.host)))) {
        return null;
      }
      value = uri.queryParameters['voucherCode'] ??
          uri.queryParameters['code'] ??
          uri.queryParameters['voucher'] ??
          '';
      if (value.isEmpty) {
        final parts = uri.pathSegments;
        if (uri.scheme == 'reki' && uri.host == 'redeem' && parts.length == 1) {
          value = parts.single;
        } else if (parts.length == 2 && parts.first == 'redeem') {
          value = parts.last;
        }
      }
    }
    if (RegExp(r'^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$')
        .hasMatch(value)) {
      return value;
    }
    return RegExp(r'^[A-Za-z0-9][A-Za-z0-9_-]{3,127}$').hasMatch(value)
        ? value
        : null;
  }
}
