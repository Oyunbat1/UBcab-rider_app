import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rider_app/core/theme/app_theme.dart';
import 'package:rider_app/features/trip/suite/trip_suite.dart';


class DriverProfileSheet extends StatelessWidget {
  const DriverProfileSheet({super.key});

  static Future<void> show() {
    return Get.bottomSheet<void>(
      const DriverProfileSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TripController>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Obx(() {
        final name = controller.state.driverName.value.isEmpty
            ? 'Driver'
            : controller.state.driverName.value;
        final phone = controller.state.driverPhone.value;
        final rating = controller.state.driverRating.value;
        final vehicle = controller.state.driverVehicle.value;
        final plate = controller.state.driverPlate.value;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            const CircleAvatar(
              radius: 36,
              backgroundColor: Color(0xFFDDE3F0),
              child: Icon(Icons.person, size: 36, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            if (phone.isNotEmpty)
              Text(
                phone,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary),
              ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat('${rating.toStringAsFixed(1)} ⭐', 'Rating'),
                  _stat(vehicle.isEmpty ? '—' : vehicle, 'Vehicle'),
                  _stat(plate.isEmpty ? '—' : plate, 'Plate'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: phone.isEmpty
                        ? null
                        : () {
                            Get.snackbar(
                              'Call',
                              'Dialing $phone (placeholder)',
                              snackPosition: SnackPosition.TOP,
                            );
                          },
                    icon: const Icon(Icons.call, size: 16),
                    label: const Text('Call'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
