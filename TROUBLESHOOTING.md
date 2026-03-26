# MovieMatch - Troubleshooting Guide 🔧

This guide covers common issues and their solutions.

## Table of Contents

1. [Build Issues](#build-issues)
2. [Firebase Issues](#firebase-issues)
3. [Authentication Issues](#authentication-issues)
4. [API Issues](#api-issues)
5. [UI Issues](#ui-issues)
6. [Runtime Errors](#runtime-errors)

---

## Build Issues

### Issue: "Could not find com.google.gms:google-services"

**Error Message:**
```
Could not find com.google.gms:google-services:4.4.0
```

**Solutions:**

1. Check `android/build.gradle`:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

2. Check `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'
```

3. Clean and rebuild:
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: "google-services.json not found"

**Error Message:**
```
File google-services.json is missing
```

**Solutions:**

1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/` directory
3. Verify path: `android/app/google-services.json`
4. Rebuild the app

### Issue: Font loading errors

**Error Message:**
```
Unable to load asset: assets/fonts/Poppins-Regular.ttf
```

**Solutions:**

**Option 1**: Add the fonts
1. Download Poppins from [Google Fonts](https://fonts.google.com/specimen/Poppins)
2. Extract and place files in `assets/fonts/`
3. Ensure these files exist:
   - `Poppins-Regular.ttf`
   - `Poppins-Medium.ttf`
   - `Poppins-SemiBold.ttf`
   - `Poppins-Bold.ttf`

**Option 2**: Remove font references
1. Delete font section from `pubspec.yaml`
2. Remove `fontFamily: 'Poppins'` from `lib/core/theme.dart`
3. Run `flutter pub get`

### Issue: Gradle build fails

**Error Message:**
```
Execution failed for task ':app:processDebugGoogleServices'
```

**Solutions:**

1. Ensure `google-services.json` is in correct location
2. Verify package name matches in:
   - `google-services.json`
   - `android/app/build.gradle` (applicationId)
   - `AndroidManifest.xml` (package)
3. Clean build:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue: iOS build fails

**Error Message:**
```
GoogleService-Info.plist not found
```

**Solutions:**

1. Open Xcode: `open ios/Runner.xcworkspace`
2. Drag `GoogleService-Info.plist` into Runner folder
3. Check "Copy items if needed"
4. Verify it appears in Xcode project navigator
5. Clean build folder in Xcode (Product → Clean Build Folder)
6. Try again: `flutter run`

---

## Firebase Issues

### Issue: Permission denied (Firestore)

**Error Message:**
```
FirebaseException: Missing or insufficient permissions
```

**Solutions:**

1. Check authentication status:
```dart
// User must be signed in
if (FirebaseAuth.instance.currentUser == null) {
  // Sign in first
}
```

2. Review Firestore rules in Firebase Console
3. Ensure rules allow authenticated users:
```javascript
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;
}
```

4. Check that user is authenticated in Firebase Console → Authentication

### Issue: Firestore index required

**Error Message:**
```
The query requires an index. You can create it here: [link]
```

**Solutions:**

1. Click the link in the error message
2. Wait for index to build (5-10 minutes)
3. Try the operation again

OR manually create indexes:
1. Go to Firebase Console → Firestore → Indexes
2. Add composite indexes as described in FIREBASE_SETUP.md

### Issue: Firebase not initialized

**Error Message:**
```
[core/no-app] No Firebase App '[DEFAULT]' has been created
```

**Solutions:**

1. Verify `main.dart` has:
```dart
await Firebase.initializeApp();
```

2. Ensure this runs before `runApp()`
3. Check `firebase_core` is in dependencies
4. Rebuild:
```bash
flutter pub get
flutter run
```

---

## Authentication Issues

### Issue: Google Sign-In fails on Android

**Error Message:**
```
PlatformException (sign_in_failed, com.google.android.gms.common.api.ApiException: 10)
```

**Solutions:**

1. **Get SHA-1 fingerprint:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

2. **Add to Firebase:**
   - Firebase Console → Project Settings
   - Your Android App
   - Add fingerprint
   - Paste SHA-1
   - Save

3. **Download updated config:**
   - Download new `google-services.json`
   - Replace in `android/app/`

4. **Rebuild completely:**
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: Google Sign-In user cancelled

**Error Message:**
```
PlatformException (sign_in_canceled)
```

**Solution:**
This is expected when user cancels. Handle gracefully:
```dart
if (user == null) {
  // User cancelled - return to login
  return;
}
```

### Issue: Anonymous sign-in fails

**Error Message:**
```
Anonymous authentication is disabled
```

**Solutions:**

1. Go to Firebase Console → Authentication
2. Click "Sign-in method" tab
3. Enable "Anonymous" provider
4. Save
5. Try again

---

## API Issues

### Issue: Movies not loading

**Error Message:**
```
Exception: Failed to load popular movies: 401
```

**Solutions:**

1. **Check API key:**
   - Open `lib/core/constants.dart`
   - Verify `tmdbApiKey` is set correctly
   - Should NOT be `'YOUR_TMDB_API_KEY_HERE'`

2. **Verify TMDB account:**
   - Go to [TMDB Settings](https://www.themoviedb.org/settings/api)
   - Confirm API key is active
   - Copy the correct API key (not API Read Access Token)

3. **Check internet connection:**
   - Verify device has internet access
   - Try opening a website

4. **Test API key:**
   ```bash
   curl "https://api.themoviedb.org/3/movie/popular?api_key=YOUR_KEY"
   ```

### Issue: Rate limit exceeded

**Error Message:**
```
Failed to load movies: 429
```

**Solutions:**

1. TMDB free tier limits: 40 requests per 10 seconds
2. Wait a minute and try again
3. Implement request throttling in production
4. Consider caching movie data

### Issue: Network error

**Error Message:**
```
Failed to fetch movies: SocketException
```

**Solutions:**

1. Check internet connection
2. Try switching between WiFi and mobile data
3. Check if TMDB API is down: [TMDB Status](https://www.themoviedb.org/)
4. Add timeout handling:
```dart
final response = await http.get(url).timeout(
  Duration(seconds: 10),
  onTimeout: () => throw Exception('Request timeout'),
);
```

---

## UI Issues

### Issue: Image not loading

**Symptoms:**
- Broken image icons
- Placeholder showing instead of poster

**Solutions:**

1. Check internet connection
2. Verify image URL is correct
3. Check TMDB API response includes `poster_path`
4. Try clearing cache:
```bash
flutter clean
```

### Issue: Text overflow errors

**Error Message:**
```
A RenderFlex overflowed by XX pixels
```

**Solutions:**

1. Already handled with `maxLines` and `overflow: TextOverflow.ellipsis`
2. If still occurring, check for very long titles
3. Use `Flexible` or `Expanded` widgets

### Issue: Blank screen after navigation

**Symptoms:**
- Navigation succeeds but screen is white/blank

**Solutions:**

1. Check console for errors
2. Verify widget returns proper `build()` method
3. Check if data is loading (add loading indicators)
4. Verify navigation context is valid

### Issue: Swipe gesture not working

**Symptoms:**
- Can't drag movie cards
- No response to swipe

**Solutions:**

1. Ensure `isTop` parameter is `true` for top card
2. Check if `GestureDetector` is present
3. Verify device touch input works
4. Check if other UI elements are blocking gestures

---

## Runtime Errors

### Issue: Null check operator error

**Error Message:**
```
Null check operator used on a null value
```

**Solutions:**

1. Check for null before accessing:
```dart
// Bad
final name = user!.displayName;

// Good
final name = user?.displayName ?? 'Guest';
```

2. Use null-aware operators:
```dart
movie.posterPath ?? 'default_poster.png'
```

3. Add null checks in provider/service methods

### Issue: Type cast error

**Error Message:**
```
type 'int' is not a subtype of type 'String'
```

**Solutions:**

1. Check Firestore document structure matches model
2. Use proper type conversions:
```dart
// Bad
final id = doc.data()['id'];

// Good
final id = (doc.data()['id'] as num).toInt();
```

3. Validate API response types

### Issue: setState called after dispose

**Error Message:**
```
setState() called after dispose()
```

**Solutions:**

1. Check if widget is mounted:
```dart
if (mounted) {
  setState(() {
    // update state
  });
}
```

2. Cancel subscriptions in `dispose()`:
```dart
@override
void dispose() {
  _subscription.cancel();
  super.dispose();
}
```

### Issue: Concurrent modification error

**Error Message:**
```
Concurrent modification during iteration
```

**Solutions:**

1. Don't modify list while iterating
2. Create a copy:
```dart
// Bad
for (var item in list) {
  list.remove(item);
}

// Good
final itemsToRemove = [...list];
for (var item in itemsToRemove) {
  list.remove(item);
}
```

---

## General Debugging Tips

### Enable Flutter Logs

```bash
# Show all logs
flutter run -v

# Filter specific logs
flutter logs | grep "MovieMatch"
```

### Check Flutter Doctor

```bash
flutter doctor
flutter doctor -v
```

### Clear Everything

```bash
# Nuclear option - clean everything
flutter clean
rm -rf build/
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm pubspec.lock
flutter pub get
cd ios && pod install && cd ..
flutter run
```

### Debug Mode Tools

1. **Flutter DevTools:**
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

2. **Hot Reload:** Press `r` in terminal
3. **Hot Restart:** Press `R` in terminal
4. **Toggle Performance Overlay:** Press `p`

### Check Dependencies

```bash
flutter pub outdated
flutter pub upgrade
```

---

## Platform-Specific Issues

### Android Emulator Issues

**Symptoms:** Emulator slow or not responding

**Solutions:**

1. Increase emulator RAM (Settings → Advanced)
2. Enable hardware acceleration
3. Use x86_64 system image
4. Close other applications

### iOS Simulator Issues

**Symptoms:** Simulator not appearing in devices

**Solutions:**

1. Open Xcode
2. Window → Devices and Simulators
3. Create new simulator
4. Restart Flutter:
```bash
flutter devices
```

### Physical Device Issues

**Android:**

1. Enable Developer Options
2. Enable USB Debugging
3. Accept USB debugging prompt on device
4. Check device appears: `flutter devices`

**iOS:**

1. Trust computer on device
2. Device must be registered in Apple Developer account
3. Provisioning profile must be configured
4. Check device appears: `flutter devices`

---

## Still Having Issues?

### Before Asking for Help

1. ✅ Checked this troubleshooting guide
2. ✅ Reviewed error messages carefully
3. ✅ Tried `flutter clean` and rebuild
4. ✅ Verified all configuration files
5. ✅ Checked Firebase Console for errors
6. ✅ Tested on different device/emulator

### Where to Get Help

1. **Check documentation:**
   - README.md
   - FIREBASE_SETUP.md
   - QUICKSTART.md
   - ARCHITECTURE.md

2. **Search for error:**
   - Google the exact error message
   - Check Stack Overflow
   - Search Flutter GitHub issues

3. **Community Support:**
   - Flutter Discord
   - Flutter Reddit: r/FlutterDev
   - Stack Overflow [flutter] tag

4. **Firebase Support:**
   - Firebase documentation
   - Firebase support forums
   - Firebase Stack Overflow

### Reporting Issues

When reporting an issue, include:

1. **Environment:**
   - Flutter version: `flutter --version`
   - Platform: Android/iOS
   - Device/Emulator details

2. **Error details:**
   - Full error message
   - Stack trace
   - Console output

3. **Steps to reproduce:**
   - What you did
   - What you expected
   - What actually happened

4. **What you've tried:**
   - Solutions attempted
   - Configuration checked

---

## Prevention Tips

1. **Keep dependencies updated:**
```bash
flutter pub upgrade
```

2. **Regularly clean build:**
```bash
flutter clean
flutter pub get
```

3. **Test on multiple devices**

4. **Monitor Firebase quotas**

5. **Implement error boundaries**

6. **Add proper error handling**

7. **Use version control (Git)**

8. **Back up configuration files**

---

**Most issues can be resolved by:**
1. Reading error messages carefully
2. Checking configuration files
3. Running `flutter clean && flutter pub get`
4. Rebuilding the app

**Good luck! 🚀**
