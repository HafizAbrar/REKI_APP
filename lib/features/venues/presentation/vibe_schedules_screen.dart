import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/vibe_schedule_api_service.dart';
import '../../../core/network/admin_api_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../auth/presentation/auth_provider.dart';

final userVenuesProvider = FutureProvider<List<dynamic>>((ref) async {
  final authService = ref.watch(authNotifierProvider);
  final userId = authService.currentUser?.id;
  if (userId == null) return [];
  final apiService = ref.watch(adminApiServiceProvider);
  return await apiService.getUserVenues(userId);
});

class VibeSchedulesScreen extends ConsumerStatefulWidget {
  const VibeSchedulesScreen({super.key});

  @override
  ConsumerState<VibeSchedulesScreen> createState() => _VibeSchedulesScreenState();
}

class _VibeSchedulesScreenState extends ConsumerState<VibeSchedulesScreen> {
  final _dayOfWeekController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _priorityController = TextEditingController(text: '1');
  String _selectedVibe = 'PARTY';
  String? _selectedVenueId;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _dayOfWeekController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      controller.text = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _createSchedule() async {
    if (_selectedVenueId == null || _dayOfWeekController.text.isEmpty || _startTimeController.text.isEmpty || _endTimeController.text.isEmpty) {
      ErrorHandler.showError(context, 'Please fill all fields');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final apiService = ref.read(vibeScheduleApiServiceProvider);
      await apiService.createVibeSchedule(_selectedVenueId!, {
        'dayOfWeek': int.parse(_dayOfWeekController.text),
        'startTime': _startTimeController.text,
        'endTime': _endTimeController.text,
        'vibe': _selectedVibe,
        'priority': int.parse(_priorityController.text),
        'isActive': _isActive,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule created successfully'), backgroundColor: Color(0xFF10B981)),
        );
        _dayOfWeekController.clear();
        _startTimeController.clear();
        _endTimeController.clear();
      }
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Vibe Schedules', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor.withOpacity(0.2), AppTheme.primaryColor.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.schedule, color: AppTheme.backgroundDark, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vibe Schedule', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                        SizedBox(height: 4),
                        Text('Set automatic vibe changes', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Create Schedule', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            venuesAsync.when(
              data: (venues) => DropdownButtonFormField<String>(
                value: _selectedVenueId,
                dropdownColor: AppTheme.cardDark,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Select Venue',
                  labelStyle: TextStyle(color: AppTheme.iceBlue.withOpacity(0.6)),
                  filled: true,
                  fillColor: AppTheme.cardDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: venues.map<DropdownMenuItem<String>>((v) => DropdownMenuItem<String>(value: v['id'] as String, child: Text(v['name'] ?? 'Unknown'))).toList(),
                onChanged: (v) => setState(() => _selectedVenueId = v),
              ),
              loading: () => const CircularProgressIndicator(color: AppTheme.primaryColor),
              error: (error, _) => Text(ErrorHandler.getErrorMessage(error), style: const TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dayOfWeekController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Day (0-6)',
                      labelStyle: TextStyle(color: AppTheme.iceBlue.withOpacity(0.6)),
                      filled: true,
                      fillColor: AppTheme.cardDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _priorityController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Priority',
                      labelStyle: TextStyle(color: AppTheme.iceBlue.withOpacity(0.6)),
                      filled: true,
                      fillColor: AppTheme.cardDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(_startTimeController),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _startTimeController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Start Time',
                          labelStyle: TextStyle(color: AppTheme.iceBlue.withOpacity(0.6)),
                          suffixIcon: const Icon(Icons.access_time, color: AppTheme.primaryColor),
                          filled: true,
                          fillColor: AppTheme.cardDark,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(_endTimeController),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _endTimeController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'End Time',
                          labelStyle: TextStyle(color: AppTheme.iceBlue.withOpacity(0.6)),
                          suffixIcon: const Icon(Icons.access_time, color: AppTheme.primaryColor),
                          filled: true,
                          fillColor: AppTheme.cardDark,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedVibe,
              dropdownColor: AppTheme.cardDark,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Vibe',
                labelStyle: TextStyle(color: AppTheme.iceBlue.withOpacity(0.6)),
                filled: true,
                fillColor: AppTheme.cardDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: ['PARTY', 'CHILL', 'ENERGETIC', 'ROMANTIC', 'BUSINESS']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedVibe = v!),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(child: Text('Active', style: TextStyle(color: Colors.white, fontSize: 16))),
                Switch(value: _isActive, activeColor: AppTheme.primaryColor, onChanged: (v) => setState(() => _isActive = v)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Create Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
