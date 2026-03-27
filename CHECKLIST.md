# MovieMatch - Verification Checklist ✅

Use this checklist to verify your MovieMatch setup and ensure everything is working correctly.

## Initial Setup

### Prerequisites
- [ ] Flutter SDK installed (version 3.0.0 or higher)
- [ ] Android Studio installed (for Android development)
- [ ] Xcode installed (for iOS development, Mac only)
- [ ] Firebase account created
- [ ] TMDB account created
- [ ] Git installed (optional)

## Firebase Configuration

### Firebase Console Setup
- [ ] Firebase project created
- [ ] Firebase project name noted
- [ ] Anonymous authentication enabled
- [ ] Google sign-in provider enabled
- [ ] Support email added for Google sign-in
- [ ] Firestore database created
- [ ] Firestore location selected
- [ ] Security rules updated with provided rules
- [ ] Composite indexes created (optional but recommended)

### Android Firebase Setup
- [ ] Android app added to Firebase project
- [ ] Package name matches: `com.moviematch.app`
- [ ] SHA-1 fingerprint obtained (debug keystore)
- [ ] SHA-1 fingerprint added to Firebase
- [ ] `google-services.json` downloaded
- [ ] `google-services.json` placed in `android/app/`
- [ ] `android/build.gradle` updated with Google services plugin
- [ ] `android/app/build.gradle` updated with plugin

### iOS Firebase Setup
- [ ] iOS app added to Firebase project
- [ ] Bundle ID matches your Xcode project
- [ ] `GoogleService-Info.plist` downloaded
- [ ] `GoogleService-Info.plist` added to Xcode project
- [ ] "Copy items if needed" checked when adding
- [ ] URL scheme added to Xcode (REVERSED_CLIENT_ID)

### FlutterFire CLI Setup (Alternative)
- [ ] FlutterFire CLI installed: `dart pub global activate flutterfire_cli`
- [ ] Firebase login completed: `firebase login`
- [ ] Project configured: `flutterfire configure`
- [ ] `firebase_options.dart` generated
- [ ] `main.dart` updated to use DefaultFirebaseOptions

## TMDB API Setup

### API Configuration
- [ ] TMDB account created
- [ ] Email verified
- [ ] API key requested (Developer option)
- [ ] API key received
- [ ] `lib/core/constants.dart` opened
- [ ] API key added: `tmdbApiKey = 'YOUR_KEY_HERE'`
- [ ] File saved

## Project Files

### Required Files Checklist
- [ ] `pubspec.yaml` - Dependencies configured
- [ ] `lib/main.dart` - Entry point exists
- [ ] `lib/core/constants.dart` - TMDB API key added
- [ ] `lib/core/theme.dart` - Theme configured
- [ ] All model files exist in `lib/models/`
- [ ] All provider files exist in `lib/providers/`
- [ ] All service files exist in `lib/services/`
- [ ] All screen files exist in `lib/screens/`
- [ ] All widget files exist in `lib/widgets/`
- [ ] `android/app/google-services.json` exists
- [ ] `ios/Runner/GoogleService-Info.plist` exists (iOS only)
- [ ] Android manifest updated
- [ ] iOS Info.plist updated

### Optional Files
- [ ] Font files added to `assets/fonts/` (or removed from pubspec)
- [ ] App icon added (optional)
- [ ] Splash screen customized (optional)

## Dependency Installation

### Flutter Packages
- [ ] Run `flutter pub get`
- [ ] No dependency errors
- [ ] All packages downloaded successfully
- [ ] Build files generated

## Build Verification

### Android Build
- [ ] `flutter build apk --debug` runs successfully
- [ ] No build errors
- [ ] APK generated in `build/app/outputs/flutter-apk/`
- [ ] File size reasonable (~50-80 MB for debug)

### iOS Build (Mac only)
- [ ] `flutter build ios --debug` runs successfully
- [ ] No build errors
- [ ] Xcode project opens without issues
- [ ] Pods installed successfully

## Run Tests

### Device/Emulator Setup
- [ ] Android emulator created and running
- [ ] iOS simulator running (Mac only)
- [ ] Physical device connected (optional)
- [ ] `flutter devices` shows available devices

### App Launch
- [ ] Run `flutter run` on Android
- [ ] App installs successfully
- [ ] App launches without crashes
- [ ] Splash screen appears
- [ ] Login screen appears after splash
- [ ] Run `flutter run` on iOS (Mac only)
- [ ] iOS app installs and launches

## Feature Testing

### Authentication Features
- [ ] "Continue as Guest" button works
- [ ] Anonymous login succeeds
- [ ] Redirected to home screen
- [ ] User appears in Firebase Console → Authentication
- [ ] Sign out and sign in again
- [ ] "Continue with Google" button works
- [ ] Google account picker appears
- [ ] Google login succeeds
- [ ] Correct user name displayed on home screen
- [ ] User document created in Firestore `users` collection

### Room Creation
- [ ] "Create Room" button works
- [ ] Room created successfully
- [ ] 6-character room code displayed
- [ ] Room code is uppercase
- [ ] Redirected to swipe screen
- [ ] Room document exists in Firestore `rooms` collection
- [ ] Room status is "waiting" initially
- [ ] User ID in room's userIds array

### Room Joining
- [ ] Can enter room code in text field
- [ ] "Join Room" button works
- [ ] Error shown if code is invalid
- [ ] Error shown if room doesn't exist
- [ ] Successfully joins existing room
- [ ] Room status changes to "active"
- [ ] Both user IDs in userIds array
- [ ] "Ready to match" message appears

