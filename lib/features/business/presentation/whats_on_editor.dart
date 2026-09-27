import '../../../core/models/live_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';

class WhatsOnEditor extends ConsumerStatefulWidget {
  final String venueId;
  const WhatsOnEditor({super.key, required this.venueId});
  @override
  ConsumerState<WhatsOnEditor> createState() => _WhatsOnEditorState();
}

class _WhatsOnEditorState extends ConsumerState<WhatsOnEditor> {
  final _text = TextEditingController();
  bool _saving = false;
  int _hours = 2;
  String _type = 'notice';

  bool get _isWorker => AuthService().currentUser?.role == UserRole.WORKER;

  static const _types = ['notice', 'music', 'offer', 'event'];
  static const _typeIcons = {
    'notice': Icons.campaign_outlined,
    'music': Icons.music_note_outlined,
    'offer': Icons.local_offer_outlined,
    'event': Icons.event_outlined,
  };
  static const _quickTexts = [
    'Live music tonight',
    'Flash 2-for-1 offer active now',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final dio = ref.read(apiClientProvider);
      final response = _isWorker
          ? await dio.get('/worker/venues/${widget.venueId}/live-info')
          : await dio.get('/venues/${widget.venueId}/whats-on');
      if (!mounted || _text.text.isNotEmpty) return;
      final entries = LiveInfo.entries(response.data);
      if (entries.isNotEmpty) {
        final data = entries.first;
        _text.text = (data['title'] ?? data['message'])?.toString() ?? '';
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (_saving || _text.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      final dio = ref.read(apiClientProvider);
      final payload = LiveInfo.publishPayload(
          _text.text, _type, DateTime.now().add(Duration(hours: _hours)));
      if (_isWorker) {
        await dio.post('/worker/venues/${widget.venueId}/live-info',
            data: payload);
      } else {
        await dio.put('/business/venues/${widget.venueId}/whats-on',
            data: payload);
      }
      if (!mounted) return;
      _text.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Announcement published'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.response?.statusCode == 404
            ? 'Announcements not available on the server yet.'
            : 'Could not publish. Your draft is preserved.'),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xFF334155).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(children: [
            Icon(Icons.campaign_outlined,
                color: AppTheme.primaryColor, size: 16),
            SizedBox(width: 8),
            Text("WHAT'S ON NOW",
                style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5)),
          ]),
          const SizedBox(height: 14),

          // Quick-fill chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickTexts
                .map((t) => GestureDetector(
                      onTap:
                          _saving ? null : () => setState(() => _text.text = t),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Text(t,
                            style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 14),

          // Type selector row
          Row(
            children: _types.map((type) {
              final selected = _type == type;
              return Expanded(
                child: GestureDetector(
                  onTap: _saving ? null : () => setState(() => _type = type),
                  child: Container(
                    margin: EdgeInsets.only(right: type != _types.last ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primaryColor.withValues(alpha: 0.15)
                          : const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? AppTheme.primaryColor
                            : const Color(0xFF334155),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(_typeIcons[type],
                            size: 16,
                            color: selected
                                ? AppTheme.primaryColor
                                : const Color(0xFF64748B)),
                        const SizedBox(height: 3),
                        Text(
                          type[0].toUpperCase() + type.substring(1),
                          style: TextStyle(
                            color: selected
                                ? AppTheme.primaryColor
                                : const Color(0xFF64748B),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Announcement text field
          Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    onSurface: Colors.white,
                    onSurfaceVariant: const Color(0xFF94A3B8),
                  ),
            ),
            child: TextFormField(
              controller: _text,
              enabled: !_saving,
              maxLength: 280,
              maxLines: 2,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Tell customers what is happening right now...',
                hintStyle:
                    const TextStyle(color: Color(0xFF475569), fontSize: 13),
                counterStyle:
                    const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppTheme.primaryColor, width: 1),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Expiry + actions row
          Row(
            children: [
              // Expiry dropdown
              Expanded(
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _hours,
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(
                          color: Color(0xFF94A3B8), fontSize: 13),
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: Color(0xFF64748B), size: 18),
                      items: [1, 2, 4, 8, 24]
                          .map((h) => DropdownMenuItem(
                                value: h,
                                child:
                                    Text('Expires in $h hr${h > 1 ? 's' : ''}'),
                              ))
                          .toList(),
                      onChanged:
                          _saving ? null : (h) => setState(() => _hours = h!),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Clear button
              GestureDetector(
                onTap: _saving ? null : () => setState(() => _text.clear()),
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: const Center(
                    child: Text('Clear',
                        style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Publish button
              GestureDetector(
                onTap: _saving ? null : _publish,
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppTheme.darkBg))
                        : const Text('Publish',
                            style: TextStyle(
                                color: AppTheme.darkBg,
                                fontSize: 13,
                                fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
