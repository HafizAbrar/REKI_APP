import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/business_api_service.dart';
import '../../../core/services/business_repository.dart';
import '../../../core/utils/error_handler.dart';

final userVenuesProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.read(businessApiServiceProvider).getMyVenues();
});

const _allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

const _offerTypes = [
  ('2-for-1',     '2 for 1',    Icons.local_bar,       Color(0xFF8B5CF6)),
  ('discount',    'Discount',   Icons.percent,          Color(0xFF3B82F6)),
  ('freebie',     'Freebie',    Icons.card_giftcard,    Color(0xFF10B981)),
  ('guestlist',   'Guestlist',  Icons.star,             Color(0xFFF59E0B)),
  ('happy-hour',  'Happy Hour', Icons.access_time,      Color(0xFFEF4444)),
];

class CreateOfferScreen extends ConsumerStatefulWidget {
  final String venueId;
  const CreateOfferScreen({super.key, required this.venueId});

  @override
  ConsumerState<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends ConsumerState<CreateOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl        = TextEditingController();
  final _descCtrl         = TextEditingController();
  final _maxRedCtrl       = TextEditingController(text: '100');
  final _savingCtrl       = TextEditingController(text: '0');

  String? _selectedVenueId;
  String  _offerType        = '2-for-1';
  final Set<String> _validDays = {'Mon', 'Tue', 'Wed', 'Thu', 'Fri'};
  TimeOfDay _timeStart      = const TimeOfDay(hour: 17, minute: 0);
  TimeOfDay _timeEnd        = const TimeOfDay(hour: 19, minute: 0);
  DateTime  _expiresAt      = DateTime.now().add(const Duration(days: 365));
  bool      _isAvailableNow = true;
  bool      _isLoading      = false;

