import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/room_model.dart';
import '../providers/auth_provider.dart';
import '../providers/room_provider.dart';
import '../core/theme.dart';
import 'matches_screen.dart';
import 'swipe_screen.dart';
import 'login_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _roomCodeController = TextEditingController();
  bool _isCreatingRoom = false;
  bool _isJoiningRoom = false;
  int _selectedTab = 0;

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    final authService = ref.read(authServiceProvider);
    final userId = authService.currentUserId;

    if (userId == null) return;

    setState(() => _isCreatingRoom = true);

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final room = await firestoreService.createRoom(userId);

      if (mounted) {
        // Set current room ID
        ref.read(currentRoomIdProvider.notifier).state = room.roomId;

        // Navigate to swipe screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SwipeScreen(room: room),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create room: ${e.toString()}'),
            backgroundColor: AppTheme.dislikeColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingRoom = false);
      }
    }
  }

  Future<void> _joinRoom() async {
    final roomCode = _roomCodeController.text.trim().toUpperCase();

    if (roomCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a room code'),
          backgroundColor: AppTheme.dislikeColor,
        ),
      );
      return;
    }

    final authService = ref.read(authServiceProvider);
    final userId = authService.currentUserId;

    if (userId == null) return;

    setState(() => _isJoiningRoom = true);

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final room = await firestoreService.joinRoom(roomCode, userId);

      if (mounted && room != null) {
        // Set current room ID
        ref.read(currentRoomIdProvider.notifier).state = room.roomId;

        // Navigate to swipe screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SwipeScreen(room: room),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: Failed to join room: Exception: ', '')),
            backgroundColor: AppTheme.dislikeColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isJoiningRoom = false);
      }
    }
  }

  Future<void> _signOut() async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign out: ${e.toString()}'),
            backgroundColor: AppTheme.dislikeColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final userRoomsAsync = ref.watch(userRoomsProvider);

    final user = authState.valueOrNull;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_selectedTab == 0 ? 'MovieMatch' : 'Matches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SafeArea(
        child: _selectedTab == 0
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    authState.when(
                      data: (user) {
                        final name = user?.displayName ?? 'Guest';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, $name',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create or join a room to start swiping together.',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => const Text('Welcome!'),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isCreatingRoom || _isJoiningRoom
                                ? null
                                : _createRoom,
                            icon: _isCreatingRoom
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.add_circle_outline),
                            label: Text(
                              _isCreatingRoom ? 'Creating...' : 'Create Room',
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _roomCodeController,
                            decoration: const InputDecoration(
                              hintText: 'Enter Room Code',
                              prefixIcon:
                                  Icon(Icons.meeting_room, color: Colors.white70),
                              counterText: '',
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                            textCapitalization: TextCapitalization.characters,
                            maxLength: 6,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _isCreatingRoom || _isJoiningRoom
                                ? null
                                : _joinRoom,
                            icon: _isJoiningRoom
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.login),
                            label: Text(_isJoiningRoom ? 'Joining...' : 'Join Room'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Your Rooms',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    userRoomsAsync.when(
                      data: (rooms) {
                        if (rooms.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'No rooms yet. Create one to get started.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: rooms.map((room) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _RoomCard(
                                room: room,
                                onTap: () {
                                  ref.read(currentRoomIdProvider.notifier).state =
                                      room.roomId;
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => SwipeScreen(room: room),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          error.toString(),
                          style: TextStyle(color: Colors.white.withOpacity(0.8)),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const MatchesScreen(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Matches',
          ),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final RoomModel room;
  final VoidCallback onTap;

  const _RoomCard({
    required this.room,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final usersLabel = '${room.userIds.length}/2';
    final status = _statusText(room);
    final color = _statusColor(room);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.meeting_room, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Room ${room.roomCode}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$usersLabel users • $status',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }

  String _statusText(RoomModel room) {
    switch (room.status) {
      case RoomStatus.waiting:
        return 'Waiting';
      case RoomStatus.active:
        return room.isReady ? 'Ready' : 'Matching';
      case RoomStatus.completed:
        return 'Matching';
    }
  }

  Color _statusColor(RoomModel room) {
    switch (room.status) {
      case RoomStatus.waiting:
        return AppTheme.secondaryColor;
      case RoomStatus.active:
        return AppTheme.likeColor;
      case RoomStatus.completed:
        return AppTheme.primaryColor;
    }
  }
}
