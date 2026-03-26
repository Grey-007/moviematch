import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';

class MatchScreen extends StatelessWidget {
  final String movieTitle;
  final String? posterPath;
  final VoidCallback onContinue;

  const MatchScreen({
    super.key,
    required this.movieTitle,
    this.posterPath,
    required this.onContinue,
  });

  String? _getPosterUrl() {
    if (posterPath == null) return null;
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  @override
  Widget build(BuildContext context) {
    final posterUrl = _getPosterUrl();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.9),
              AppTheme.secondaryColor.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.5),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Match icon with animation
            Icon(
              Icons.celebration,
              size: 80,
              color: Colors.white,
            )
                .animate()
                .scale(
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                )
                .then()
                .shake(hz: 2, duration: 500.ms),

            const SizedBox(height: 20),

            // "It's a Match!" text
            Text(
              "It's a Match!",
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 12),

            // Movie title
            Text(
              'You both liked',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms),

            const SizedBox(height: 8),

            Text(
              movieTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
                .animate()
                .fadeIn(delay: 600.ms, duration: 400.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 24),

            // Movie poster
            if (posterUrl != null)
              Container(
                width: 150,
                height: 225,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: posterUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppTheme.cardColor,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppTheme.cardColor,
                      child: const Icon(
                        Icons.movie,
                        size: 50,
                        color: Colors.white30,
                      ),
                    ),
                  ),
                ),
              )
                  .animate()
                  .scale(
                    delay: 800.ms,
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(delay: 800.ms),

            const SizedBox(height: 32),

            // Continue button
            ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Continue Swiping',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 1200.ms, duration: 400.ms)
                .slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }
}
