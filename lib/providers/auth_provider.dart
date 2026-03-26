import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Auth state provider - listens to Firebase auth changes
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current user provider
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.getCurrentUserModel();
});

// Sign in with Google
final signInWithGoogleProvider = FutureProvider.autoDispose<UserModel?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.signInWithGoogle();
});
