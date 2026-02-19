# Role-Based Authentication Flow

## Overview
This implementation provides role-based routing after authentication using the `/auth/me` endpoint.

## User Roles
- **USER**: Regular customers - routed to `/home`
- **BUSINESS**: Business owners - routed to `/business-dashboard`
- **ADMIN**: Platform administrators - routed to `/admin-dashboard`

## Flow Implementation

### 1. Splash Screen (App Launch)
- Checks for stored access token in secure storage
- If token exists:
  - Calls `/auth/me` to fetch user info
  - Routes based on user role (USER → home, BUSINESS → business-dashboard, ADMIN → admin-dashboard)
- If no token or fetch fails:
  - Routes to `/login`

### 2. Login Flow
- User enters credentials
- On successful login:
  - Stores access token and refresh token in secure storage
  - Calls `/auth/me` to fetch user info
  - Routes based on user role

### 3. Token Input (Testing)
- Accessible from login screen via "Login with Token" link
- Allows direct token input for testing
- Stores token and fetches user info
- Routes based on role

## API Integration

### Endpoint: GET /auth/me
**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "id": "ee7bfb62-af8b-4d01-9603-2a0c9f77c309",
  "email": "hafiz@gmail.com",
  "role": "ADMIN",
  "isActive": true,
  "preferences": null,
  "createdAt": "2026-02-18T17:29:09.680Z",
  "updatedAt": "2026-02-19T08:48:41.007Z"
}
```

## Key Files Modified

1. **lib/core/services/auth_service.dart**
   - Added token storage to secure storage
   - Enhanced `fetchCurrentUser()` to read token from storage
   - Added token cleanup on logout

2. **lib/features/splash/splash_screen.dart**
   - Reads token from secure storage on app launch
   - Implements role-based routing

3. **lib/features/auth/presentation/login_screen.dart**
   - Added "Login with Token" link
   - Implements role-based routing after login

4. **lib/features/auth/presentation/token_input_screen.dart**
   - Updated to use Riverpod providers
   - Implements role-based routing

5. **lib/features/auth/presentation/auth_provider.dart**
   - Added auth service provider
   - Enhanced login to fetch user after authentication

## Testing

### Test with Token
1. Run the app
2. Navigate to Login screen
3. Click "Login with Token"
4. Paste your JWT token
5. App will route based on your role

### Test with Credentials
1. Login with email/password
2. App will automatically fetch user info and route based on role

## Security Features
- Tokens stored in Flutter Secure Storage (encrypted)
- Auth interceptor automatically adds Bearer token to API requests
- Automatic token refresh on 401 errors
- Token cleanup on logout
