# MovieMatch - Architecture Documentation

## Overview

MovieMatch follows a **clean architecture** pattern with clear separation of concerns. The app uses **Riverpod** for state management and follows Flutter best practices.

## Architecture Layers

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (Screens, Widgets, UI Components)      │
└─────────────────────────────────────────┘
              ↕
┌─────────────────────────────────────────┐
│       State Management Layer            │
│      (Riverpod Providers)               │
└─────────────────────────────────────────┘
              ↕
┌─────────────────────────────────────────┐
│         Business Logic Layer            │
│         (Services, Models)              │
└─────────────────────────────────────────┘
              ↕
┌─────────────────────────────────────────┐
│          Data Layer                     │
│    (Firebase, TMDB API)                 │
└─────────────────────────────────────────┘
```

## Directory Structure

```
lib/
├── main.dart                    # App entry point
│
├── core/                        # Core app configuration
│   ├── constants.dart           # API keys, app constants
│   └── theme.dart               # Material 3 theme
│
├── models/                      # Data models
│   ├── user_model.dart          # User entity
│   ├── room_model.dart          # Room entity
│   ├── movie_model.dart         # Movie entity
│   └── match_model.dart         # Match & Like entities
│
├── providers/                   # Riverpod providers
│   ├── auth_provider.dart       # Authentication state
│   ├── room_provider.dart       # Room management
│   └── movie_provider.dart      # Movie data
│
├── screens/                     # Full-screen pages
│   ├── splash_screen.dart       # Initial loading
│   ├── login_screen.dart        # Authentication
│   ├── home_screen.dart         # Room creation/joining
│   ├── swipe_screen.dart        # Main swiping interface
│   └── match_screen.dart        # Match celebration
│
├── services/                    # Business logic services
│   ├── auth_service.dart        # Firebase Auth operations
│   ├── firestore_service.dart   # Firestore CRUD operations
│   └── tmdb_service.dart        # TMDB API calls
│
└── widgets/                     # Reusable UI components
    ├── movie_card.dart          # Movie display card
    ├── swipeable_card.dart      # Gesture-enabled card
    ├── action_buttons.dart      # Like/Dislike buttons
    └── loading_skeleton.dart    # Loading placeholders
```

## Data Flow

### 1. Authentication Flow

```
User Action (Login)
    ↓
LoginScreen
    ↓
AuthService.signInAnonymously() / signInWithGoogle()
    ↓
Firebase Authentication
    ↓
FirestoreService.createUser()
    ↓
authStateProvider (Riverpod)
    ↓
Navigation to HomeScreen
```

### 2. Room Creation Flow

```
User Action (Create Room)
    ↓
HomeScreen
    ↓
FirestoreService.createRoom()
    ↓
Generate 6-char code
    ↓
Save to Firestore 'rooms' collection
    ↓
currentRoomIdProvider.state = roomId
    ↓
Navigation to SwipeScreen
```

### 3. Room Joining Flow

```
User Action (Enter Code)
    ↓
HomeScreen
    ↓
FirestoreService.joinRoom(code, userId)
    ↓
Query Firestore by roomCode
    ↓
Update room with new user
    ↓
Change status to 'active'
    ↓
currentRoomIdProvider.state = roomId
    ↓
Navigation to SwipeScreen
```

### 4. Movie Swiping Flow

```
App Load
    ↓
moviesListProvider
    ↓
TmdbService.getMixedMovies()
    ↓
TMDB API Request
    ↓
Parse to List<MovieModel>
    ↓
Display in SwipeableCard
    ↓
User Swipes
    ↓
If Like: FirestoreService.saveLike()
    ↓
Check for Match: _checkForMatch()
    ↓
If Match: Create match document
    ↓
roomMatchesProvider detects new match
    ↓
Show MatchScreen dialog
```

### 5. Match Detection Flow

```
User A likes Movie X
    ↓
Save to 'likes' collection
    ↓
Query 'likes' for same roomId + movieId
    ↓
If User B also liked Movie X
    ↓
Create document in 'matches' collection
    ↓
roomMatchesProvider stream emits new data
    ↓
SwipeScreen detects match via listener
    ↓
