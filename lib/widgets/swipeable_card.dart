import 'dart:math';
import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../core/theme.dart';
import 'movie_card.dart';

class SwipeableCardController {
  void Function(bool isLike)? _swipe;

  void _attach(void Function(bool isLike) callback) {
    _swipe = callback;
  }

  void _detach() {
    _swipe = null;
  }

  void swipe({required bool isLike}) {
    _swipe?.call(isLike);
  }
}

class SwipeableCard extends StatefulWidget {
  final MovieModel movie;
  final ValueChanged<bool> onSwipe;
  final bool isTop;
  final SwipeableCardController? controller;
  final ValueChanged<double>? onDragProgress;

  const SwipeableCard({
    super.key,
    required this.movie,
    required this.onSwipe,
    this.isTop = false,
    this.controller,
    this.onDragProgress,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  static const double _maxTiltRadians = pi / 12;
  static const double _dismissVelocity = 800;

  late final AnimationController _animationController;
  Animation<Offset>? _offsetAnimation;
  Animation<double>? _rotationAnimation;

  Offset _dragOffset = Offset.zero;
  double _dragRotation = 0;
  bool _isDragging = false;
  bool _isAnimatingOut = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    widget.controller?._attach(_triggerProgrammaticSwipe);
  }

  @override
  void didUpdateWidget(covariant SwipeableCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(_triggerProgrammaticSwipe);
    }

    if (oldWidget.movie.id != widget.movie.id) {
      _animationController.stop();
      _offsetAnimation = null;
      _rotationAnimation = null;
      _dragOffset = Offset.zero;
      _dragRotation = 0;
      _isDragging = false;
      _isAnimatingOut = false;
      widget.onDragProgress?.call(0);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final offset = _offsetAnimation?.value ?? _dragOffset;
    final rotationAngle = _rotationAnimation?.value ?? _dragRotation;
    final likeOpacity = offset.dx > 0 ? (offset.dx / 100).clamp(0.0, 1.0) : 0.0;
    final dislikeOpacity = offset.dx < 0 ? (-offset.dx / 100).clamp(0.0, 1.0) : 0.0;

    return Transform(
      transform: Matrix4.identity()
        ..translate(offset.dx, offset.dy)
        ..rotateZ(rotationAngle),
      child: GestureDetector(
        onPanStart: (details) {
          if (widget.isTop && !_isAnimatingOut) {
            _animationController.stop();
            _offsetAnimation = null;
            _rotationAnimation = null;
            setState(() => _isDragging = true);
          }
        },
        onPanUpdate: (details) {
          if (widget.isTop && !_isAnimatingOut) {
            setState(() {
              _dragOffset += details.delta;
              _dragRotation =
                  (_dragOffset.dx / screenSize.width).clamp(-1.0, 1.0) *
                      _maxTiltRadians;
            });
            widget.onDragProgress
                ?.call((_dragOffset.dx.abs() / (screenSize.width * 0.28)).clamp(0.0, 1.0));
          }
        },
        onPanEnd: (details) {
          if (widget.isTop && !_isAnimatingOut) {
            setState(() => _isDragging = false);

            final velocityX = details.velocity.pixelsPerSecond.dx;
            final threshold = screenSize.width * 0.28;

            if (_dragOffset.dx > threshold || velocityX > _dismissVelocity) {
              _animateDismiss(isLike: true, velocityX: velocityX);
            } else if (_dragOffset.dx < -threshold || velocityX < -_dismissVelocity) {
              _animateDismiss(isLike: false, velocityX: velocityX);
            } else {
              _animateBackToCenter();
            }
          }
        },
        child: Stack(
          children: [
            MovieCard(
              movie: widget.movie,
              isTop: widget.isTop,
            ),
            if (widget.isTop && likeOpacity > 0)
              Positioned(
                top: 50,
                left: 50,
                child: Opacity(
                  opacity: likeOpacity,
                  child: Transform.rotate(
                    angle: -0.3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.likeColor,
                          width: 4,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'LIKE',
                        style: TextStyle(
                          color: AppTheme.likeColor,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (widget.isTop && dislikeOpacity > 0)
              Positioned(
                top: 50,
                right: 50,
                child: Opacity(
                  opacity: dislikeOpacity,
                  child: Transform.rotate(
                    angle: 0.3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.dislikeColor,
                          width: 4,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'NOPE',
                        style: TextStyle(
                          color: AppTheme.dislikeColor,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _triggerProgrammaticSwipe(bool isLike) {
    if (!widget.isTop || _isDragging || _isAnimatingOut) return;
    _animateDismiss(isLike: isLike, velocityX: isLike ? 1400 : -1400);
  }

  Future<void> _animateDismiss({
    required bool isLike,
    required double velocityX,
  }) async {
    if (_isAnimatingOut) return;

    final screenSize = MediaQuery.of(context).size;
    final targetX = isLike ? screenSize.width * 1.35 : -screenSize.width * 1.35;
    final targetY = _dragOffset.dy + (velocityX.sign * 30);
    final distance = (targetX - _dragOffset.dx).abs();
    final speedFactor = velocityX.abs().clamp(700.0, 2200.0) / 2200.0;
    final durationMs = (300 - (120 * speedFactor) - (distance / 20))
        .round()
        .clamp(160, 300);

    setState(() {
      _isAnimatingOut = true;
      _isDragging = false;
      _offsetAnimation = Tween<Offset>(
        begin: _dragOffset,
        end: Offset(targetX, targetY),
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
      );
      _rotationAnimation = Tween<double>(
        begin: _dragRotation,
        end: isLike ? _maxTiltRadians : -_maxTiltRadians,
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
      );
    });
    widget.onDragProgress?.call(1);

    _animationController.duration = Duration(milliseconds: durationMs);
    await _animationController.forward(from: 0);
    if (!mounted) return;
    widget.onSwipe(isLike);
  }

  Future<void> _animateBackToCenter() async {
    setState(() {
      _offsetAnimation = Tween<Offset>(
        begin: _dragOffset,
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
      );
      _rotationAnimation = Tween<double>(
        begin: _dragRotation,
        end: 0,
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
      );
    });

    _animationController.duration = const Duration(milliseconds: 240);
    await _animationController.forward(from: 0);
    if (!mounted) return;

    setState(() {
      _dragOffset = Offset.zero;
      _dragRotation = 0;
      _offsetAnimation = null;
      _rotationAnimation = null;
    });
    widget.onDragProgress?.call(0);
  }
}
