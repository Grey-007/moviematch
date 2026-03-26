# MovieMatch 🎬

A Flutter mobile app that allows two users to swipe on movies and find matches - similar to Tinder but for movies!

## Features ✨

- **Authentication**: Anonymous login or Google Sign-In via Firebase Auth
- **Room System**: Create or join rooms with 6-character codes
- **Movie Swiping**: Tinder-style card swiping with smooth animations
- **Real-time Matching**: Instantly notified when both users like the same movie
- **Beautiful UI**: Dark theme with Material 3 design
- **Haptic Feedback**: Vibration feedback on swipes
- **Movie Data**: Powered by TMDB (The Movie Database) API

## Tech Stack 🛠️

- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Backend**: Firebase (Authentication + Firestore)
- **API**: TMDB (The Movie Database)
- **Animations**: flutter_animate
- **UI**: Material 3 with custom dark theme

## Project Structure 📁

```
lib/
├── core/
│   ├── constants.dart       # App constants and configuration
│   └── theme.dart           # Material 3 dark theme
├── models/
│   ├── user_model.dart      # User data model
│   ├── room_model.dart      # Room data model
│   ├── movie_model.dart     # Movie data model
│   └── match_model.dart     # Match data model
├── providers/
│   ├── auth_provider.dart   # Authentication providers
│   ├── room_provider.dart   # Room management providers
│   └── movie_provider.dart  # Movie data providers
├── screens/
│   ├── splash_screen.dart   # Splash screen with animation
│   ├── login_screen.dart    # Login/signup screen
│   ├── home_screen.dart     # Create/join room screen
│   ├── swipe_screen.dart    # Main swiping screen
│   └── match_screen.dart    # Match celebration dialog
├── services/
│   ├── auth_service.dart    # Firebase Auth service
│   ├── firestore_service.dart # Firestore operations
│   └── tmdb_service.dart    # TMDB API service
├── widgets/
│   ├── movie_card.dart      # Movie card widget
│   ├── swipeable_card.dart  # Swipeable card with gestures
│   ├── action_buttons.dart  # Like/dislike buttons
│   └── loading_skeleton.dart # Loading skeleton UI
└── main.dart                # App entry point
```

## Setup Instructions 🚀

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Firebase account
- TMDB API account
- Android Studio / Xcode (for running on devices)

### 1. Clone the Repository

```bash
git clone <repository-url>
cd moviematch
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

#### Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" and follow the setup wizard
3. Enable Google Analytics (optional)

#### Enable Authentication

1. In Firebase Console, go to **Authentication**
2. Click "Get started"
3. Enable **Anonymous** authentication
4. Enable **Google** sign-in provider
5. Add your app's SHA-1 fingerprint for Google Sign-In (Android only)

#### Create Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click "Create database"
3. Choose **Production mode** or **Test mode**
4. Select a location for your database

#### Firestore Security Rules

Add these security rules in Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Rooms collection
    match /rooms/{roomId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null &&
                       request.auth.uid in resource.data.userIds;
    }

    // Likes collection
    match /likes/{likeId} {
      allow read, write: if request.auth != null;
    }

    // Matches collection
    match /matches/{matchId} {
      allow read: if request.auth != null &&
                     request.auth.uid in resource.data.userIds;
      allow create: if request.auth != null;
    }
  }
}
```

#### Add Firebase to Your Flutter App

##### Android Setup

1. In Firebase Console, add an Android app
2. Register your app with package name: `com.example.moviematch` (or your chosen package)
3. Download `google-services.json`
4. Place it in `android/app/` directory

##### iOS Setup

