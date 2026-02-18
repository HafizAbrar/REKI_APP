import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/venue_repository.dart';
import '../data/venue_management_provider.dart';

class VibeSchedulesScreen extends ConsumerWidget {
  final String venueId;

  const VibeSchedulesScreen({super.key, required this.venueId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(vibeSchedulesProvider(venueId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vibe Schedules'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateScheduleDialog(context, ref),
          ),
        ],
      ),
      body: schedulesAsync.when(
        data: (schedules) => schedules.isEmpty
            ? const Center(child: Text('No schedules'))
            : ListView.builder(
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final schedule = schedules[index];
                  return ListTile(
                    title: Text(schedule['vibe'] ?? ''),
                    subtitle: Text(
                      '${schedule['dayOfWeek']} ${schedule['startTime']} - ${schedule['endTime']}',
                    ),
                    trailing: Switch(
                      value: schedule['isActive'] ?? false,
                      onChanged: (value) {},
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _showCreateScheduleDialog(BuildContext context, WidgetRef ref) {
    final vibeController = TextEditingController();
    final dayController = TextEditingController();
    final startController = TextEditingController();
    final endController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Vibe Schedule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: vibeController, decoration: const InputDecoration(labelText: 'Vibe')),
            TextField(controller: dayController, decoration: const InputDecoration(labelText: 'Day of Week')),
            TextField(controller: startController, decoration: const InputDecoration(labelText: 'Start Time')),
            TextField(controller: endController, decoration: const InputDecoration(labelText: 'End Time')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final repository = ref.read(venueRepositoryProvider);
              await repository.createVibeSchedule(venueId, {
                'vibe': vibeController.text,
                'dayOfWeek': dayController.text,
                'startTime': startController.text,
                'endTime': endController.text,
              });
              if (context.mounted) {
                Navigator.pop(context);
                ref.invalidate(vibeSchedulesProvider(venueId));
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
