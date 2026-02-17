import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'venue_provider.dart';
import '../../../features/auth/presentation/auth_provider.dart';
import '../../../core/models/venue.dart';
import '../../../core/models/offer.dart';
import '../../../core/theme/app_theme.dart';

class VenueListScreen extends ConsumerStatefulWidget {
  const VenueListScreen({Key? key}) : super(key: key);
  
  @override
  ConsumerState<VenueListScreen> createState() => _VenueListScreenState();
}

class _VenueListScreenState extends ConsumerState<VenueListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(venueProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final venueState = ref.watch(venueProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        title: NeonText('REKI - Manchester', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        actions: [
          IconButton(
            icon: Icon(Icons.tune, color: AppTheme.primaryColor),
            onPressed: () => context.push('/filters'),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: AppTheme.primaryColor),
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(venueState),
          Expanded(
            child: venueState.isLoading
                ? Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                : RefreshIndicator(
                    color: AppTheme.primaryColor,
                    onRefresh: () async => ref.read(venueProvider.notifier).refreshVenues(),
                    child: ListView.builder(
                      itemCount: venueState.filteredVenues.length,
                      itemBuilder: (context, index) {
                        final venue = venueState.filteredVenues[index];
                        return _buildVenueCard(venue);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(VenueState venueState) {
    final filters = ['All', 'Bar', 'Restaurant', 'Club', 'With Offers'];
    
    return Container(
      height: 60,
      color: AppTheme.cardBg,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = venueState.selectedFilter == filter;
          
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: GlowContainer(
              glowRadius: isSelected ? 15 : 0,
              glowSpread: isSelected ? 2 : 0,
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (_) => ref.read(venueProvider.notifier).setFilter(filter),
                backgroundColor: AppTheme.cardBg,
                selectedColor: AppTheme.primaryColor,
                labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVenueCard(Venue venue) {
    return GlowCard(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          title: Text(venue.name, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${venue.type} • ${venue.address}', style: TextStyle(color: Colors.grey[400])),
              SizedBox(height: 4),
              Row(
                children: [
                  _buildBusynessChip(venue.busyness),
                  SizedBox(width: 8),
                  _buildVibeChip(venue.currentVibe),
                ],
              ),
              if (venue.offers.isNotEmpty) ...[
                SizedBox(height: 4),
                Text('${venue.offers.length} offer(s) available', 
                     style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w500)),
              ],
            ],
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: AppTheme.primaryColor),
          onTap: () => context.push('/venue-detail?id=${venue.id}'),
        ),
      ),
    );
  }

  Widget _buildBusynessChip(String busyness) {
    Color color;
    switch (busyness) {
      case 'Quiet': color = Colors.green; break;
      case 'Moderate': color = Colors.orange; break;
      case 'Busy': color = Colors.red; break;
      default: color = Colors.grey;
    }
    
    return Chip(
      label: Text(busyness, style: TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
    );
  }

  Widget _buildVibeChip(String vibe) {
    return Chip(
      label: Text(vibe, style: TextStyle(fontSize: 12, color: Colors.white)),
      backgroundColor: AppTheme.primaryColor.withOpacity(0.3),
    );
  }

  void _showVenueDetails(Venue venue) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(venue.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 8),
            Text('${venue.type} • ${venue.address}', style: TextStyle(color: Colors.grey[400])),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Busyness: ', style: TextStyle(color: Colors.white)),
                _buildBusynessChip(venue.busyness),
                SizedBox(width: 16),
                Text('Vibe: ', style: TextStyle(color: Colors.white)),
                _buildVibeChip(venue.currentVibe),
              ],
            ),
            if (venue.offers.isNotEmpty) ...[
              SizedBox(height: 16),
              Text('Active Offers:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ...venue.offers.map((offer) => ListTile(
                title: Text(offer.title, style: TextStyle(color: Colors.white)),
                subtitle: Text(offer.description, style: TextStyle(color: Colors.grey[400])),
                trailing: GlowButton(
                  text: 'Redeem',
                  onPressed: () => _redeemOffer(offer),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  void _redeemOffer(Offer offer) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Offer "${offer.title}" redeemed!'), backgroundColor: AppTheme.primaryColor),
    );
    Navigator.pop(context);
  }
}
