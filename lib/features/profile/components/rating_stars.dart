import 'package:flutter/material.dart';
import 'package:rider_app/core/theme/app_theme.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;

  const RatingStars({super.key, required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, size: size, color: AppTheme.primaryColor),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: size - 3,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }
}
