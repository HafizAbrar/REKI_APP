#!/bin/bash

# REKI MVP iOS Build Script
# This script should be run on macOS with Xcode installed

echo "🚀 Building REKI MVP for iOS..."

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: iOS builds can only be created on macOS"
    echo "Please run this script on a Mac with Xcode installed"
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode is not installed"
    echo "Please install Xcode from the App Store"
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter is not installed"
    echo "Please install Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build for iOS simulator (for testing)
echo "🔨 Building for iOS Simulator..."
flutter build ios --simulator

# Build for iOS device (release)
echo "🔨 Building for iOS Device (Release)..."
flutter build ios --release --no-codesign

# Create IPA (requires proper code signing)
echo "📱 To create an IPA file for distribution:"
echo "1. Open ios/Runner.xcworkspace in Xcode"
echo "2. Select 'Any iOS Device' as the target"
echo "3. Go to Product > Archive"
echo "4. Follow the distribution workflow"

echo "✅ iOS build completed!"
echo "📁 Build output: build/ios/iphoneos/Runner.app"