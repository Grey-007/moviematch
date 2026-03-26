import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

import '../models/room_model.dart';
import '../models/movie_model.dart';
import '../models/match_model.dart';

import '../providers/auth_provider.dart';
import '../providers/room_provider.dart';
import '../providers/movie_provider.dart';

import '../widgets/swipeable_card.dart';
import '../widgets/action_buttons.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/movie_card.dart'; 

import '../core/theme.dart';
import 'match_screen.dart';
import 'home_screen.dart';

class SwipeScreen extends ConsumerStatefulWidget {
  final RoomModel room;

  const SwipeScreen({super.key, required this.room});

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> {
  final SwipeableCardController _swipeController = SwipeableCardController();
  String? _lastShownMatchId;
  bool _isMatchDialogOpen = false;
  double _dragProgress = 0;
  ProviderSubscription<AsyncValue<List<MatchModel>>>? _matchesSubscription;
  ProviderSubscription<AsyncValue<List<MovieModel>>>? _moviesSubscription;
  int _autoRetryAttempts = 0;
  bool _isRoomActionLoading = false;

  @override
  void initState() {
    super.initState();
    // Set current room ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentRoomIdProvider.notifier).state = widget.room.roomId;
    });

    // Listen for new matches once per screen lifecycle.
    _matchesSubscription = ref.listenManual(roomMatchesProvider, (previous, next) {
      next.whenData((matches) {
        if (matches.isEmpty) return;

        final latestMatch = matches.first;
        final hasNewMatch = latestMatch.matchId != _lastShownMatchId;

        if (!hasNewMatch || _isMatchDialogOpen || !mounted) return;

        _lastShownMatchId = latestMatch.matchId;
        _showMatchDialog(latestMatch.movieTitle, latestMatch.moviePosterPath);
      });
    });

