import 'package:flutter/material.dart';
import 'package:rider_app/core/theme/app_theme.dart';
import 'package:rider_app/features/trip/suite/trip_suite.dart';

class TripStatusBar extends StatelessWidget {
  final TripStatus status;

  const TripStatusBar({super.key, required this.status});

  String get _title {
    switch (status) {
      case TripStatus.requested:
        return 'Finding your driver...';
      case TripStatus.accepted:
        return 'Driver is on the way';
      case TripStatus.arriving:
        return 'Driver is arriving';
      case TripStatus.inProgress:
        return 'Trip in progress';
      case TripStatus.completed:
        return 'Trip completed';
      case TripStatus.cancelled:
        return 'Trip cancelled';
    }
  }

  String get _subtitle {
    switch (status) {
      case TripStatus.requested:
        return 'Please wait...';
      case TripStatus.accepted:
        return 'Arriving in 3 minutes';
      case TripStatus.arriving:
        return 'Driver is nearby';
      case TripStatus.inProgress:
        return 'Enjoy your ride';
      case TripStatus.completed:
        return 'Thank you for riding!';
      case TripStatus.cancelled:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 14),
      color: AppTheme.primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          if (_subtitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(_subtitle, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.75))),
            ),
        ],
      ),
    );
  }
}
