import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rider_app/core/theme/app_theme.dart';
import 'package:rider_app/features/trip/suite/trip_suite.dart';

/// Trip-iin top bar:
/// - 'accepted' uyd huleej baigaa hugatsaa MM:SS-ar haruulna
/// - 'arriving' uyd "Driver has arrived"
/// - 'inProgress' uyd "On the way to destination"
class TripStatusBar extends StatelessWidget {
  const TripStatusBar({super.key});

  String _title(TripStatus? status) {
    switch (status) {
      case TripStatus.requested:
        return 'Finding your driver...';
      case TripStatus.accepted:
        return 'Driver is on the way';
      case TripStatus.arriving:
        return 'Driver has arrived';
      case TripStatus.inProgress:
        return 'On the way to destination';
      case TripStatus.completed:
        return 'Trip completed';
      case TripStatus.cancelled:
        return 'Trip cancelled';
      case null:
        return '';
    }
  }

  String _subtitle(TripStatus? status, String elapsed) {
    switch (status) {
      case TripStatus.requested:
        return 'Please wait...';
      case TripStatus.accepted:
        return 'Arriving · $elapsed';
      case TripStatus.arriving:
        return 'Please head out to the pickup point';
      case TripStatus.inProgress:
        return 'Enjoy your ride';
      case TripStatus.completed:
        return 'Thank you for riding!';
      case TripStatus.cancelled:
      case null:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TripController>();

    return Container(
      width: double.infinity,
      color: AppTheme.primaryColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Obx(() {
            final status = controller.state.tripStatus.value;
            final elapsed = controller.state.elapsed.value;

            // 'accepted' uyd elapsed timer-iig tom haruulna.
            if (status == TripStatus.accepted) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title(status),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_outlined,
                          color: Colors.white, size: 26),
                      const SizedBox(width: 8),
                      Text(
                        elapsed,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'huleej bui hugatsaa',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }


            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title(status),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (_subtitle(status, elapsed).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      _subtitle(status, elapsed),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