Show MatchScreen with animation
```

## State Management

### Riverpod Providers

#### 1. Auth Providers (`auth_provider.dart`)

```dart
// Service instance
authServiceProvider: Provider<AuthService>

// Stream of auth changes
authStateProvider: StreamProvider<User?>

// Current user data
currentUserProvider: FutureProvider<UserModel?>
```

#### 2. Room Providers (`room_provider.dart`)

```dart
// Service instance
firestoreServiceProvider: Provider<FirestoreService>

// Current room ID (state)
currentRoomIdProvider: StateProvider<String?>

// Stream of current room
currentRoomProvider: StreamProvider<RoomModel?>

// Stream of matches
roomMatchesProvider: StreamProvider<List<MatchModel>>

// User's liked movies
userLikedMoviesProvider: FutureProvider<List<int>>
```

#### 3. Movie Providers (`movie_provider.dart`)

```dart
// Service instance
tmdbServiceProvider: Provider<TmdbService>

// Movies list with StateNotifier
moviesListProvider: StateNotifierProvider<MoviesNotifier, AsyncValue<List<MovieModel>>>
```

### StateNotifier Pattern

`MoviesNotifier` manages movie list state:

```dart
class MoviesNotifier extends StateNotifier<AsyncValue<List<MovieModel>>> {
  // Load initial movies
  loadMovies()

  // Load more when running low
  loadMoreMovies()

  // Remove swiped movie
  removeMovie(movieId)

  // Refresh list
  refresh()
}
```

## Services Layer

### 1. AuthService

Handles Firebase Authentication:

- `signInAnonymously()`: Anonymous auth
- `signInWithGoogle()`: Google Sign-In
- `signOut()`: Sign out user
- `getCurrentUserModel()`: Get user from Firestore
- `authStateChanges`: Stream of auth changes

### 2. FirestoreService

Manages Firestore operations:

**User Operations:**
- `createUser(user)`: Create/update user document
- `getUser(userId)`: Fetch user by ID

**Room Operations:**
- `createRoom(creatorId)`: Create new room
- `getRoomByCode(code)`: Find room by code
- `joinRoom(code, userId)`: Join existing room
- `streamRoom(roomId)`: Real-time room updates

**Like Operations:**
- `saveLike(roomId, userId, movie)`: Save a like
- `_checkForMatch()`: Check if both users liked
- `_createMatch()`: Create match document
- `getUserLikedMovies()`: Get user's likes

**Match Operations:**
- `getMatches(roomId)`: Get all matches
- `streamMatches(roomId)`: Real-time matches

### 3. TmdbService

Handles TMDB API calls:

- `getPopularMovies()`: Fetch popular movies
- `getTopRatedMovies()`: Fetch top rated
- `getNowPlayingMovies()`: Fetch now playing
- `getMixedMovies()`: Combine popular + top rated
- `discoverMoviesByGenre()`: Filter by genre
- `searchMovies()`: Search functionality
- `getMovieDetails()`: Get specific movie

## Models

### 1. UserModel

```dart
{
  userId: String
  email: String?
  displayName: String?
  photoUrl: String?
  createdAt: DateTime
  isAnonymous: bool
}
```

### 2. RoomModel

```dart
{
  roomId: String
  roomCode: String (6 chars)
  creatorId: String
  partnerId: String?
  status: RoomStatus (waiting/active/completed)
  createdAt: DateTime
  updatedAt: DateTime?
  userIds: List<String>
}
```

### 3. MovieModel

```dart
{
  id: int
  title: String
  overview: String?
  posterPath: String?
  backdropPath: String?
  voteAverage: double
  voteCount: int
  releaseDate: String?
  genreIds: List<int>
  popularity: double
  originalLanguage: String?
}
```

### 4. MatchModel & LikeModel

```dart
// Match
{
  matchId: String
  roomId: String
  movieId: int
  movieTitle: String
  moviePosterPath: String?
  userIds: List<String>
  matchedAt: DateTime
}

// Like
{
  likeId: String
  roomId: String
  userId: String
  movieId: int
  likedAt: DateTime
}
```

## Key Features Implementation

### 1. Swipe Gesture

**SwipeableCard Widget:**

- Uses `GestureDetector` for pan gestures
- Calculates rotation angle based on drag
- Shows like/dislike indicators with opacity
- Animates card off-screen on completion
- Threshold: 30% of screen width

### 2. Real-time Updates

Uses Firestore streams:

```dart
// Listen to room changes
streamRoom(roomId).listen((room) {
  // Update UI when room status changes
});

