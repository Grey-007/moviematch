# MovieMatch - Quick Start Guide 🚀

Get up and running with MovieMatch in 10 minutes!

## Prerequisites ✅

- [ ] Flutter SDK installed (3.0.0+)
- [ ] Android Studio or Xcode installed
- [ ] Firebase account
- [ ] TMDB account

## Setup Steps

### 1. Install Dependencies (2 minutes)

```bash
cd moviematch
flutter pub get
```

### 2. Firebase Setup (5 minutes)

#### Quick Method (Recommended):

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login

# Configure Firebase (follow prompts)
flutterfire configure
```

**Select/Create your Firebase project and it will auto-configure everything!**

#### Manual Method:

See detailed instructions in [FIREBASE_SETUP.md](FIREBASE_SETUP.md)

#### Enable Services in Firebase Console:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Enable **Authentication** → Anonymous & Google Sign-In
4. Create **Firestore Database** → Start in test mode
5. Copy security rules from [FIREBASE_SETUP.md](FIREBASE_SETUP.md)

### 3. TMDB API Key (2 minutes)

1. Go to [TMDB](https://www.themoviedb.org/settings/api)
2. Create account → Request API key
3. Copy your API key
4. Open `lib/core/constants.dart`
5. Replace:
   ```dart
   static const String tmdbApiKey = 'YOUR_TMDB_API_KEY_HERE';
   ```

### 4. Android SHA-1 (1 minute - for Google Sign-In)

```bash
# Get SHA-1
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Copy the SHA-1 fingerprint
```

Add to Firebase:
1. Firebase Console → Project Settings → Your Android App
2. Add fingerprint → Paste SHA-1 → Save
3. Download updated `google-services.json`
4. Place in `android/app/`

### 5. Run the App! (1 minute)

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios
```

## Verify Everything Works ✨

### Test Checklist:

- [ ] App launches successfully
- [ ] Can sign in anonymously
- [ ] Can sign in with Google
- [ ] Can create a room (get room code)
- [ ] Can join a room with code
- [ ] Movies load and display
- [ ] Can swipe left/right on movies
- [ ] Match dialog appears when both users like same movie

## Common Quick Fixes 🔧

### Issue: Movies not loading
```dart
// Check lib/core/constants.dart
static const String tmdbApiKey = 'your_actual_key_here'; // Make sure it's set!
```

### Issue: Google Sign-In fails on Android
```bash
# Rebuild completely
flutter clean
flutter pub get
flutter run
```
Make sure SHA-1 is added to Firebase!

### Issue: Firebase errors
```bash
# Reconfigure Firebase
flutterfire configure
```

### Issue: Build errors
```bash
flutter clean
flutter pub get
rm -rf ios/Pods
cd ios && pod install
cd ..
flutter run
```

## Project Structure Overview 📁

```
lib/
├── main.dart              # Entry point
├── core/
│   ├── constants.dart     # ⚠️ ADD TMDB API KEY HERE
│   └── theme.dart         # App theme
├── models/                # Data models
├── providers/             # Riverpod state management
├── screens/               # UI screens
├── services/              # Backend services
└── widgets/               # Reusable components
```

## Quick Commands 💻

```bash
# Clean build
flutter clean && flutter pub get

# Run on specific device
flutter devices
flutter run -d <device-id>

# Build release APK
flutter build apk --release

# Build iOS
flutter build ios --release

# Check for issues
flutter doctor

# Format code
flutter format .

# Analyze code
flutter analyze
```

## Next Steps 🎯

Once everything works:

1. ✅ Invite a friend to test room joining
2. ✅ Try different movies and genres
3. ✅ Test on both Android and iOS
4. ✅ Customize the theme in `lib/core/theme.dart`
5. ✅ Add more features (see README for roadmap)

## Need Help? 🆘

- **Detailed Firebase Setup**: See [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
- **Full Documentation**: See [README.md](README.md)
- **Common Issues**: Check Troubleshooting section in README

## Architecture Notes 🏗️

- **State Management**: Riverpod (see `lib/providers/`)
- **Navigation**: Navigator 2.0 with MaterialPageRoute
- **Backend**: Firebase Auth + Firestore
- **API**: TMDB REST API
- **UI**: Material 3 dark theme
- **Animations**: flutter_animate + custom animations

## Development Tips 💡

1. **Hot Reload**: Press `r` in terminal while app is running
2. **Hot Restart**: Press `R` for full restart
3. **Debug Mode**: Use Chrome DevTools or VS Code debugger
4. **Logs**: Check console for error messages
5. **Firebase Console**: Monitor real-time data in Firestore

## Performance Tips ⚡

- Images are cached automatically (cached_network_image)
- Movies are lazy-loaded as you swipe
- Firebase queries are optimized with indexes
- Use debug mode during development
- Build release version for performance testing

## Security Reminders 🔒

- ⚠️ **NEVER commit**:
  - `google-services.json`
  - `GoogleService-Info.plist`
  - API keys in constants.dart

- ✅ **ALWAYS**:
  - Use environment variables for production
  - Keep security rules restrictive
  - Test with real users before launch

---

**You're ready to go! Start swiping! 🎬**

For questions or issues, check the full documentation or open an issue on GitHub.
