# Quick Start: Role-Based Authentication Testing

## 🚀 How to Test

### Method 1: Using Token (Fastest)
1. Run the app: `flutter run`
2. Wait for splash screen to complete
3. On login screen, tap **"Login with Token"**
4. Paste your JWT token:
   ```
   eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImhhZml6QGdtYWlsLmNvbSIsInN1YiI6ImVlN2JmYjYyLWFmOGItNGQwMS05NjAzLTJhMGM5Zjc3YzMwOSIsInJvbGUiOiJBRE1JTiIsImlhdCI6MTc3MTQ5MDkyMCwiZXhwIjoxNzcxNDkxODIwfQ.3pwJ9s5JC8zhmafyCkhhx03dVWDPLWRhxX-BR6qwup8
   ```
5. Tap **Continue**
6. App will route to **Admin Dashboard** (since role is ADMIN)

### Method 2: Using Login Credentials
1. Run the app: `flutter run`
2. On login screen, enter credentials
3. App will automatically:
   - Call `/auth/login` to get tokens
   - Call `/auth/me` to get user info
   - Route based on role

## 📱 Expected Routing

| Role | Destination |
|------|-------------|
| USER | Home Screen (Venue Discovery) |
| BUSINESS | Business Dashboard |
| ADMIN | Admin Dashboard |

## 🔄 Flow Diagram

```
App Launch
    ↓
Splash Screen
    ↓
Check Token in Storage?
    ↓
├─ YES → Call /auth/me
│         ↓
│         Route by Role
│         ├─ USER → /home
│         ├─ BUSINESS → /business-dashboard
│         └─ ADMIN → /admin-dashboard
│
└─ NO → /login
         ↓
         User Logs In
         ↓
         Store Tokens
         ↓
         Call /auth/me
         ↓
         Route by Role
```

## 🔧 Configuration

### API Endpoint
- Base URL: `http://18.171.182.71`
- Auth endpoint: `GET /auth/me`
- Header: `Authorization: Bearer <token>`

### Token Storage
- Stored in: Flutter Secure Storage (encrypted)
- Keys: `access_token`, `refresh_token`

## 🧪 Testing Different Roles

To test different roles, you need tokens for users with different roles:

1. **ADMIN Role**: Use the provided token above
2. **BUSINESS Role**: Login with business account or get business token
3. **USER Role**: Login with regular user account or get user token

## 📝 Notes

- Tokens are automatically added to API requests via AuthInterceptor
- Token refresh is handled automatically on 401 errors
- Logout clears tokens from secure storage
- Mock data mode is disabled by default (uses real API)

## 🐛 Troubleshooting

### Token expired
- Get a new token from the API
- Or login with credentials

### Wrong route after login
- Check the role in `/auth/me` response
- Verify User model is parsing role correctly

### API not responding
- Check if API server is running at `http://18.171.182.71`
- Verify network connectivity