1. In Firebase Console, add an iOS app
2. Register your app with bundle ID
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/` directory

##### FlutterFire CLI (Recommended)

Alternatively, use FlutterFire CLI for automatic setup:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

### 4. TMDB API Setup

#### Get Your API Key

1. Go to [TMDB](https://www.themoviedb.org/)
2. Create an account and verify your email
3. Go to Settings → API
4. Request an API key (choose "Developer" option)
5. Fill out the form and accept terms
6. Copy your API key

#### Add API Key to App

Open `lib/core/constants.dart` and replace the placeholder:

```dart
static const String tmdbApiKey = 'YOUR_TMDB_API_KEY_HERE';
```

### 5. Google Sign-In Setup (Android)

For Google Sign-In to work on Android, you need to add your SHA-1 fingerprint:

#### Get SHA-1 Fingerprint

```bash
# Debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# For release, use your release keystore
keytool -list -v -keystore /path/to/your/keystore -alias your-alias-name
```

#### Add to Firebase

1. Copy the SHA-1 fingerprint
2. In Firebase Console → Project Settings → Your Android App
3. Add the SHA-1 fingerprint
4. Download the updated `google-services.json`

### 6. Run the App

#### On Android

```bash
flutter run -d android
```

#### On iOS

```bash
flutter run -d ios
```

#### Build for Production

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## How to Use 📱

1. **Launch the App**: Opens with a splash screen
2. **Login**: Choose "Continue with Google" or "Continue as Guest"
3. **Create or Join Room**:
   - **Create**: Generates a 6-character room code
   - **Join**: Enter a friend's room code
4. **Swipe Movies**:
   - Swipe right or tap ❤️ to LIKE
   - Swipe left or tap ✖️ to DISLIKE
5. **Get Matches**: When both users like the same movie, you'll see a match celebration!

## Firestore Data Structure 💾

### Collections

#### `users/`
```json
{
  "userId": "string",
  "email": "string?",
  "displayName": "string?",
  "photoUrl": "string?",
  "createdAt": "timestamp",
  "isAnonymous": "boolean"
}
```

#### `rooms/`
```json
{
  "roomId": "string",
  "roomCode": "string (6 chars)",
  "creatorId": "string",
  "partnerId": "string?",
  "status": "waiting | active | completed",
  "createdAt": "timestamp",
  "updatedAt": "timestamp?",
  "userIds": ["string"]
}
```

#### `likes/`
```json
{
  "likeId": "string",
  "roomId": "string",
  "userId": "string",
  "movieId": "number",
  "likedAt": "timestamp"
}
```

#### `matches/`
```json
{
  "matchId": "string",
  "roomId": "string",
  "movieId": "number",
  "movieTitle": "string",
  "moviePosterPath": "string?",
  "userIds": ["string"],
  "matchedAt": "timestamp"
}
```

## API Reference 🔌

### TMDB API Endpoints Used

- `GET /movie/popular` - Get popular movies
- `GET /movie/top_rated` - Get top rated movies
- `GET /movie/now_playing` - Get now playing movies
- `GET /discover/movie` - Discover movies by genre

## Troubleshooting 🔧

### Common Issues

#### Firebase Authentication Error
- Ensure Firebase is properly configured
- Check if SHA-1 fingerprint is added (Android)
- Verify Google Sign-In is enabled in Firebase Console

#### Movies Not Loading
- Check if TMDB API key is correct
- Verify internet connection
- Check for API rate limits

#### Google Sign-In Not Working
- Add SHA-1 fingerprint to Firebase
- Download updated `google-services.json`
- Rebuild the app

#### Build Errors
```bash
# Clean build
flutter clean
flutter pub get
flutter run
```

## Features Roadmap 🗺️

- [ ] Add movie filters (genre, year, rating)
- [ ] Show streaming availability
- [ ] Add chat functionality in rooms
- [ ] Save favorite matches
- [ ] Export match list
- [ ] Add movie trailers
- [ ] Social sharing
- [ ] Push notifications for matches

## Contributing 🤝

Contributions are welcome! Please feel free to submit a Pull Request.

## License 📄

This project is licensed under the MIT License.

## Credits 🙏

- Movie data provided by [TMDB](https://www.themoviedb.org/)
- Firebase by Google
- Flutter by Google

## Support 💬

For issues and questions, please open an issue on GitHub or contact the maintainers.

---

**Enjoy matching movies with your friends! 🎬🍿**
