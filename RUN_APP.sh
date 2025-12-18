#!/bin/bash

# Engliya App - Run Script
# This script helps you run the app with speech recognition features

echo "🎓 Engliya - English Learning App"
echo "=================================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"
echo ""

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

echo "✅ Dependencies installed"
echo ""

# Check for connected devices
echo "📱 Checking for connected devices..."
flutter devices

echo ""
echo "⚠️  IMPORTANT: Speech recognition requires a REAL DEVICE"
echo "   - Android Emulator: May not work properly"
echo "   - iOS Simulator: Does not support speech recognition"
echo ""

# Ask user which device to use
echo "Please connect your device via USB and run:"
echo ""
echo "  For Android:"
echo "    flutter run -d <android-device-id>"
echo ""
echo "  For iOS:"
echo "    flutter run -d <ios-device-id>"
echo ""
echo "Or simply run:"
echo "    flutter run"
echo ""
echo "Then select your device from the list."
echo ""

# Optionally run the app
read -p "Do you want to run the app now? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Launching app..."
    flutter run
fi

echo ""
echo "📚 Documentation:"
echo "  - QUICK_START_SPEECH.md - Quick start guide"
echo "  - SPEECH_RECOGNITION_SETUP.md - Setup instructions"
echo "  - LESSON_CONTENT_ENHANCEMENT.md - Content guidelines"
echo "  - UI_IMPROVEMENTS.md - UI changes"
echo ""
echo "Happy learning! ✨"
