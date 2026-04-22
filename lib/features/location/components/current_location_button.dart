import 'package:flutter/material.dart';
import 'package:rider_app/core/theme/app_theme.dart';

class CurrentLocationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CurrentLocationButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.my_location, color: AppTheme.primaryColor, size: 18),
        onPressed: onPressed,
      ),
    );
  }
}
