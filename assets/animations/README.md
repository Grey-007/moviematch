# Animations Directory

This directory is reserved for Lottie animation files (.json) used in the app.

## Current Animations

The app currently uses built-in Flutter animations via the `flutter_animate` package and doesn't require external Lottie files.

## Optional Lottie Animations You Can Add

If you want to enhance the app with Lottie animations:

### Match Animation
- `match_celebration.json` - Play when users match on a movie
- Download from [LottieFiles](https://lottiefiles.com/)

### Loading Animations
- `loading_movies.json` - Show while fetching movies
- `connecting.json` - Show while connecting to Firebase

### Empty State Animations
- `no_movies.json` - Show when movie list is empty
- `no_matches.json` - Show when no matches yet

## How to Use Lottie Animations

1. Download .json animation from [LottieFiles](https://lottiefiles.com/)
2. Place the .json file in this directory
3. Use in your Flutter code:

```dart
import 'package:lottie/lottie.dart';

Lottie.asset('assets/animations/your_animation.json')
```

## Note

The `lottie` package is already included in `pubspec.yaml`, so you can start using Lottie animations immediately by adding files here.

Current animations in the app are handled by:
- `flutter_animate` package for text and widget animations
- Custom Flutter animations for swipe gestures
- Material 3 built-in transitions
