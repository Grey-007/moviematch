import 'package:cloud_firestore/cloud_firestore.dart';

class MatchModel {
  final String matchId;
  final String roomId;
  final int movieId;
  final String movieTitle;
  final String? moviePosterPath;
  final List<String> userIds;
  final DateTime matchedAt;

  MatchModel({
    required this.matchId,
    required this.roomId,
    required this.movieId,
    required this.movieTitle,
    this.moviePosterPath,
    required this.userIds,
    required this.matchedAt,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'matchId': matchId,
      'roomId': roomId,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'moviePosterPath': moviePosterPath,
      'userIds': userIds,
      'matchedAt': Timestamp.fromDate(matchedAt),
    };
  }

  // Create from Firestore document
  factory MatchModel.fromMap(Map<String, dynamic> map) {
    return MatchModel(
      matchId: map['matchId'] ?? '',
      roomId: map['roomId'] ?? '',
      movieId: map['movieId'] ?? 0,
      movieTitle: map['movieTitle'] ?? '',
      moviePosterPath: map['moviePosterPath'],
      userIds: List<String>.from(map['userIds'] ?? []),
      matchedAt: (map['matchedAt'] as Timestamp).toDate(),
    );
  }

  MatchModel copyWith({
    String? matchId,
    String? roomId,
    int? movieId,
    String? movieTitle,
    String? moviePosterPath,
    List<String>? userIds,
    DateTime? matchedAt,
  }) {
    return MatchModel(
      matchId: matchId ?? this.matchId,
      roomId: roomId ?? this.roomId,
      movieId: movieId ?? this.movieId,
      movieTitle: movieTitle ?? this.movieTitle,
      moviePosterPath: moviePosterPath ?? this.moviePosterPath,
      userIds: userIds ?? this.userIds,
      matchedAt: matchedAt ?? this.matchedAt,
    );
  }
}

// Model for storing individual likes
class LikeModel {
  final String likeId;
  final String roomId;
  final String userId;
  final int movieId;
  final DateTime likedAt;

  LikeModel({
    required this.likeId,
    required this.roomId,
    required this.userId,
    required this.movieId,
    required this.likedAt,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'likeId': likeId,
      'roomId': roomId,
      'userId': userId,
      'movieId': movieId,
      'likedAt': Timestamp.fromDate(likedAt),
    };
  }

  // Create from Firestore document
  factory LikeModel.fromMap(Map<String, dynamic> map) {
    return LikeModel(
      likeId: map['likeId'] ?? '',
      roomId: map['roomId'] ?? '',
      userId: map['userId'] ?? '',
      movieId: map['movieId'] ?? 0,
      likedAt: (map['likedAt'] as Timestamp).toDate(),
    );
  }
}
