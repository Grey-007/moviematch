import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../core/constants.dart';
import '../models/user_model.dart';
import '../models/room_model.dart';
import '../models/match_model.dart';
import '../models/movie_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> _userRoomsRef(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection('rooms');
  }

  CollectionReference<Map<String, dynamic>> _roomLikesRef(String roomId) {
    return _firestore
        .collection(AppConstants.roomsCollection)
        .doc(roomId)
        .collection('likes');
  }

  CollectionReference<Map<String, dynamic>> _roomMatchesRef(String roomId) {
    return _firestore
        .collection(AppConstants.roomsCollection)
        .doc(roomId)
        .collection('matches');
  }

  Future<void> _addRoomToUser(String userId, RoomModel room) async {
    await _userRoomsRef(userId).doc(room.roomId).set({
      'roomId': room.roomId,
      'roomCode': room.roomCode,
      'status': room.status.name,
      'joinedAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Future<void> _syncRoomToUsers(RoomModel room) async {
    final futures = room.userIds.map((uid) => _addRoomToUser(uid, room));
    await Future.wait(futures);
  }

  Future<void> _removeRoomFromUser(String userId, String roomId) async {
    await _userRoomsRef(userId).doc(roomId).delete();
  }

  Future<void> _deleteCollection(
    CollectionReference<Map<String, dynamic>> collectionRef,
  ) async {
    while (true) {
      final snapshot = await collectionRef.limit(200).get();
      if (snapshot.docs.isEmpty) break;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  // ==================== USER OPERATIONS ====================

  // Create or update user
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.userId)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      print('Error creating user: $e');
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }

  // Get user by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // ==================== ROOM OPERATIONS ====================

  // Generate unique 6-character room code
  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(
      AppConstants.roomCodeLength,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  // Create a new room
  Future<RoomModel> createRoom(String creatorId) async {
    try {
      final roomId = _uuid.v4();
      final roomCode = _generateRoomCode();

      // Check if room code already exists (very unlikely but safe)
      final existingRoom = await getRoomByCode(roomCode);
      if (existingRoom != null) {
        // Recursively generate new code if collision
        return createRoom(creatorId);
      }

      final room = RoomModel(
        roomId: roomId,
        roomCode: roomCode,
        creatorId: creatorId,
        status: RoomStatus.waiting,
        createdAt: DateTime.now(),
        userIds: [creatorId],
      );

      await _firestore
          .collection(AppConstants.roomsCollection)
          .doc(roomId)
          .set(room.toMap());

      await _addRoomToUser(creatorId, room);

      return room;
    } catch (e) {
      print('Error creating room: $e');
      throw Exception('Failed to create room: ${e.toString()}');
    }
  }

  // Get room by code
  Future<RoomModel?> getRoomByCode(String roomCode) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.roomsCollection)
          .where('roomCode', isEqualTo: roomCode.toUpperCase())
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return RoomModel.fromMap(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      print('Error getting room by code: $e');
      return null;
    }
  }

  // Get room by ID
  Future<RoomModel?> getRoom(String roomId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.roomsCollection)
          .doc(roomId)
          .get();

      if (doc.exists && doc.data() != null) {
        return RoomModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting room: $e');
      return null;
    }
  }

  // Join an existing room
  Future<RoomModel?> joinRoom(String roomCode, String userId) async {
    try {
      final room = await getRoomByCode(roomCode);

      if (room == null) {
        throw Exception('Room not found');
      }

      if (room.userIds.contains(userId)) {
        // Idempotent join: allow users to re-open the same persistent room.
        return room;
      }

      if (room.isFull) {
        throw Exception('Room is full');
      }

      // Update room with new user
      final updatedUserIds = [...room.userIds, userId];
      await _firestore
          .collection(AppConstants.roomsCollection)
          .doc(room.roomId)
          .update({
        'userIds': updatedUserIds,
        'partnerId': userId,
        'status': RoomStatus.active.name,
        'updatedAt': Timestamp.now(),
      });

      final updatedRoom = room.copyWith(
        userIds: updatedUserIds,
        partnerId: userId,
        status: RoomStatus.active,
        updatedAt: DateTime.now(),
      );

      await _syncRoomToUsers(updatedRoom);
      return updatedRoom;
    } catch (e) {
      print('Error joining room: $e');
      throw Exception('Failed to join room: ${e.toString()}');
    }
  }

  // Stream room updates
  Stream<RoomModel?> streamRoom(String roomId) {
    return _firestore
        .collection(AppConstants.roomsCollection)
        .doc(roomId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return RoomModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  Future<void> leaveRoom(String roomId, String userId) async {
    try {
      final roomRef = _firestore.collection(AppConstants.roomsCollection).doc(roomId);
      final roomDoc = await roomRef.get();

      // Room already deleted - only cleanup user reference.
      if (!roomDoc.exists || roomDoc.data() == null) {
        await _removeRoomFromUser(userId, roomId);
        return;
      }

      final room = RoomModel.fromMap(roomDoc.data()!);
      await _removeRoomFromUser(userId, roomId);

      final updatedUserIds = room.userIds.where((id) => id != userId).toList();

      if (updatedUserIds.isEmpty) {
        await deleteRoom(roomId);
        return;
      }

      final nextStatus =
          updatedUserIds.length == 2 ? RoomStatus.active : RoomStatus.waiting;
      final nextCreatorId =
          room.creatorId == userId ? updatedUserIds.first : room.creatorId;
      String? nextPartnerId;
      if (updatedUserIds.length == 2) {
        nextPartnerId = updatedUserIds.firstWhere(
          (id) => id != nextCreatorId,
          orElse: () => '',
        );
        if (nextPartnerId.isEmpty) {
          nextPartnerId = null;
        }
      }

      await roomRef.update({
        'userIds': updatedUserIds,
        'creatorId': nextCreatorId,
        'partnerId': nextPartnerId,
        'status': nextStatus.name,
        'updatedAt': Timestamp.now(),
        'isReady': updatedUserIds.length == 2,
      });

      final updatedRoom = room.copyWith(
        creatorId: nextCreatorId,
        userIds: updatedUserIds,
        partnerId: nextPartnerId,
        status: nextStatus,
        updatedAt: DateTime.now(),
      );
      await _syncRoomToUsers(updatedRoom);
    } catch (e) {
      print('Error leaving room: $e');
      throw Exception('Failed to leave room: ${e.toString()}');
    }
  }

  Future<void> deleteRoom(String roomId) async {
    try {
      final roomRef = _firestore.collection(AppConstants.roomsCollection).doc(roomId);
      final roomDoc = await roomRef.get();

      if (!roomDoc.exists || roomDoc.data() == null) {
        return;
      }

      final room = RoomModel.fromMap(roomDoc.data()!);

      // Remove room references from all known users in room.
      final removeRefs = room.userIds.map((uid) => _removeRoomFromUser(uid, roomId));
      await Future.wait(removeRefs);

      // Explicitly delete subcollections.
      await _deleteCollection(_roomLikesRef(roomId));
      await _deleteCollection(_roomMatchesRef(roomId));

      // Delete main room document.
      await roomRef.delete();
    } catch (e) {
      print('Error deleting room: $e');
      throw Exception('Failed to delete room: ${e.toString()}');
    }
  }

  // ==================== LIKE OPERATIONS ====================

  // Save a like
  Future<void> saveLike(String roomId, String userId, MovieModel movie) async {
    try {
      await _roomLikesRef(roomId).doc(userId).set({
        'userId': userId,
        'movieIds': FieldValue.arrayUnion([movie.id]),
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));

      // Check for match
      await _checkForMatch(roomId, userId, movie);
    } catch (e) {
      print('Error saving like: $e');
      throw Exception('Failed to save like: ${e.toString()}');
    }
  }

  // Check if both users liked the same movie
  Future<void> _checkForMatch(
      String roomId, String userId, MovieModel movie) async {
    try {
      // Get the room to find the other user
      final room = await getRoom(roomId);
      if (room == null || !room.isReady) return;

      // Find the other user ID
      final otherUserId =
          room.userIds.firstWhere((id) => id != userId, orElse: () => '');
      if (otherUserId.isEmpty) return;

      // Check if other user also liked this movie
      final otherUserLikeDoc = await _roomLikesRef(roomId).doc(otherUserId).get();
      final otherUserMovieIds =
          List<int>.from(otherUserLikeDoc.data()?['movieIds'] ?? const <int>[]);

      if (otherUserMovieIds.contains(movie.id)) {
        // It's a match! Create match document
        await _createMatch(roomId, room.userIds, movie);
      }
    } catch (e) {
      print('Error checking for match: $e');
    }
  }

  // Create a match
  Future<void> _createMatch(
      String roomId, List<String> userIds, MovieModel movie) async {
    try {
      final matchId = _uuid.v4();
      final match = MatchModel(
        matchId: matchId,
        roomId: roomId,
        movieId: movie.id,
        movieTitle: movie.title,
        moviePosterPath: movie.posterPath,
        userIds: userIds,
        matchedAt: DateTime.now(),
      );

      final existingMatch = await _roomMatchesRef(roomId)
          .where('movieId', isEqualTo: movie.id)
          .limit(1)
          .get();
      if (existingMatch.docs.isNotEmpty) {
        return;
      }

      await _roomMatchesRef(roomId).doc(matchId).set(match.toMap());
    } catch (e) {
      print('Error creating match: $e');
    }
  }

  // Get all matches for a room
  Future<List<MatchModel>> getMatches(String roomId) async {
    try {
      final querySnapshot = await _roomMatchesRef(roomId)
          .orderBy('matchedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => MatchModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting matches: $e');
      return [];
    }
  }

  // Stream matches for a room
  Stream<List<MatchModel>> streamMatches(String roomId) {
    return _roomMatchesRef(roomId)
        .orderBy('matchedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MatchModel.fromMap(doc.data()))
          .toList();
    });
  }

  // Get user's liked movie IDs in a room
  Future<List<int>> getUserLikedMovies(String roomId, String userId) async {
    try {
      final doc = await _roomLikesRef(roomId).doc(userId).get();
      if (!doc.exists || doc.data() == null) return [];
      return List<int>.from(doc.data()!['movieIds'] ?? const <int>[]);
    } catch (e) {
      print('Error getting user liked movies: $e');
      return [];
    }
  }

  Stream<List<RoomModel>> streamUserRooms(String userId) {
    return _userRoomsRef(userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) return <RoomModel>[];

      final futures = snapshot.docs.map((doc) => getRoom(doc.id));
      final rooms = await Future.wait(futures);
      final filtered = rooms.whereType<RoomModel>().toList();
      filtered.sort((a, b) {
        final aUpdated = a.updatedAt ?? a.createdAt;
        final bUpdated = b.updatedAt ?? b.createdAt;
        return bUpdated.compareTo(aUpdated);
      });
      return filtered;
    });
  }

  Stream<List<MatchModel>> streamUserMatches(String userId) {
    return _firestore
        .collectionGroup('matches')
        .where('userIds', arrayContains: userId)
        .orderBy('matchedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MatchModel.fromMap(doc.data()))
          .toList();
    });
  }
}
