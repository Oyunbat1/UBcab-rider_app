import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rider_app/core/theme/app_theme.dart';
import 'package:rider_app/features/trip/suite/trip_suite.dart';
import 'package:rider_app/features/trip/components/driver_profile_sheet.dart';
import 'package:rider_app/features/trip/components/rider_trip_map.dart';
import 'package:rider_app/features/trip/components/trip_status_bar.dart';

class TripActiveView extends StatelessWidget {
  const TripActiveView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TripController>();

    return Scaffold(
      body: Stack(
        children: [
          // Real Google Map: pickup, dropoff, driver-iin live position.
          // Driver app 5 sek tutamd `driverLocation` push hiidg tul rider
          // map deer driver-iin yvltsang harna.
          const Positioned.fill(child: RiderTripMap()),

          // Top status bar — elapsed timer + status.
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TripStatusBar(),
          ),

          // Bottom card — driver info (tap to view) + actions.
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Obx(() {
              final trip = controller.state.activeTrip.value;
              if (trip == null) return const SizedBox();

              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -4))
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                          color: const Color(0xFFDDDDDD),
                          borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(height: 12),

                    // Driver row — InkWell-ar wrap; tap-har profile bottom sheet
                    InkWell(
                      onTap: DriverProfileSheet.show,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              backgroundColor: Color(0xFFDDE3F0),
                              child: Icon(Icons.person, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.state.driverName.value.isEmpty
                                        ? 'Driver'
                                        : controller.state.driverName.value,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '⭐ ${controller.state.driverRating.value.toStringAsFixed(1)}  ·  ${controller.state.driverVehicle.value} · Tap to view',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                controller.state.driverPlate.value,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.circle,
                            size: 8, color: AppTheme.primaryColor),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            (trip['pickupAddress'] as String?)?.isNotEmpty ==
                                    true
                                ? trip['pickupAddress']
                                : 'Pickup location',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.circle,
                            size: 8, color: Colors.red.shade600),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            (trip['dropoffAddress'] as String?)?.isNotEmpty ==
                                    true
                                ? trip['dropoffAddress']
                                : 'Dropoff location',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: DriverProfileSheet.show,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text('📞  Call',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF2E7D32))),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => controller.cancelTrip(),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text('✕  Cancel',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFE53935))),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
