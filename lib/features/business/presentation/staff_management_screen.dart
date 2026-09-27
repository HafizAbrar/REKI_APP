import 'business_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';

// ── Providers ────────────────────────────────────────────────────────────────

final staffListProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final res = await ref.read(apiClientProvider).get('/worker/staff');
  final raw = res.data;
  if (raw is List) return List<Map<String, dynamic>>.from(raw);
  if (raw is Map) {
    final inner = raw['data'] ?? raw['staff'] ?? raw['items'] ?? [];
    if (inner is List) return List<Map<String, dynamic>>.from(inner);
  }
  return [];
});

// ── Screen ───────────────────────────────────────────────────────────────────

class StaffManagementScreen extends ConsumerStatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  ConsumerState<StaffManagementScreen> createState() =>
      _StaffManagementScreenState();
}

class _StaffManagementScreenState extends ConsumerState<StaffManagementScreen> {
  bool _creating = false;

  final _assigning = <String>{};

  Future<void> _manageAssignment(String staffId, String name) async {
    if (!_assigning.add(staffId)) return;
    setState(() {});
    try {
      final api = ref.read(apiClientProvider);
      final response = await api.get('/business/venues');
      final raw = response.data;
      final inner = raw is Map ? raw['data'] ?? raw : raw;
      final list = inner is List
          ? inner
          : inner is Map
              ? inner['venues'] ?? inner['items'] ?? []
              : [];
      final venues = (list as List)
          .whereType<Map>()
          .where((v) => v['id'] != null)
          .toList();
      if (!mounted) return;
      if (venues.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No owned venues available.')));
        return;
      }
      var venueId = venues.first['id'].toString();
      final action = await showDialog<String>(
          context: context,
          builder: (ctx) => StatefulBuilder(
              builder: (ctx, update) => AlertDialog(
                    title: Text('Venue access for $name'),
                    content: DropdownButtonFormField<String>(
                      initialValue: venueId,
                      isExpanded: true,
                      items: venues
                          .map((v) => DropdownMenuItem(
                              value: v['id'].toString(),
                              child: Text(v['name']?.toString() ?? 'Venue')))
                          .toList(),
                      onChanged: (value) => update(() => venueId = value!),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, 'remove'),
                          child: const Text('Remove access')),
                      FilledButton(
                          onPressed: () => Navigator.pop(ctx, 'assign'),
                          child: const Text('Assign')),
                    ],
                  )));
      if (action == null || !mounted) return;
      if (action == 'assign') {
        await api.post('/worker/venues/$venueId/assignments',
            data: {'businessUserId': staffId});
      } else {
        await api.delete('/worker/venues/$venueId/assignments/$staffId');
      }
      ref.invalidate(staffListProvider);
      ref.invalidate(myVenuesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(action == 'assign'
                ? 'Venue access assigned'
                : 'Venue access removed')));
      }
    } on DioException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Could not update venue access. Please try again.')));
      }
    } finally {
      _assigning.remove(staffId);
      if (mounted) setState(() {});
    }
  }

  Future<void> _createWorker() async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Create Staff Account',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _dialogField(nameCtrl, 'Full Name', Icons.person),
              const SizedBox(height: 12),
              _dialogField(emailCtrl, 'Email', Icons.email,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _dialogField(passCtrl, 'Password', Icons.lock,
                  obscure: true, minLength: 8),
            ]),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFF64748B)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.darkBg),
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _creating = true);
    try {
      await ref.read(apiClientProvider).post('/worker/staff', data: {
        'name': nameCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'password': passCtrl.text,
      });
      ref.invalidate(staffListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Staff account created'),
            backgroundColor: Color(0xFF10B981)));
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data is Map
          ? e.response!.data['message']?.toString()
          : null;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg ?? 'Failed to create staff account'),
          backgroundColor: Colors.red[700]));
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<void> _deactivate(String staffId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Deactivate Staff',
            style: TextStyle(color: Colors.white)),
        content: Text('Remove $name from your team?',
            style: const TextStyle(color: Color(0xFF94A3B8))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFF64748B)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(apiClientProvider).delete('/worker/staff/$staffId');
      ref.invalidate(staffListProvider);
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data is Map
          ? e.response!.data['message']?.toString()
          : null;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg ?? 'Failed to deactivate staff'),
          backgroundColor: Colors.red[700]));
    }
  }

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(staffListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Staff Management',
            style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: _creating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.primaryColor))
                : const Icon(Icons.person_add, color: AppTheme.primaryColor),
            tooltip: 'Add staff',
            onPressed: _creating ? null : _createWorker,
          ),
        ],
      ),
      body: staffAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor)),
        error: (e, _) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.wifi_off, color: Color(0xFF334155), size: 48),
            const SizedBox(height: 12),
            Text(e.toString(),
                style: const TextStyle(color: Color(0xFF64748B)),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.darkBg),
              onPressed: () => ref.invalidate(staffListProvider),
              child: const Text('Retry'),
            ),
          ]),
        ),
        data: (staff) => staff.isEmpty
            ? Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.group_off,
                      color: Color(0xFF334155), size: 56),
                  const SizedBox(height: 16),
                  const Text('No staff yet',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const Text('Tap + to create a worker account.',
                      style: TextStyle(color: Color(0xFF64748B))),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: AppTheme.darkBg),
                    onPressed: _createWorker,
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add Staff'),
                  ),
                ]),
              )
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(staffListProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: staff.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final member = staff[i];
                    final id = member['id']?.toString() ?? '';
                    final name = member['name']?.toString() ??
                        member['fullName']?.toString() ??
                        'Staff';
                    final email = member['email']?.toString() ?? '';
                    final isActive = member['isActive'] ?? true;
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color:
                                const Color(0xFF334155).withValues(alpha: 0.5)),
                      ),
                      child: Row(children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color:
                                AppTheme.primaryColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15)),
                                Text(email,
                                    style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 12)),
                                if (!isActive)
                                  const Text('Inactive',
                                      style: TextStyle(
                                          color: Color(0xFFEF4444),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600)),
                              ]),
                        ),
                        if (isActive)
                          IconButton(
                            icon: const Icon(Icons.store_outlined),
                            tooltip: 'Manage venue access',
                            onPressed: _assigning.contains(id)
                                ? null
                                : () => _manageAssignment(id, name),
                          ),
                        if (isActive)
                          IconButton(
                            icon: const Icon(Icons.person_remove,
                                color: Color(0xFFEF4444), size: 20),
                            tooltip: 'Deactivate',
                            onPressed: () => _deactivate(id, name),
                          ),
                      ]),
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _dialogField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
    bool obscure = false,
    int minLength = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Required';
        if (v.trim().length < minLength) return 'Min $minLength characters';
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF64748B)),
        prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
        filled: true,
        fillColor: const Color(0xFF0F172A),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1),
        ),
        errorStyle: const TextStyle(color: Color(0xFFEF4444)),
      ),
    );
  }
}
