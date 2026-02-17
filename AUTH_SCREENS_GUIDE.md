# REKI MVP - Authentication Screens

## Overview
All authentication screens have been created with REKI's color scheme and integrated with go_router and riverpod for state management.

## Color Scheme
- **Primary Gradient**: `#1A237E` → `#3949AB` → `#5C6BC0` (Deep Blue to Light Blue)
- **Accent Color**: `#4ECDC4` (Turquoise)
- **Background**: White with rounded corners
- **Text**: Dark blue for headers, grey for subtitles

## Screens Created

### 1. Splash Screen (`splash_screen.dart`)
- Auto-checks authentication status
- Navigates to `/home` if token exists
- Navigates to `/login` if no token
- REKI branding with gradient background

### 2. Login Screen (`login_screen.dart`)
- Email and password fields
- Form validation
- Password visibility toggle
- "Forgot Password?" link → `/forgot-password`
- "Sign Up" link → `/signup`
- Loading state with spinner
- Success navigation to `/home`

### 3. Signup Screen (`signup_screen.dart`)
- Full name, email, phone, password fields
- Form validation
- Password visibility toggle
- Button enabled only when all fields filled
- Success navigation to `/login`
- "Sign In" link for existing users

### 4. Forgot Password Screen (`forgot_password_screen.dart`)
- Phone number input (11 digits)
- Digit-only input formatter
- Sends verification code
- Navigates to `/code-verification` with phone number

### 5. Code Verification Screen (`code_verification_screen.dart`)
- 4-digit code input
- Resend code button
- Displays phone number
- 10-minute expiration notice
- Change phone number option
- Navigates to `/change-password`

### 6. Change Password Screen (`change_password_screen.dart`)
- New password and confirm password fields
- Password visibility toggles
- Password match validation
- Minimum 6 characters requirement
- Success navigation to `/login`

## Router Configuration (`core/router/app_router.dart`)

```dart
Routes:
- /splash → SplashScreen
- /login → LoginScreen
- /signup → SignupScreen
- /forgot-password → ForgotPasswordScreen
- /code-verification → CodeVerificationScreen (with phone number)
- /change-password → ChangePasswordScreen
- /home → VenueListScreen
```

## State Management

### Auth Provider (`auth_provider.dart`)
- Uses Riverpod StateNotifier
- States: Initial, Loading, LoginSuccess, RegisterSuccess, Error
- Methods: `login()`, `register()`, `logout()`
- Token storage with FlutterSecureStorage

## Dependencies Added
- `go_router: ^14.6.2` - Declarative routing

## Usage

### Run the app:
```bash
cd E:\reki_mvp
flutter pub get
flutter run
```

### Navigation Examples:
```dart
// Navigate to login
context.go('/login');

// Navigate with data
context.go('/code-verification', extra: phoneNumber);

// Go back
context.pop();
```

## Features
✅ Consistent REKI color scheme across all screens
✅ Form validation on all inputs
✅ Loading states with spinners
✅ Error handling with SnackBars
✅ Password visibility toggles
✅ Disabled buttons until forms are valid
✅ Smooth navigation with go_router
✅ Riverpod state management
✅ Secure token storage

## Next Steps
- Test all navigation flows
- Add email verification screen if needed
- Integrate with backend API
- Add biometric authentication
- Implement social login (Google, Apple)
