# Fonts Directory

This directory should contain the Poppins font files referenced in `pubspec.yaml`:

- `Poppins-Regular.ttf`
- `Poppins-Medium.ttf`
- `Poppins-SemiBold.ttf`
- `Poppins-Bold.ttf`

## How to Get Poppins Font

### Option 1: Google Fonts (Recommended)

1. Go to [Google Fonts - Poppins](https://fonts.google.com/specimen/Poppins)
2. Click "Download family"
3. Extract the zip file
4. Copy the following files from the `static` folder to this directory:
   - `Poppins-Regular.ttf`
   - `Poppins-Medium.ttf`
   - `Poppins-SemiBold.ttf`
   - `Poppins-Bold.ttf`

### Option 2: Use System Font (Temporary)

If you want to test the app without custom fonts, you can:

1. Remove the `fonts` section from `pubspec.yaml`
2. Remove `fontFamily: 'Poppins'` references from `lib/core/theme.dart`
3. The app will use the system default font

### Option 3: Alternative Font

You can use any font family you prefer by:

1. Adding your font files to this directory
2. Updating the font references in `pubspec.yaml`
3. Updating the `fontFamily` in `lib/core/theme.dart`

## Note

The app will still work without these fonts, but the UI may look slightly different.
For production, it's recommended to include the proper fonts.
