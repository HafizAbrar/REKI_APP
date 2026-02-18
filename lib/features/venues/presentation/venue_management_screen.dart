import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/venue_management_provider.dart';
import 'create_venue_screen.dart';
import 'venue_live_state_screen.dart';

class VenueManagementScreen extends ConsumerStatefulWidget {
  const VenueManagementScreen({super.key});

  @override
  ConsumerState<VenueManagementScreen> createState() => _VenueManagementScreenState();
}

class _VenueManagementScreenState extends ConsumerState<VenueManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(venueManagementProvider.notifier).loadVenues());
  }

  @override
  Widget build(BuildContext context) {
    final venuesAsync = ref.watch(venueManagementProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Venue Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(venueManagementProvider.notifier).loadVenues(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateVenueScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: venuesAsync.when(
        data: (venues) => ListView.builder(
          itemCount: venues.length,
          itemBuilder: (context, index) {
            final venue = venues[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(venue.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Type: ${venue.type}'),
                    Text('Busyness: ${venue.busyness}'),
                    Text('Vibe: ${venue.currentVibe}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VenueLiveStateScreen(venueId: venue.id),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
