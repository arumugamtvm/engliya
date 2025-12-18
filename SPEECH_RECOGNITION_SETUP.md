# Speech Recognition Setup Guide

## Overview
The Speak Tab now uses real speech recognition to evaluate pronunciation and provide detailed feedback with wave animations.

## Installation Steps

### 1. Install Dependencies

Run the following command:
```bash
flutter pub get
```

This will install:
- `speech_to_text: ^6.6.0` - For speech recognition
- `permission_handler: ^11.3.0` - For microphone permissions

### 2. Android Configuration

#### Add Permissions to AndroidManifest.xml

File: `android/app/src/main/AndroidManifest.xml`

Add these permissions inside the `<manifest>` tag (before `<application>`):

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
```

#### Update build.gradle

File: `android/app/build.gradle`

Ensure minimum SDK version is 21 or higher:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Must be 21 or higher
        targetSdkVersion 33
    }
}
```

### 3. iOS Configuration

#### Add Permissions to Info.plist

File: `ios/Runner/Info.plist`

Add these keys inside the `<dict>` tag:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to help you practice English pronunciation</string>

<key>NSSpeechRecognitionUsageDescription</key>
<string>This app uses speech recognition to evaluate your pronunciation and provide feedback</string>
```

#### Update Podfile

File: `ios/Podfile`

Ensure platform version is 12.0 or higher:

```ruby
platform :ios, '12.0'
```

Then run:
```bash
cd ios
pod install
cd ..
```

### 4. Testing

#### Test on Real Device (Recommended)

Speech recognition works best on real devices. To test:

```bash
# For Android
flutter run -d <your-android-device-id>

# For iOS
flutter run -d <your-ios-device-id>
```

#### Simulator/Emulator Limitations

- **Android Emulator**: May not support speech recognition properly
- **iOS Simulator**: Does not support speech recognition
- **Always test on real devices for speech features**

### 5. Verify Installation

Run this command to check for issues:

```bash
flutter doctor -v
```

## Features Implemented

### 1. Real Speech Recognition
- Uses device's native speech recognition
- Supports multiple languages (configured for English)
- Real-time speech-to-text conversion

### 2. Wave Animation
- Visual feedback during recording
- Animated bars respond to sound levels
- Smooth animations using Flutter's AnimationController

### 3. Detailed Feedback
- Shows what you said vs expected text
- Calculates pronunciation score (0-100%)
- Provides tips for improvement
- Color-coded feedback (green for good, orange for needs practice)

### 4. Score Calculation
- Word-by-word comparison
- Similarity algorithm
- Percentage-based scoring
- Tracks average across attempts

## Usage

1. **Tap "Tap to Speak" button**
2. **Speak the sentence clearly**
3. **Wait for processing** (wave animation shows recording)
4. **View results** with score and feedback
5. **Practice again** to improve score

## Troubleshooting

### Issue: "Speech recognition not available"

**Solutions:**
1. Check microphone permissions in device settings
2. Ensure you're testing on a real device (not simulator)
3. Verify internet connection (some devices need it for speech recognition)
4. Restart the app after granting permissions

### Issue: "No speech detected"

**Solutions:**
1. Speak louder and clearer
2. Reduce background noise
3. Hold device closer to mouth
4. Check microphone is not blocked

### Issue: Low accuracy scores

**Solutions:**
1. Speak at moderate pace (not too fast/slow)
2. Pronounce words clearly
3. Practice in quiet environment
4. Listen to example audio first

### Issue: Permissions denied

**Solutions:**
1. Go to device Settings > Apps > Engliya > Permissions
2. Enable Microphone permission
3. Restart the app
4. Try recording again

## Platform-Specific Notes

### Android
- Requires Google Play Services for speech recognition
- Works offline on some devices (depends on device)
- May require internet connection on first use

### iOS
- Uses Apple's Speech framework
- Requires iOS 10.0 or higher
- Works offline after initial setup
- More accurate than Android in most cases

## Performance Tips

1. **First Launch**: May take a few seconds to initialize
2. **Background Apps**: Close other apps using microphone
3. **Battery**: Speech recognition uses more battery
4. **Storage**: Downloaded speech models may use storage

## Privacy & Security

- Speech data is processed on-device when possible
- No audio is stored permanently
- Microphone access only when recording
- Permissions can be revoked anytime in settings

## Next Steps

After setup:
1. Test on real device
2. Practice with different sentences
3. Check score accuracy
4. Provide feedback for improvements

## Support

If you encounter issues:
1. Check this guide first
2. Verify all permissions are granted
3. Test on real device (not simulator)
4. Check Flutter and dependency versions

## Version Requirements

- Flutter: 3.10.1 or higher
- Dart: 3.10.1 or higher
- Android: API 21+ (Android 5.0+)
- iOS: 12.0+

## Additional Resources

- [speech_to_text package](https://pub.dev/packages/speech_to_text)
- [permission_handler package](https://pub.dev/packages/permission_handler)
- [Flutter speech recognition guide](https://flutter.dev/docs/development/packages-and-plugins/using-packages)
