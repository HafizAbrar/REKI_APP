import '../models/venue.dart';
import '../models/user.dart';
import '../constants/app_constants.dart';

class MockDataService {
  static List<Venue> getManchesterVenues() {
    return [
      Venue(
        id: '1',
        name: 'The Alchemist',
        type: 'Bar',
        latitude: 53.4808,
        longitude: -2.2426,
        address: 'New York Street, Manchester',
        busyness: AppConstants.moderate,
        currentVibe: 'Energetic',
        availableVibes: ['Energetic', 'Party', 'Chill'],
        offers: [
          Offer(
            id: 'o1',
            title: '2-for-1 Cocktails',
            description: 'Happy hour special until 8pm',
            type: 'Drink',
            isActive: true,
            validUntil: DateTime.now().add(Duration(hours: 4)),
          ),
        ],
        lastUpdated: DateTime.now(),
      ),
      Venue(
        id: '2',
        name: 'Dishoom',
        type: 'Restaurant',
        latitude: 53.4794,
        longitude: -2.2451,
        address: 'King Street West, Manchester',
        busyness: AppConstants.busy,
        currentVibe: 'Business',
        availableVibes: ['Business', 'Romantic', 'Chill'],
        offers: [
          Offer(
            id: 'o2',
            title: '15% Off Lunch',
            description: 'Weekday lunch discount',
            type: 'Food',
            isActive: true,
            validUntil: DateTime.now().add(Duration(days: 1)),
          ),
        ],
        lastUpdated: DateTime.now(),
      ),
      Venue(
        id: '3',
        name: 'Revolution',
        type: 'Club',
        latitude: 53.4833,
        longitude: -2.2404,
        address: 'Parsonage Gardens, Manchester',
        busyness: AppConstants.quiet,
        currentVibe: 'Party',
        availableVibes: ['Party', 'Energetic'],
        offers: [],
        lastUpdated: DateTime.now(),
      ),
    ];
  }

  static User getDemoUser() {
    return User(
      id: 'user1',
      email: 'demo@reki.app',
      name: 'Demo User',
      type: UserType.customer,
      preferences: ['Bar', 'Restaurant'],
    );
  }

  static User getDemoBusinessUser() {
    return User(
      id: 'business1',
      email: 'venue@reki.app',
      name: 'The Alchemist Manager',
      type: UserType.business,
      preferences: [],
    );
  }
}