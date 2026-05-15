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

class CreateOfferScreen extends ConsumerStatefulWidget {
  final String venueId;
  const CreateOfferScreen({super.key, required this.venueId});

  @override
  ConsumerState<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends ConsumerState<CreateOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxRedemptionsController = TextEditingController(text: '100');
  final _savingValueController = TextEditingController(text: '0');

  String? _selectedVenueId;
  String _offerType = 'discount';
  final Set<String> _validDays = {'Mon', 'Tue', 'Wed', 'Thu', 'Fri'};
  TimeOfDay _validTimeStart = const TimeOfDay(hour: 17, minute: 0);
  TimeOfDay _validTimeEnd = const TimeOfDay(hour: 19, minute: 0);
  DateTime _expiresAt = DateTime.now().add(const Duration(days: 365));
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedVenueId = widget.venueId.isEmpty ? null : widget.venueId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _maxRedemptionsController.dispose();
    _savingValueController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _validTimeStart : _validTimeEnd,
    );
    if (picked != null) {
      setState(() => isStart ? _validTimeStart = picked : _validTimeEnd = picked);
    }
  }

  Future<void> _pickExpiresAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiresAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (date != null) setState(() => _expiresAt = date);
  }

  Future<void> _createOffer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVenueId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please select a venue'), backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      );
      return;
    }
    if (_validDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Select at least one valid day'), backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await ref.read(businessRepositoryProvider).createOffer({
        'venueId': _selectedVenueId,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'type': _offerType,
        'validDays': _validDays.toList(),
        'validTimeStart': _formatTime(_validTimeStart),
        'validTimeEnd': _formatTime(_validTimeEnd),
        'maxRedemptions': int.tryParse(_maxRedemptionsController.text) ?? 100,
        'savingValue': int.tryParse(_savingValueController.text) ?? 0,
        'expiresAt': _expiresAt.toUtc().toIso8601String(),
      });

      if (!mounted) return;
      result.when(
        success: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Offer created successfully'),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          );
          context.pop();
        },
        failure: (msg) => ErrorHandler.showError(context, msg),
      );
    } catch (e) {
      if (mounted) ErrorHandler.showError(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final venuesAsync = ref.watch(userVenuesProvider);
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
        title: const Text('Create Offer', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
      ),
      body: venuesAsync.when(
        data: (venues) {
          if (_selectedVenueId != null && venues.every((v) => v['id'] != _selectedVenueId)) {
            _selectedVenueId = venues.isNotEmpty ? venues.first['id'] as String : null;
          }
          return _buildForm(venues);
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
        error: (e, _) => Center(child: Text(ErrorHandler.getErrorMessage(e), style: const TextStyle(color: Colors.white))),
      ),
    );
  }

  Widget _buildForm(List<dynamic> venues) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.primaryColor.withOpacity(0.2), AppTheme.primaryColor.withOpacity(0.05)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.local_offer, color: AppTheme.backgroundDark, size: 28),
                ),
                const SizedBox(width: 16),
                const Text('New Offer', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              ]),
            ),
            const SizedBox(height: 28),

            // Venue
            _sectionLabel('Venue'),
            DropdownButtonFormField<String>(
              value: _selectedVenueId,
              dropdownColor: AppTheme.cardDark,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: _inputDecoration('Venue', Icons.store),
              items: venues.map<DropdownMenuItem<String>>((v) =>
                  DropdownMenuItem(value: v['id'] as String, child: Text(v['name'] ?? 'Unknown'))).toSet().toList(),
              onChanged: (v) => setState(() => _selectedVenueId = v),
              validator: (v) => v == null || v.isEmpty ? 'Please select a venue' : null,
            ),
            const SizedBox(height: 24),

            // Offer Details
            _sectionLabel('Offer Details'),
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Title', Icons.title),
              validator: (v) => v?.trim().isEmpty ?? true ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: _inputDecoration('Description', Icons.description),
              validator: (v) => v?.trim().isEmpty ?? true ? 'Description is required' : null,
            ),
            const SizedBox(height: 24),

            // Offer Type
            _sectionLabel('Offer Type'),
            DropdownButtonFormField<String>(
              value: _offerType,
              dropdownColor: AppTheme.cardDark,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: _inputDecoration('Type', Icons.category),
              items: ['2-for-1', 'discount', 'freebie', 'guestlist', 'happy-hour']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.replaceAll('-', ' ').toUpperCase())))
                  .toList(),
              onChanged: (v) => setState(() => _offerType = v!),
            ),
            const SizedBox(height: 24),

            // Valid Days
            _sectionLabel('Valid Days'),
            Wrap(
              spacing: 8,
              children: _allDays.map((day) {
                final selected = _validDays.contains(day);
                return FilterChip(
                  label: Text(day, style: TextStyle(color: selected ? AppTheme.backgroundDark : Colors.white, fontWeight: FontWeight.w600)),
                  selected: selected,
                  selectedColor: AppTheme.primaryColor,
                  backgroundColor: AppTheme.cardDark,
                  checkmarkColor: AppTheme.backgroundDark,
                  side: BorderSide(color: selected ? AppTheme.primaryColor : Colors.white24),
                  onSelected: (val) => setState(() => val ? _validDays.add(day) : _validDays.remove(day)),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Valid Time
            _sectionLabel('Valid Time Window'),
            Row(children: [
              Expanded(child: _timeTile('Start Time', _formatTime(_validTimeStart), () => _pickTime(true))),
              const SizedBox(width: 12),
              Expanded(child: _timeTile('End Time', _formatTime(_validTimeEnd), () => _pickTime(false))),
            ]),
            const SizedBox(height: 24),

            // Max Redemptions & Saving Value
            _sectionLabel('Limits & Value'),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _maxRedemptionsController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Max Redemptions', Icons.confirmation_number),
                  validator: (v) => int.tryParse(v ?? '') == null ? 'Enter a number' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _savingValueController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Saving Value (£)', Icons.savings),
                  validator: (v) => int.tryParse(v ?? '') == null ? 'Enter a number' : null,
                ),
              ),
            ]),
            const SizedBox(height: 24),

            // Expires At
            _sectionLabel('Expiry Date'),
            GestureDetector(
              onTap: _pickExpiresAt,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(children: [
                  const Icon(Icons.event, color: AppTheme.primaryColor),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Expires At', style: TextStyle(color: AppTheme.iceBlue.withOpacity(0.6), fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('${_expiresAt.day}/${_expiresAt.month}/${_expiresAt.year}',
                        style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ])),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
                ]),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createOffer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Create Offer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
  );

  Widget _timeTile(String label, String value, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: AppTheme.iceBlue.withOpacity(0.6), fontSize: 12)),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.access_time, color: AppTheme.primaryColor, size: 18),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        ]),
      ]),
    ),
  );

  InputDecoration _inputDecoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: AppTheme.iceBlue.withOpacity(0.6)),
    prefixIcon: Icon(icon, color: AppTheme.primaryColor),
    filled: true,
    fillColor: AppTheme.cardDark,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
  );
}