  @override
  void initState() {
    super.initState();
    _selectedVenueId = widget.venueId.isEmpty ? null : widget.venueId;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _maxRedCtrl.dispose();
    _savingCtrl.dispose();
    super.dispose();
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _timeStart : _timeEnd,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => isStart ? _timeStart = picked : _timeEnd = picked);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiresAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _expiresAt = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVenueId == null) {
      _snack('Please select a venue', isError: true); return;
    }
    if (_validDays.isEmpty) {
      _snack('Select at least one valid day', isError: true); return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await ref.read(businessRepositoryProvider).createOffer({
        'venueId':        _selectedVenueId,
        'title':          _titleCtrl.text.trim(),
        'description':    _descCtrl.text.trim(),
        'type':           _offerType,
        'validDays':      _validDays.toList(),
        'validTimeStart': _fmt(_timeStart),
        'validTimeEnd':   _fmt(_timeEnd),
        'maxRedemptions': int.tryParse(_maxRedCtrl.text) ?? 100,
        'savingValue':    int.tryParse(_savingCtrl.text) ?? 0,
        'expiresAt':      _expiresAt.toUtc().toIso8601String(),
        'isAvailableNow': _isAvailableNow,
      });
      if (!mounted) return;
      result.when(
        success: (_) { _snack('Offer created successfully'); context.pop(); },
        failure: (msg) => ErrorHandler.showError(context, msg),
      );
    } catch (e) {
      if (mounted) ErrorHandler.showError(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red[700] : const Color(0xFF10B981),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  (String, String, IconData, Color) get _currentType =>
      _offerTypes.firstWhere((t) => t.$1 == _offerType, orElse: () => _offerTypes[0]);

  @override
  Widget build(BuildContext context) {
    final venuesAsync = ref.watch(userVenuesProvider);
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create Offer',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _isLoading ? null : _submit,
              child: const Text('PUBLISH',
                  style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1)),
            ),
          ),
        ],
      ),
      body: venuesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
        error: (e, _) => Center(
            child: Text(ErrorHandler.getErrorMessage(e),
                style: const TextStyle(color: Colors.white))),
        data: (venues) {
          if (_selectedVenueId != null &&
              venues.every((v) => v['id'] != _selectedVenueId)) {
            _selectedVenueId =
                venues.isNotEmpty ? venues.first['id'] as String : null;
          }
          return _buildBody(venues);
        },
      ),
    );
  }

  Widget _buildBody(List<dynamic> venues) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Preview card ──────────────────────────────────────────────
            _PreviewCard(
              title: _titleCtrl.text.trim().isEmpty ? 'Offer Title' : _titleCtrl.text.trim(),
              type: _currentType.$2,
              typeColor: _currentType.$4,
              typeIcon: _currentType.$3,
              days: _validDays,
              timeStart: _fmt(_timeStart),
              timeEnd: _fmt(_timeEnd),
              saving: int.tryParse(_savingCtrl.text) ?? 0,
              isAvailableNow: _isAvailableNow,
            ),
            const SizedBox(height: 28),

            // ── Venue ─────────────────────────────────────────────────────
            _card(children: [
              _label('VENUE'),
              DropdownButtonFormField<String>(
                value: _selectedVenueId,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: _dec('Select venue', Icons.store_outlined),
                items: venues
                    .map<DropdownMenuItem<String>>((v) => DropdownMenuItem(
                        value: v['id'] as String,
                        child: Text(v['name'] ?? 'Unknown')))
                    .toSet()
                    .toList(),
                onChanged: (v) => setState(() => _selectedVenueId = v),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please select a venue' : null,
              ),
            ]),
            const SizedBox(height: 16),

            // ── Details ───────────────────────────────────────────────────
            _card(children: [
              _label('OFFER DETAILS'),
              TextFormField(
                controller: _titleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _dec('Title *', Icons.title_outlined),
                onChanged: (_) => setState(() {}),
                validator: (v) =>
                    v?.trim().isEmpty ?? true ? 'Title is required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descCtrl,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: _dec('Description', Icons.notes_outlined),
              ),
            ]),
            const SizedBox(height: 16),

            // ── Offer Type ────────────────────────────────────────────────
            _card(children: [
              _label('OFFER TYPE'),
              const SizedBox(height: 4),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _offerTypes.map((t) {
                  final selected = _offerType == t.$1;
                  return GestureDetector(
                    onTap: () => setState(() => _offerType = t.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? t.$4.withOpacity(0.15)
                            : const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: selected ? t.$4 : const Color(0xFF334155),
                            width: selected ? 1.5 : 1),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(t.$3,
                            color: selected ? t.$4 : const Color(0xFF64748B),
                            size: 16),
                        const SizedBox(width: 6),
                        Text(t.$2,
                            style: TextStyle(
                              color: selected ? t.$4 : const Color(0xFF94A3B8),
                              fontSize: 13,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                            )),
                      ]),
                    ),
                  );
                }).toList(),
              ),
            ]),
            const SizedBox(height: 16),

            // ── Valid Days ────────────────────────────────────────────────
            _card(children: [
              _label('VALID DAYS'),
              const SizedBox(height: 4),
              Row(
                children: _allDays.map((day) {
                  final sel = _validDays.contains(day);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() =>
                          sel ? _validDays.remove(day) : _validDays.add(day)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        margin: EdgeInsets.only(
                            right: day != _allDays.last ? 6 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: sel
                              ? AppTheme.primaryColor.withOpacity(0.15)
                              : const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: sel
                                  ? AppTheme.primaryColor
                                  : const Color(0xFF334155),
                              width: sel ? 1.5 : 1),
                        ),
                        child: Text(day,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: sel
                                  ? AppTheme.primaryColor
                                  : const Color(0xFF64748B),
                              fontSize: 11,
                              fontWeight: sel
                                  ? FontWeight.w800
                                  : FontWeight.normal,
                            )),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ]),
            const SizedBox(height: 16),

            // ── Time Window ───────────────────────────────────────────────
            _card(children: [
              _label('VALID TIME WINDOW'),
              Row(children: [
                Expanded(child: _timeTile('Start', _fmt(_timeStart), () => _pickTime(true))),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward, color: Color(0xFF475569), size: 18),
                const SizedBox(width: 12),
                Expanded(child: _timeTile('End', _fmt(_timeEnd), () => _pickTime(false))),
              ]),
            ]),
            const SizedBox(height: 16),

            // ── Limits & Value ────────────────────────────────────────────
            _card(children: [
              _label('LIMITS & VALUE'),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _maxRedCtrl,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: _dec('Max Redemptions', Icons.confirmation_number_outlined),
                    onChanged: (_) => setState(() {}),
                    validator: (v) =>
                        int.tryParse(v ?? '') == null ? 'Enter a number' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _savingCtrl,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: _dec('Saving Value (£)', Icons.savings_outlined),
                    onChanged: (_) => setState(() {}),
                    validator: (v) =>
                        int.tryParse(v ?? '') == null ? 'Enter a number' : null,
                  ),
                ),
              ]),
            ]),
            const SizedBox(height: 16),

            // ── Expiry & Availability ─────────────────────────────────────
            _card(children: [
              _label('EXPIRY & AVAILABILITY'),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.event_outlined,
                        color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Expires At',
                                style: TextStyle(
                                    color: Color(0xFF64748B), fontSize: 11)),
                            const SizedBox(height: 2),
                            Text(
                              '${_expiresAt.day.toString().padLeft(2, '0')}/'
                              '${_expiresAt.month.toString().padLeft(2, '0')}/'
                              '${_expiresAt.year}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                          ]),
                    ),
                    const Icon(Icons.chevron_right,
                        color: Color(0xFF475569), size: 20),
                  ]),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _isAvailableNow
                          ? AppTheme.primaryColor.withOpacity(0.4)
                          : const Color(0xFF334155)),
                ),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isAvailableNow
                          ? AppTheme.primaryColor.withOpacity(0.15)
                          : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.bolt,
                        color: _isAvailableNow
                            ? AppTheme.primaryColor
                            : const Color(0xFF475569),
                        size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Available Now',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                          Text(
                            _isAvailableNow
                                ? 'Offer is live and claimable'
                                : 'Offer is hidden from customers',
                            style: const TextStyle(
                                color: Color(0xFF64748B), fontSize: 12),
                          ),
                        ]),
                  ),
                  Switch(
                    value: _isAvailableNow,
                    onChanged: (v) => setState(() => _isAvailableNow = v),
                    activeColor: AppTheme.primaryColor,
                    inactiveThumbColor: const Color(0xFF475569),
                    inactiveTrackColor: const Color(0xFF1E293B),
                  ),
                ]),
              ),
            ]),
            const SizedBox(height: 32),

            // ── Submit ────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  disabledBackgroundColor:
                      AppTheme.primaryColor.withOpacity(0.4),
                  foregroundColor: AppTheme.backgroundDark,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.backgroundDark))
                    : const Icon(Icons.rocket_launch_outlined, size: 20),
                label: Text(
                  _isLoading ? 'Publishing...' : 'Publish Offer',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── small helpers ─────────────────────────────────────────────────────────

  Widget _card({required List<Widget> children}) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF334155).withOpacity(0.6)),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children),
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Text(text,
            style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5)),
      );

  Widget _timeTile(String label, String value, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF64748B), fontSize: 11)),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.access_time_outlined,
                  color: AppTheme.primaryColor, size: 16),
              const SizedBox(width: 6),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ]),
          ]),
        ),
      );

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: Color(0xFF64748B), fontSize: 13),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 20),
        filled: true,
        fillColor: const Color(0xFF0F172A),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF334155))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5)),
      );
}

