import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential result =
          await _auth.signInWithCredential(credential);
      final User? user = result.user;

      if (user != null) {
        final userModel = UserModel.fromFirebaseUser(user);
        // Save or update user in Firestore
        await _firestoreService.createUser(userModel);
        return userModel;
      }
      return null;
    } catch (e) {
      print('Error signing in with Google: $e');
      throw Exception('Failed to sign in with Google: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Error signing out: $e');
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  // Get current user model from Firestore
  Future<UserModel?> getCurrentUserModel() async {
    try {
      final User? user = currentUser;
      if (user == null) return null;

      return await _firestoreService.getUser(user.uid);
    } catch (e) {
      print('Error getting current user model: $e');
      return null;
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Convert Firebase User to UserModel
  UserModel? getUserModel() {
    final User? user = currentUser;
    if (user == null) return null;
    return UserModel.fromFirebaseUser(user);
  }
}
