import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final bool isAnonymous;

  UserModel({
    required this.userId,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.isAnonymous,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'isAnonymous': isAnonymous,
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      email: map['email'],
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isAnonymous: map['isAnonymous'] ?? false,
    );
  }

  // Create from Firebase Auth User
  factory UserModel.fromFirebaseUser(dynamic firebaseUser) {
    return UserModel(
      userId: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      createdAt: DateTime.now(),
      isAnonymous: firebaseUser.isAnonymous,
    );
  }

  UserModel copyWith({
    String? userId,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    bool? isAnonymous,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }
}
