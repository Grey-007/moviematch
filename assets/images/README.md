# Images Directory

This directory is reserved for static image assets used in the app.

Currently, the app loads all movie images from TMDB API dynamically, so this directory is optional.

## Optional Assets You Can Add

### App Icon
- Add custom app icon here and reference in Android/iOS configs

### Placeholder Images
- `movie_placeholder.png` - Shown when movie poster fails to load
- `profile_placeholder.png` - Default user avatar

### Onboarding Images
- Images for tutorial/onboarding screens (if you add this feature)

### Background Images
- Decorative backgrounds for various screens

## Note

All movie posters, backdrops, and movie-related images are loaded from TMDB API and cached automatically by the `cached_network_image` package.

This directory is prepared for any custom static assets you want to add in the future.
