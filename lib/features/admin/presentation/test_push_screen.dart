import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/admin_models.dart';
import '../data/admin_provider.dart';

class TestPushScreen extends ConsumerStatefulWidget {
  const TestPushScreen({super.key});

  @override
  ConsumerState<TestPushScreen> createState() => _TestPushScreenState();
}

class _TestPushScreenState extends ConsumerState<TestPushScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userIdCtrl = TextEditingController();
  final _titleCtrl =
      TextEditingController(text: '🔔 REKI Test Notification');
  final _bodyCtrl = TextEditingController(
      text: 'This is a test push from REKI admin panel');

  bool _loading = false;
  TestPushResult? _result;
  String? _error;

  @override
  void dispose() {
    _userIdCtrl.dispose();
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _result = null;
      _error = null;
    });
    try {
      final result = await ref.read(adminProvider.notifier).sendTestPush(
            userId: _userIdCtrl.text.trim(),
            title: _titleCtrl.text.trim(),
            body: _bodyCtrl.text.trim(),
          );
      setState(() => _result = result);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pre-fill userId from users list if available
    final usersAsync = ref.watch(adminProvider).users;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Test Push Notification',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.info_outline,
                      color: Color(0xFF3B82F6), size: 16),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Send a test push notification to any registered user via FCM.',
                      style: TextStyle(
                          color: Color(0xFF93C5FD), fontSize: 12),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 20),

              // User ID field with quick-pick
              _label('User ID'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _userIdCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: _inputDecoration('Enter user UUID'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),

              // Quick-pick from loaded users
              usersAsync.whenOrNull(
                data: (users) {
                  final nonGuests =
                      users.where((u) => u.role != 'guest').toList();
                  if (nonGuests.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      const Text('Quick pick:',
                          style: TextStyle(
                              color: Color(0xFF64748B), fontSize: 11)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: nonGuests.take(6).map((u) {
                          final isSelected =
                              _userIdCtrl.text.trim() == u.id;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _userIdCtrl.text = u.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF2DD4BF)
                                        .withValues(alpha: 0.2)
                                    : const Color(0xFF334155),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF2DD4BF)
                                      : Colors.transparent,
                                ),
                              ),
                              child: Text(
                                u.name,
                                style: TextStyle(
                                    color: isSelected
                                        ? const Color(0xFF2DD4BF)
                                        : const Color(0xFF94A3B8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ) ?? const SizedBox.shrink(),

              const SizedBox(height: 16),
              _label('Title'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: _inputDecoration('Notification title'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 16),
              _label('Body'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _bodyCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: _inputDecoration('Notification body'),
                maxLines: 3,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 24),

              // Send button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _send,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2DD4BF),
                    disabledBackgroundColor:
                        const Color(0xFF2DD4BF).withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Color(0xFF0F172A), strokeWidth: 2),
                        )
                      : const Text(
                          'Send Test Push',
                          style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w800,
                              fontSize: 15),
                        ),
                ),
              ),

              // Error
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color:
                            const Color(0xFFEF4444).withValues(alpha: 0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline,
                        color: Color(0xFFEF4444), size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_error!,
                          style: const TextStyle(
                              color: Color(0xFFFCA5A5), fontSize: 12)),
                    ),
                  ]),
                ),
              ],

              // Result card
              if (_result != null) ...[
                const SizedBox(height: 20),
                _resultCard(_result!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultCard(TestPushResult r) {
    final sentColor =
        r.sent ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: sentColor.withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: sentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              r.sent ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: sentColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.sent ? 'Push Sent Successfully' : 'Push Failed',
                    style: TextStyle(
                        color: sentColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Row(children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: r.firebaseConfigured
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      r.firebaseConfigured
                          ? 'Firebase configured'
                          : 'Firebase not configured',
                      style: TextStyle(
                          color: r.firebaseConfigured
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                          fontSize: 11),
                    ),
                  ]),
                ]),
          ),
        ]),

        const SizedBox(height: 16),
        const Divider(color: Color(0xFF334155), height: 1),
        const SizedBox(height: 14),

        // Push stats grid
        const Text('PUSH STATS',
            style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: _statItem('Total Sent', r.totalSent.toString(),
                  const Color(0xFF3B82F6))),
          _divider(),
          Expanded(
              child: _statItem('Delivered', r.delivered.toString(),
                  const Color(0xFF10B981))),
          _divider(),
          Expanded(
              child: _statItem(
                  'Failed', r.failed.toString(), const Color(0xFFEF4444))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: _statItem(
                  'Opened', r.opened.toString(), const Color(0xFF8B5CF6))),
          _divider(),
          Expanded(
              child: _statItem(
                  'Open Rate', r.openRate, const Color(0xFFF59E0B))),
          _divider(),
          const Expanded(child: SizedBox()),
        ]),
      ]),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(children: [
      Text(value,
          style: TextStyle(
              color: color, fontSize: 22, fontWeight: FontWeight.w900)),
      const SizedBox(height: 3),
      Text(label,
          style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _divider() => Container(
      width: 1, height: 40, color: const Color(0xFF334155));

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 12,
          fontWeight: FontWeight.w600));

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF475569), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2DD4BF)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFCA5A5)),
      );
}