// Listen to new matches
streamMatches(roomId).listen((matches) {
  // Show match dialog when new match
});
```

### 3. Match Detection Algorithm

```dart
1. User likes movie → Save to 'likes' collection
2. Query 'likes' for same (roomId + movieId + otherUserId)
3. If found → Both users liked it
4. Create document in 'matches' collection
5. Stream notifies both users
```

### 4. Image Caching

Uses `cached_network_image`:

- Automatic caching of movie posters
- Placeholder while loading
- Error widget on failure
- Memory and disk cache

### 5. Haptic Feedback

```dart
// Check device capability
if (await Vibration.hasVibrator() ?? false) {
  Vibration.vibrate(duration: 50);
}

// On match
HapticFeedback.heavyImpact();
```

## Performance Optimizations

### 1. Lazy Loading

- Load 20 movies initially
- Auto-load more when < 5 remaining
- Prevents memory overflow

### 2. Image Optimization

- Use w500 size for cards (not original)
- Lazy load images
- Cache network images

### 3. Firestore Queries

- Use indexes for compound queries
- Limit query results
- Use snapshots only when needed

### 4. Widget Optimization

- Use `const` constructors where possible
- Avoid rebuilding entire tree
- Use `AutoDisposeProvider` for cleanup

## Security

### Firestore Rules

```javascript
// Users: Only read/write own data
allow read, write: if request.auth.uid == userId

// Rooms: Authenticated users can create/read
allow read: if request.auth != null
allow update: if request.auth.uid in resource.data.userIds

// Likes: Authenticated users can manage
allow read, write: if request.auth != null

// Matches: Users in match can read
allow read: if request.auth.uid in resource.data.userIds
```

### Best Practices

- Never expose API keys in code (use constants file)
- Validate user input (room codes)
- Check authentication state before operations
- Use Firebase Security Rules
- Sanitize user-generated content

## Testing Strategy

### Unit Tests

- Test models (toMap/fromMap)
- Test service methods
- Test business logic

### Widget Tests

- Test individual widgets
- Test user interactions
- Test navigation

### Integration Tests

- Test full user flows
- Test Firebase integration
- Test API integration

## Error Handling

### Network Errors

```dart
try {
  final movies = await tmdbService.getPopularMovies();
} catch (e) {
  // Show error UI
  // Log error
  // Provide retry option
}
```

### Firebase Errors

```dart
try {
  await firestoreService.saveLike();
} catch (e) {
  // User-friendly error message
  // Log to analytics
  // Graceful degradation
}
```

## Future Enhancements

### Scalability

- Add pagination to Firestore queries
- Implement server-side matching logic
- Add Cloud Functions for complex operations
- Implement rate limiting

### Features

- Add movie filtering
- Show streaming platforms
- Add user profiles
- Implement chat
- Add push notifications
- Export match lists

### Performance

- Implement image preloading
- Add offline support
- Optimize bundle size
- Use Flutter Web for wider reach

## Dependencies

### Core
- `flutter_riverpod`: State management
- `firebase_core`: Firebase initialization
- `firebase_auth`: Authentication
- `cloud_firestore`: Database
- `google_sign_in`: Google auth

### UI
- `cached_network_image`: Image caching
- `shimmer`: Loading skeletons
- `flutter_animate`: Animations
- `lottie`: Lottie animations

### HTTP
- `http`: HTTP client
- `dio`: Advanced HTTP client

### Utilities
- `uuid`: Generate unique IDs
- `intl`: Internationalization
- `vibration`: Haptic feedback

## Conclusion

MovieMatch is built with:
- ✅ Clean architecture
- ✅ Separation of concerns
- ✅ Reactive state management
- ✅ Real-time updates
- ✅ Smooth animations
- ✅ Production-ready code

The architecture is designed to be:
- **Maintainable**: Clear structure, single responsibility
- **Testable**: Separated layers, dependency injection
- **Scalable**: Can handle growth in users and features
- **Performant**: Optimized queries, lazy loading, caching
