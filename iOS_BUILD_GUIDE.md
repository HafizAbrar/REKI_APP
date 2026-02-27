# iOS Build Instructions for REKI MVP

## Prerequisites

### 1. macOS System Requirements
- macOS 10.15.4 (Catalina) or later
- At least 8GB RAM (16GB recommended)
- 50GB+ free disk space

### 2. Required Software
- **Xcode 14.0+** (from Mac App Store)
- **Flutter SDK 3.10+** 
- **CocoaPods** (usually installed with Xcode)

### 3. Apple Developer Account
- Free account: For simulator testing only
- Paid account ($99/year): For device testing and App Store distribution

## Setup Instructions

### 1. Install Xcode
```bash
# Install from Mac App Store or
xcode-select --install
```

### 2. Install Flutter (if not already installed)
```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

### 3. Setup iOS Development
```bash
# Accept Xcode license
sudo xcodebuild -license accept

# Install CocoaPods
sudo gem install cocoapods
```

## Building the App

### Option 1: Using the Build Script
```bash
# Make script executable
chmod +x build_ios.sh

# Run the build script
./build_ios.sh
```

### Option 2: Manual Build Process

#### Step 1: Prepare the Project
```bash
# Navigate to project directory
cd /path/to/reki_mvp

# Clean and get dependencies
flutter clean
flutter pub get

# Generate iOS platform files
cd ios
pod install
cd ..
```

#### Step 2: Build for Simulator (Testing)
```bash
flutter build ios --simulator
```

#### Step 3: Build for Device (Release)
```bash
flutter build ios --release --no-codesign
```

#### Step 4: Create IPA using Xcode
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select your development team in project settings
3. Choose "Any iOS Device" as target
4. Go to **Product > Archive**
5. Once archived, click **Distribute App**
6. Choose distribution method:
   - **App Store Connect**: For App Store submission
   - **Ad Hoc**: For testing on registered devices
   - **Enterprise**: For internal distribution
   - **Development**: For development testing

## Code Signing Setup

### For Development/Testing
1. Open Xcode
2. Go to **Preferences > Accounts**
3. Add your Apple ID
4. In project settings, select your team
5. Xcode will automatically manage certificates

### For App Store Distribution
1. Create App Store Connect record
2. Generate distribution certificate
3. Create provisioning profile
4. Configure in Xcode project settings

## Build Outputs

### Simulator Build
- Location: `build/ios/iphonesimulator/Runner.app`
- Use: Testing on iOS Simulator

### Device Build
- Location: `build/ios/iphoneos/Runner.app`
- Use: Base for IPA creation

### IPA File
- Created through Xcode Archive process
- Use: Distribution and installation

## Troubleshooting

### Common Issues

#### 1. "No development team selected"
- Solution: Add Apple ID in Xcode Preferences > Accounts
- Select team in project settings

#### 2. "CocoaPods not found"
```bash
sudo gem install cocoapods
cd ios && pod install
```

#### 3. "Flutter not found"
```bash
export PATH="$PATH:/path/to/flutter/bin"
```

#### 4. Build errors related to permissions
- Ensure Info.plist has required permissions (already added)
- Check iOS deployment target (minimum iOS 11.0)

### Performance Optimization
```bash
# Build with optimization flags
flutter build ios --release --split-debug-info=debug-info --obfuscate
```

## App Store Submission Checklist

- [ ] App icons (all required sizes)
- [ ] Launch screens
- [ ] App Store screenshots
- [ ] App description and metadata
- [ ] Privacy policy (required for location services)
- [ ] Age rating
- [ ] Test on physical devices
- [ ] Performance testing
- [ ] Memory usage optimization

## Distribution Methods

### 1. TestFlight (Beta Testing)
- Upload to App Store Connect
- Add beta testers
- Automatic updates for testers

### 2. Ad Hoc Distribution
- Register device UDIDs
- Create ad hoc provisioning profile
- Distribute IPA file directly

### 3. App Store Release
- Complete App Store review process
- Set release date
- Monitor analytics and crash reports

## Next Steps After Build

1. **Test thoroughly** on physical iOS devices
2. **Optimize performance** and memory usage
3. **Add crash reporting** (Firebase Crashlytics)
4. **Setup analytics** (Firebase Analytics)
5. **Prepare App Store assets** (screenshots, descriptions)
6. **Submit for review** following App Store guidelines

## Support

For build issues:
- Check Flutter documentation: https://flutter.dev/docs/deployment/ios
- Apple Developer documentation: https://developer.apple.com/documentation/
- Xcode release notes for compatibility issues