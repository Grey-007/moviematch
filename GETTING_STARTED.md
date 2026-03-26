# Getting Started with MovieMatch 🎬

The fastest way to get MovieMatch running on your device!

## What You Need

1. Flutter SDK installed
2. A Firebase account (free)
3. A TMDB API key (free)

---

## 3-Step Quick Start

### Step 1: Install Dependencies (30 seconds)

```bash
cd moviematch
flutter pub get
```

### Step 2: Configure Firebase (3 minutes)

**Automatic Method (Recommended):**

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login
firebase login

# Auto-configure
flutterfire configure
```

Follow the prompts to select/create your Firebase project.

**What it does:**
- Creates Firebase project (or uses existing)
- Adds Android and iOS apps
- Downloads config files
- Generates firebase_options.dart

**Manual Method:**

See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed instructions.

### Step 3: Add TMDB API Key (1 minute)

1. Get key from [TMDB API Settings](https://www.themoviedb.org/settings/api)
2. Open `lib/core/constants.dart`
3. Replace:
```dart
static const String tmdbApiKey = 'YOUR_TMDB_API_KEY_HERE';
```

---

## Enable Firebase Services (2 minutes)

### In Firebase Console:

1. **Authentication:**
   - Go to Authentication → Get Started
   - Enable "Anonymous" provider
   - Enable "Google" provider
   - Add support email

2. **Firestore:**
   - Go to Firestore Database → Create Database
   - Start in "Test mode"
   - Select location

3. **Security Rules:**
   - Copy rules from [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
   - Paste in Rules tab
   - Publish

---

## For Google Sign-In on Android (2 minutes)

### Get SHA-1 Fingerprint:

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### Add to Firebase:

1. Firebase Console → Project Settings
2. Your Android App
3. Add fingerprint → Paste SHA-1
4. Download updated google-services.json
5. Replace in android/app/

---

## Run the App! (30 seconds)

```bash
# Check available devices
flutter devices

# Run on connected device/emulator
flutter run
```

---

## Quick Test Checklist ✅

Once running:

1. ✅ App launches
2. ✅ Can sign in as guest
3. ✅ Can create room
4. ✅ Movies load
5. ✅ Can swipe movies
6. ✅ Match works (test with friend)

---

## If Something Goes Wrong

### Movies Not Loading?
→ Check TMDB API key in `lib/core/constants.dart`

### Google Sign-In Not Working?
→ Add SHA-1 fingerprint to Firebase

### Build Errors?
```bash
flutter clean
flutter pub get
flutter run
```

### Still Stuck?
→ See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

## Next Steps

Once it's running:

1. 📱 Test all features
2. 👥 Invite a friend to test matching
3. 🎨 Customize theme if desired
4. 📚 Read full docs for production setup
5. 🚀 Build release version

---

## Documentation Map

- **This file**: Quick start
- **[README.md](README.md)**: Complete overview
- **[QUICKSTART.md](QUICKSTART.md)**: Detailed quick guide
- **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)**: Full Firebase setup
- **[ARCHITECTURE.md](ARCHITECTURE.md)**: Code structure
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)**: Fix issues
- **[CHECKLIST.md](CHECKLIST.md)**: Verification steps

---

## Project Structure at a Glance

```
lib/
├── main.dart              ← App starts here
├── core/
│   └── constants.dart     ← ADD TMDB API KEY HERE
├── screens/               ← 5 screens
├── widgets/               ← Reusable components
├── services/              ← Firebase & TMDB
├── providers/             ← State management
└── models/                ← Data models
```

---

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Hot reload (while running)
# Press 'r' in terminal

# Clean build
flutter clean

# Check for issues
flutter doctor

# See available devices
flutter devices

# Build release APK
flutter build apk --release
```

---

## Support

- 📖 Read the docs (especially FIREBASE_SETUP.md)
- 🔍 Check TROUBLESHOOTING.md
- 💬 Search error on Stack Overflow
- 🐛 Check Flutter issues on GitHub

---

**Total Setup Time:** ~10 minutes

**Result:** Working MovieMatch app on your device! 🎉

---

Now go match some movies! 🍿