    _moviesSubscription = ref.listenManual(moviesListProvider, (previous, next) async {
      next.when(
        data: (_) {
          _autoRetryAttempts = 0;
        },
        loading: () {},
        error: (_, __) async {
          if (_autoRetryAttempts >= 2) return;
          _autoRetryAttempts++;
          await Future.delayed(const Duration(milliseconds: 600));
          if (!mounted) return;
          ref.read(moviesListProvider.notifier).refresh();
        },
      );
    });
  }

  @override
  void dispose() {
    _matchesSubscription?.close();
    _moviesSubscription?.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SwipeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.room.roomId != widget.room.roomId) {
      ref.read(currentRoomIdProvider.notifier).state = widget.room.roomId;
      _lastShownMatchId = null;
      _isMatchDialogOpen = false;
    }
  }



  void _showMatchDialog(String movieTitle, String? posterPath) {
    if (_isMatchDialogOpen || !mounted) return;
    _isMatchDialogOpen = true;
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MatchScreen(
        movieTitle: movieTitle,
        posterPath: posterPath,
        onContinue: () {
          Navigator.of(context).pop();
        },
      ),
    ).then((_) {
      _isMatchDialogOpen = false;
    });
  }

  Future<void> _navigateToHome() async {
    if (!mounted) return;
    ref.read(currentRoomIdProvider.notifier).state = null;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  Future<void> _leaveRoom() async {
    final userId = ref.read(authServiceProvider).currentUserId;
    if (userId == null) return;

    try {
      if (mounted) {
        setState(() {
          _isRoomActionLoading = true;
        });
      }
      await ref.read(firestoreServiceProvider).leaveRoom(widget.room.roomId, userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You left the room')),
      );
      await _navigateToHome();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to leave room: $e'),
          backgroundColor: AppTheme.dislikeColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRoomActionLoading = false;
        });
      }
    }
  }

  Future<void> _deleteRoom() async {
    try {
      if (mounted) {
        setState(() {
          _isRoomActionLoading = true;
        });
      }
      await ref.read(firestoreServiceProvider).deleteRoom(widget.room.roomId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room deleted')),
      );
      await _navigateToHome();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete room: $e'),
          backgroundColor: AppTheme.dislikeColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRoomActionLoading = false;
        });
      }
    }
  }

  Future<void> _confirmLeaveRoom() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Room?'),
        content: const Text('Are you sure you want to leave this room?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (shouldLeave == true) {
      if (_isRoomActionLoading) return;
      await _leaveRoom();
    }
  }

  Future<void> _confirmDeleteRoom() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Room?'),
        content: const Text(
          'Are you sure? This will permanently delete the room, likes, and matches.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dislikeColor),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      if (_isRoomActionLoading) return;
      await _deleteRoom();
    }
  }

  Future<void> _handleSwipe(bool isLike, MovieModel movie) async {
    // Haptic feedback
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }

    final authService = ref.read(authServiceProvider);
    final userId = authService.currentUserId;

    if (userId == null) return;

    if (isLike) {
      // Save like to Firestore
      final firestoreService = ref.read(firestoreServiceProvider);
      try {
        await firestoreService.saveLike(widget.room.roomId, userId, movie);
      } catch (e) {
        print('Error saving like: $e');
      }
    }

    // Remove movie from list
    ref.read(moviesListProvider.notifier).removeMovie(movie.id);
    if (mounted) {
      setState(() {
        _dragProgress = 0;
      });
    }
  }

  void _onLike() {
    final movies = ref.read(moviesListProvider).value ?? const <MovieModel>[];
    if (movies.isEmpty) return;

    // Primary path: animate via card controller.
    _swipeController.swipe(isLike: true);

    // Fallback path: if controller is not attached yet, still process swipe.
    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      final latestMovies = ref.read(moviesListProvider).value ?? const <MovieModel>[];
      if (latestMovies.isNotEmpty && latestMovies.first.id == movies.first.id) {
        _handleSwipe(true, latestMovies.first);
      }
    });
  }

  void _onDislike() {
    final movies = ref.read(moviesListProvider).value ?? const <MovieModel>[];
    if (movies.isEmpty) return;

    _swipeController.swipe(isLike: false);

    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      final latestMovies = ref.read(moviesListProvider).value ?? const <MovieModel>[];
      if (latestMovies.isNotEmpty && latestMovies.first.id == movies.first.id) {
        _handleSwipe(false, latestMovies.first);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final roomStream = ref.watch(currentRoomProvider);
    final moviesAsync = ref.watch(moviesListProvider);
    final currentUserId = ref.read(authServiceProvider).currentUserId;
    final isHost = currentUserId != null && currentUserId == widget.room.creatorId;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Room Code'),
            Text(
              widget.room.roomCode,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _isRoomActionLoading ? null : _confirmLeaveRoom,
            child: const Text('Leave'),
          ),
          if (isHost)
            TextButton(
              onPressed: _isRoomActionLoading ? null : _confirmDeleteRoom,
              child: const Text(
                'Delete',
                style: TextStyle(color: AppTheme.dislikeColor),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(moviesListProvider.notifier).refresh();
            },
            tooltip: 'Refresh Movies',
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
            // Room status
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: roomStream.when(
                data: (room) {
                  if (room == null) {
                    return const Text('Room not found');
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: room.isReady
                          ? AppTheme.likeColor.withOpacity(0.2)
                          : AppTheme.secondaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: room.isReady
                            ? AppTheme.likeColor
                            : AppTheme.secondaryColor,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          room.isReady ? Icons.check_circle : Icons.hourglass_empty,
                          color: room.isReady
                              ? AppTheme.likeColor
                              : AppTheme.secondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          room.isReady
                              ? '${room.userIds.length}/2 Users - Ready to match!'
                              : 'Waiting for partner... (${room.userIds.length}/2)',
                          style: TextStyle(
                            color: room.isReady
                                ? AppTheme.likeColor
                                : AppTheme.secondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error loading room'),
              ),
            ),

            // Movie cards
            Expanded(
              child: moviesAsync.when(
                data: (movies) {
                  if (movies.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.movie_outlined,
                            size: 80,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No more movies!',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              ref.read(moviesListProvider.notifier).refresh();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Load More Movies'),
                          ),
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Stack(
                      children: [
                        // Show up to 2 cards for depth
                        if (movies.length > 1)
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Transform.scale(
                                scale: 0.94 + (_dragProgress * 0.06),
                                child: Opacity(
                                  opacity: 0.45 + (_dragProgress * 0.2),
                                  child: MovieCard(movie: movies[1]),
                                ),
                              ),
                            ),
                          ),

                        // Top card (swipeable)
                        Positioned.fill(
                          child: SwipeableCard(
                            key: ValueKey(movies[0].id),
                            movie: movies[0],
                            isTop: true,
                            controller: _swipeController,
                            onDragProgress: (value) {
                              if (!mounted) return;
                              if ((_dragProgress - value).abs() < 0.01) return;
                              setState(() {
                                _dragProgress = value;
                              });
                            },
                            onSwipe: (isLike) {
                              _handleSwipe(isLike, movies[0]);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: MovieCardSkeleton(),
                ),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: AppTheme.dislikeColor,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Failed to load movies',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        error.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.read(moviesListProvider.notifier).refresh();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                      const SizedBox(height: 12),
                      ActionChip(
                        avatar: const Icon(Icons.autorenew, size: 18),
                        label: const Text('Quick Retry'),
                        onPressed: () {
                          ref.read(moviesListProvider.notifier).refresh();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: moviesAsync.when(
                data: (movies) {
                  if (movies.isEmpty) return const SizedBox.shrink();

                  return ActionButtons(
                    onDislike: _onDislike,
                    onLike: _onLike,
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
              ],
            ),
            if (_isRoomActionLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.35),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
