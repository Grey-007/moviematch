import 'package:flutter/material.dart';
import '../core/theme.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onDislike;
  final VoidCallback onLike;
  final VoidCallback? onUndo;

  const ActionButtons({
    super.key,
    required this.onDislike,
    required this.onLike,
    this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Dislike button
        _ActionButton(
          onTap: onDislike,
          icon: Icons.close,
          color: AppTheme.dislikeColor,
          size: 60,
        ),
        const SizedBox(width: 30),

        // Undo button (optional)
        if (onUndo != null) ...[
          _ActionButton(
            onTap: onUndo!,
            icon: Icons.replay,
            color: Colors.amber,
            size: 50,
          ),
          const SizedBox(width: 30),
        ],

        // Like button
        _ActionButton(
          onTap: onLike,
          icon: Icons.favorite,
          color: AppTheme.likeColor,
          size: 60,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color color;
  final double size;

  const _ActionButton({
    required this.onTap,
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: color,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}