### Movie Loading
- [ ] Movies load on swipe screen
- [ ] Movie posters display correctly
- [ ] Movie titles visible
- [ ] Rating stars shown
- [ ] Release year displayed
- [ ] Genres shown as chips
- [ ] Overview text visible
- [ ] No API errors in console
- [ ] Images load and cache

### Swipe Functionality
- [ ] Can drag movie card left/right
- [ ] Card rotates during drag
- [ ] "LIKE" indicator appears on right swipe
- [ ] "NOPE" indicator appears on left swipe
- [ ] Card animates off screen
- [ ] Next movie appears
- [ ] Like button (❤️) works
- [ ] Dislike button (✖️) works
- [ ] Haptic feedback on swipe (if supported)

### Matching Logic
- [ ] Both users in same room
- [ ] Both users swipe right on same movie
- [ ] Match dialog appears
- [ ] "It's a Match!" message shown
- [ ] Movie title displayed in dialog
- [ ] Movie poster shown in dialog
- [ ] Celebration animation plays
- [ ] Match document created in Firestore `matches` collection
- [ ] Both user IDs in match document
- [ ] "Continue Swiping" button works
- [ ] Returns to swipe screen

### Like Storage
- [ ] Likes saved to Firestore when swiping right
- [ ] Like documents appear in `likes` collection
- [ ] Like contains correct roomId
- [ ] Like contains correct userId
- [ ] Like contains correct movieId
- [ ] Timestamp recorded

### UI/UX Features
- [ ] Dark theme applied throughout
- [ ] Material 3 components used
- [ ] Smooth animations
- [ ] Loading skeletons appear during load
- [ ] Error states handled gracefully
- [ ] Back navigation works correctly
- [ ] Status bar appears correctly
- [ ] Portrait orientation locked
- [ ] No UI overflow errors

## Error Handling

### Network Errors
- [ ] Turn off internet → appropriate error shown
- [ ] Turn internet back on → app recovers
- [ ] Retry button works after network error

### Authentication Errors
- [ ] Cancel Google sign-in → returns to login screen
- [ ] Invalid credentials handled gracefully

### Firestore Errors
- [ ] Permission denied errors show user-friendly message
- [ ] Database errors don't crash app

### API Errors
- [ ] Invalid TMDB API key → error message shown
- [ ] API rate limit → handled gracefully
- [ ] Movie not found → fallback works

## Performance

### Loading Times
- [ ] Splash screen duration appropriate (2-3 seconds)
- [ ] Movies load within 3 seconds
- [ ] Images load progressively
- [ ] No lag during swipe gestures
- [ ] Match dialog appears immediately
- [ ] Transitions are smooth (60fps)

### Memory
- [ ] App memory usage stable
- [ ] No memory leaks detected
- [ ] Images cached properly
- [ ] Old images released from memory

## Security

### API Keys
- [ ] TMDB API key not committed to git
- [ ] Firebase config files in .gitignore
- [ ] No sensitive data in public code

### Firebase Security
- [ ] Security rules tested in Firebase Console
- [ ] Can't access other users' data
- [ ] Can't access rooms you're not in
- [ ] Authentication required for all operations

## Production Readiness

### Before Production Release
- [ ] Remove all debug print statements
- [ ] Test on multiple devices
- [ ] Test on different Android versions
- [ ] Test on different iOS versions
- [ ] Create release keystore (Android)
- [ ] Configure signing (Android)
- [ ] Configure provisioning profiles (iOS)
- [ ] Update app name and icon
- [ ] Update package name/bundle ID
- [ ] Set up separate Firebase project for production
- [ ] Enable Firebase Crashlytics (optional)
- [ ] Set up Firebase Analytics (optional)
- [ ] Test release build
- [ ] Prepare store listings
- [ ] Create privacy policy
- [ ] Create terms of service

### Release Builds
- [ ] `flutter build apk --release` succeeds
- [ ] `flutter build appbundle --release` succeeds (Android)
- [ ] `flutter build ios --release` succeeds (iOS)
- [ ] Release APK/AAB signed correctly
- [ ] iOS IPA signed correctly
- [ ] Test release builds on real devices
- [ ] Performance in release mode verified

## Documentation

### Code Documentation
- [ ] README.md reviewed
- [ ] QUICKSTART.md reviewed
- [ ] FIREBASE_SETUP.md reviewed
- [ ] ARCHITECTURE.md reviewed
- [ ] All setup steps clear and correct
- [ ] Screenshots added (optional)
- [ ] Video demo created (optional)

## Final Checks

- [ ] All features working end-to-end
- [ ] No console errors or warnings
- [ ] No UI glitches or artifacts
- [ ] App stable with no crashes
- [ ] Both Android and iOS working
- [ ] Firebase data structure correct
- [ ] API integrations working
- [ ] User experience smooth and intuitive

## Known Issues to Check

- [ ] SHA-1 fingerprint issues (Android Google Sign-In)
- [ ] Font loading issues (if Poppins not added)
- [ ] Firestore index creation needed
- [ ] TMDB API rate limiting
- [ ] Internet connectivity handling
- [ ] Device compatibility

## Support

If any items fail:
1. Check the detailed documentation (README.md, FIREBASE_SETUP.md)
2. Review error messages carefully
3. Verify all configuration files
4. Clean and rebuild: `flutter clean && flutter pub get && flutter run`
5. Check Firebase Console for any issues
6. Verify API keys are correct

---

## Status

**Date Tested**: _____________

**Tester**: _____________

**Overall Status**: ⬜ Pass | ⬜ Fail | ⬜ Needs Review

**Notes**:
```
[Add any notes here]
```

---

**Congratulations! If all checks pass, your MovieMatch app is ready! 🎉**
