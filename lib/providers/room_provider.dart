import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/room_model.dart';
import '../models/match_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

// Firestore service provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Current room ID state provider
final currentRoomIdProvider = StateProvider<String?>((ref) => null);

// Current room provider - streams room updates
final currentRoomProvider = StreamProvider.autoDispose<RoomModel?>((ref) {
  final roomId = ref.watch(currentRoomIdProvider);
  if (roomId == null) {
    return Stream.value(null);
  }

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.streamRoom(roomId);
});

// Create room provider
final createRoomProvider = FutureProvider.family<RoomModel, String>((ref, creatorId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.createRoom(creatorId);
});

// Join room provider
final joinRoomProvider = FutureProvider.family<RoomModel?, (String, String)>((ref, params) async {
  final (roomCode, userId) = params;
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.joinRoom(roomCode, userId);
});

final userRoomsProvider = StreamProvider.autoDispose<List<RoomModel>>((ref) {
  final authService = ref.watch(authServiceProvider);
  final userId = authService.currentUserId;
  if (userId == null) {
    return Stream.value([]);
  }
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.streamUserRooms(userId);
});

final userMatchesProvider = StreamProvider.autoDispose<List<MatchModel>>((ref) {
  final authService = ref.watch(authServiceProvider);
  final userId = authService.currentUserId;
  if (userId == null) {
    return Stream.value([]);
  }
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.streamUserMatches(userId);
});

// Get matches for current room
final roomMatchesProvider = StreamProvider.autoDispose<List<MatchModel>>((ref) {
  final roomId = ref.watch(currentRoomIdProvider);
  if (roomId == null) {
    return Stream.value([]);
  }

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.streamMatches(roomId);
});

// User's liked movies in current room
final userLikedMoviesProvider = FutureProvider.autoDispose<List<int>>((ref) async {
  final roomId = ref.watch(currentRoomIdProvider);
  final authService = ref.watch(authServiceProvider);
  final userId = authService.currentUserId;

  if (roomId == null || userId == null) {
    return [];
  }

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUserLikedMovies(roomId, userId);
});