// ── Preview Card ─────────────────────────────────────────────────────────────

class _PreviewCard extends StatelessWidget {
  final String title;
  final String type;
  final Color typeColor;
  final IconData typeIcon;
  final Set<String> days;
  final String timeStart;
  final String timeEnd;
  final int saving;
  final bool isAvailableNow;

  const _PreviewCard({
    required this.title,
    required this.type,
    required this.typeColor,
    required this.typeIcon,
    required this.days,
    required this.timeStart,
    required this.timeEnd,
    required this.saving,
    required this.isAvailableNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            typeColor.withOpacity(0.18),
            typeColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: typeColor.withOpacity(0.35)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(typeIcon, color: typeColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(type,
                    style: TextStyle(
                        color: typeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            if (saving > 0)
              Text('£$saving',
                  style: TextStyle(
                      color: typeColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w900)),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isAvailableNow
                    ? const Color(0xFF10B981).withOpacity(0.15)
                    : const Color(0xFF475569).withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isAvailableNow
                        ? const Color(0xFF10B981)
                        : const Color(0xFF475569),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  isAvailableNow ? 'LIVE' : 'HIDDEN',
                  style: TextStyle(
                      color: isAvailableNow
                          ? const Color(0xFF10B981)
                          : const Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5),
                ),
              ]),
            ),
          ]),
        ]),
        const SizedBox(height: 16),
        const Divider(color: Color(0xFF334155), height: 1),
        const SizedBox(height: 14),
        Row(children: [
          const Icon(Icons.access_time_outlined,
              color: Color(0xFF64748B), size: 14),
          const SizedBox(width: 6),
          Text('$timeStart – $timeEnd',
              style: const TextStyle(
                  color: Color(0xFF94A3B8), fontSize: 12)),
          const SizedBox(width: 16),
          const Icon(Icons.calendar_today_outlined,
              color: Color(0xFF64748B), size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              days.isEmpty ? 'No days selected' : days.join(' · '),
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]),
      ]),
    );
  }
}
