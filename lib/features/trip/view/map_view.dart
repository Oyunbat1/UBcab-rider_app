import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rider_app/app/routes/app_routes.dart';
import 'package:rider_app/core/theme/app_theme.dart';
import 'package:rider_app/core/utils/geo_utils.dart';
import 'package:rider_app/features/location/logic/location_controller.dart';
import 'package:rider_app/features/location/components/address_search_bar.dart';
import 'package:rider_app/features/location/components/current_location_button.dart';
import 'package:rider_app/features/trip/logic/trip_controller.dart';
import 'package:rider_app/features/trip/suite/trip_suite.dart';
import 'package:rider_app/features/trip/components/fare_estimate_card.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    final tripController = Get.find<TripController>();
    final locationController = Get.find<LocationController>();

    // Track whether a destination has been selected
    final selectedDestination = Rx<Map<String, String>?>(null);

    return Scaffold(
      body: Stack(
        children: [
          // Map background placeholder
          Container(color: const Color(0xFFEEF0EC)),

          // Top bar
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              color: Colors.white,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Good morning 👋',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          GestureDetector(
                            onTap: () => Get.toNamed(AppRoutes.profile),
                            child: const CircleAvatar(
                              radius: 16,
                              backgroundColor: Color(0xFFDDE3F0),
                              child: Icon(Icons.person, size: 18, color: AppTheme.primaryColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      AddressSearchBar(
                        onTap: () async {
                          final result = await Get.toNamed(AppRoutes.home + '/pick-location');
                          if (result != null && result is Map) {
                            selectedDestination.value = {
                              'title': result['title'] ?? '',
                              'subtitle': result['subtitle'] ?? '',
                            };
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // FAB - current location
          Positioned(
            bottom: 220, right: 16,
            child: CurrentLocationButton(
              onPressed: () => locationController.getCurrentLocation(),
            ),
          ),

          // Bottom panel — shows recent places or fare estimate
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Obx(() {
              final dest = selectedDestination.value;
              final tripStatus = tripController.state.tripStatus.value;

              // If trip is requested, show searching indicator
              if (tripStatus == TripStatus.requested) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4))],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: AppTheme.primaryColor),
                      const SizedBox(height: 16),
                      const Text('Finding your driver...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      const Text('Please wait', style: TextStyle(fontSize: 13, color: AppTheme.textTertiary)),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {
                          tripController.cancelTrip();
                          selectedDestination.value = null;
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                );
              }

              // If destination selected, show fare estimate
              if (dest != null) {
                final distKm = 4.2; // Placeholder
                final fare = GeoUtils.estimateFare(distKm);

                return FareEstimateCard(
                  pickupAddress: 'Current location',
                  dropoffAddress: '${dest['title']}, ${dest['subtitle']}',
                  fare: fare,
                  distance: '${distKm.toStringAsFixed(1)} km',
                  eta: '3 min',
                  isLoading: tripController.state.isRequesting.value,
                  onRequestRide: () {
                    // Use placeholder coordinates for now
                    tripController.requestTrip(
                      pickup: const GeoPoint(47.9184, 106.9177),
                      dropoff: const GeoPoint(47.9210, 106.9060),
                      fare: fare,
                    );
                  },
                );
              }

              // Default: recent places
              return _buildRecentPlaces(selectedDestination);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPlaces(Rx<Map<String, String>?> selectedDestination) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4))],
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFFDDDDDD), borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 14),
          const Text('Recent places', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          _placeItem(Icons.business, 'Central Tower', 'Sukhbaatar Square, UB', selectedDestination),
          _placeItem(Icons.home, 'Home', 'Bayangol district, 4th khoroo', selectedDestination),
          _placeItem(Icons.school, 'National University', 'Baga toiruu, UB', selectedDestination),
        ],
      ),
    );
  }

  Widget _placeItem(IconData icon, String title, String subtitle, Rx<Map<String, String>?> selectedDestination) {
    return GestureDetector(
      onTap: () {
        selectedDestination.value = {'title': title, 'subtitle': subtitle};
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: const Color(0xFFF0F2F8), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 16, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
