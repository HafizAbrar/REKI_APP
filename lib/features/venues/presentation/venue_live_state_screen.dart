import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/venue_management_provider.dart';

class VenueLiveStateScreen extends ConsumerStatefulWidget {
  final String venueId;

  const VenueLiveStateScreen({super.key, required this.venueId});

  @override
  ConsumerState<VenueLiveStateScreen> createState() => _VenueLiveStateScreenState();
}

class _VenueLiveStateScreenState extends ConsumerState<VenueLiveStateScreen> {
  String? _selectedBusyness;
  String? _selectedVibe;

  final _busynessLevels = ['Quiet', 'Moderate', 'Busy', 'Packed'];
  final _vibes = ['Chill', 'Energetic', 'Romantic', 'Business', 'Party'];

  @override
  Widget build(BuildContext context) {
    final venueAsync = ref.watch(venueDetailProvider(widget.venueId));

    return Scaffold(
      appBar: AppBar(title: const Text('Update Live State')),
      body: venueAsync.when(
        data: (venue) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(venue.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              const Text('Busyness Level', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _busynessLevels.map((level) {
                  final isSelected = _selectedBusyness == level || (_selectedBusyness == null && venue.busyness == level);
                  return ChoiceChip(
                    label: Text(level),
                    selected: isSelected,
                    onSelected: (selected) => setState(() => _selectedBusyness = level),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text('Current Vibe', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _vibes.map((vibe) {
                  final isSelected = _selectedVibe == vibe || (_selectedVibe == null && venue.currentVibe == vibe);
                  return ChoiceChip(
                    label: Text(vibe),
                    selected: isSelected,
                    onSelected: (selected) => setState(() => _selectedVibe = vibe),
                  );
                }).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateLiveState,
                  child: const Text('Update Live State'),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<void> _updateLiveState() async {
    final success = await ref.read(venueManagementProvider.notifier).updateLiveState(
      widget.venueId,
      busyness: _selectedBusyness,
      currentVibe: _selectedVibe,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Live state updated')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update')),
        );
      }
    }
  }
}
