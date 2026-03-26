import 'package:cloud_firestore/cloud_firestore.dart';

enum RoomStatus {
  waiting, // Waiting for second user to join
  active, // Both users joined, ready to swipe
  completed, // Session ended
}

class RoomModel {
  final String roomId;
  final String roomCode;
  final String creatorId;
  final String? partnerId;
  final RoomStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> userIds;

  RoomModel({
    required this.roomId,
    required this.roomCode,
    required this.creatorId,
    this.partnerId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.userIds,
  });

  // Check if room is full
  bool get isFull => userIds.length >= 2;

  // Check if room is ready (has 2 users)
  bool get isReady => userIds.length == 2 && status == RoomStatus.active;

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'roomCode': roomCode,
      'creatorId': creatorId,
      'partnerId': partnerId,
      'status': status.name,
      'isReady': isReady,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'userIds': userIds,
    };
  }

  // Create from Firestore document
  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      roomId: map['roomId'] ?? '',
      roomCode: map['roomCode'] ?? '',
      creatorId: map['creatorId'] ?? '',
      partnerId: map['partnerId'],
      status: _statusFromString(map['status'] ?? 'waiting'),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      userIds: List<String>.from(map['userIds'] ?? []),
    );
  }

  // Helper to convert string to RoomStatus enum
  static RoomStatus _statusFromString(String status) {
    switch (status) {
      case 'waiting':
        return RoomStatus.waiting;
      case 'active':
        return RoomStatus.active;
      case 'completed':
        return RoomStatus.completed;
      default:
        return RoomStatus.waiting;
    }
  }

  RoomModel copyWith({
    String? roomId,
    String? roomCode,
    String? creatorId,
    String? partnerId,
    RoomStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? userIds,
  }) {
    return RoomModel(
      roomId: roomId ?? this.roomId,
      roomCode: roomCode ?? this.roomCode,
      creatorId: creatorId ?? this.creatorId,
      partnerId: partnerId ?? this.partnerId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userIds: userIds ?? this.userIds,
    );
  }
}
