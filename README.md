# REKI MVP - 6-Week Investor Demo

A Flutter MVP for venue discovery and crowd intelligence, focused on Manchester city.

## Project Structure

```
lib/
├── core/
│   ├── constants/          # App-wide constants
│   ├── models/            # Data models (Venue, User, Offer)
│   └── services/          # Business logic services
├── features/
│   ├── auth/              # Authentication feature
│   ├── venues/            # Venue discovery feature
│   ├── business/          # Business dashboard feature
│   └── offers/            # Offers management feature
└── shared/
    ├── widgets/           # Reusable UI components
    └── utils/             # Shared utilities
```

## Key Features

### Customer App
- ✅ Venue discovery (Manchester only)
- ✅ Real-time busyness levels (Quiet/Moderate/Busy)
- ✅ Vibe tracking (Chill/Energetic/Romantic/Business/Party)
- ✅ Offer redemption system
- ✅ Filter by venue type and offers

### Business Dashboard
- ✅ Crowd level management
- ✅ Vibe updates
- ✅ Offer creation and management
- ✅ Real-time venue control

## Demo Accounts

**Customer Account:**
- Email: demo@reki.app
- Password: any

**Business Account:**
- Email: business@reki.app
- Password: any
- Manages: The Alchemist venue

## Setup Instructions

1. **Install Dependencies**
   ```bash
   cd E:\reki_mvp
   flutter pub get
   ```

2. **Run the App**
   ```bash
   flutter run
   ```

3. **Demo Flow**
   - Login with customer account to see venue discovery
   - Login with business account to manage venue settings
   - Switch between accounts to see real-time updates

## MVP Scope (6 Weeks)

### Week 1-2: Core Logic ✅
- Data models and services
- Mock data for Manchester venues
- State management setup

### Week 3-4: User Features ✅
- Authentication system
- Venue discovery and filtering
- Offer redemption flow

### Week 5-6: Business Features ✅
- Business dashboard
- Venue management controls
- Demo polish and stability

## Technical Stack

- **Framework:** Flutter 3.10+
- **State Management:** Provider
- **Data:** Mock services (Phase 1)
- **Platform:** iOS-first MVP

## Next Phase (Post-Investment)

- Real GPS integration
- Live venue partnerships
- Payment processing
- Android support
- Multi-city expansion
- Production infrastructure

## Demo Highlights

1. **Real-time Updates:** Busyness levels change automatically
2. **Business Value:** Clear monetization through offers
3. **Scalable Architecture:** Feature-based structure
4. **Investor Ready:** Professional UI and smooth flows