import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/automation_provider.dart';

class AutomationScreen extends ConsumerWidget {
  const AutomationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(automationStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Automation')),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(automationStatusProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            statusAsync.when(
              data: (status) => Column(
                children: [
                  _buildStatusCard('Vibe Schedule', status.vibeScheduleEnabled, status.lastVibeUpdate),
                  _buildStatusCard('Busyness Simulation', status.busynessSimulationEnabled, status.lastBusynessUpdate),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Error: $error'),
            ),
            const SizedBox(height: 24),
            const Text('Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildActionButton(context, ref, 'Trigger Demo Scenario', Icons.play_arrow, () async {
              await ref.read(automationActionsProvider).triggerDemoScenario();
              ref.refresh(automationStatusProvider);
            }),
            _buildActionButton(context, ref, 'Update Vibes', Icons.mood, () async {
              await ref.read(automationActionsProvider).updateVibes();
              ref.refresh(automationStatusProvider);
            }),
            _buildActionButton(context, ref, 'Update Busyness', Icons.people, () async {
              await ref.read(automationActionsProvider).updateBusyness();
              ref.refresh(automationStatusProvider);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, bool enabled, String lastUpdate) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(enabled ? Icons.check_circle : Icons.cancel, color: enabled ? Colors.green : Colors.red),
        title: Text(title),
        subtitle: Text('Last update: $lastUpdate'),
        trailing: Text(enabled ? 'Enabled' : 'Disabled', style: TextStyle(color: enabled ? Colors.green : Colors.red)),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref, String label, IconData icon, Future<void> Function() onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        onPressed: () async {
          try {
            await onPressed();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label completed')));
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          }
        },
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }
}
