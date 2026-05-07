import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rider_app/app/routes/app_routes.dart';
import 'package:rider_app/core/theme/app_theme.dart';
import 'package:rider_app/core/utils/geo_utils.dart';
import 'package:rider_app/features/location/logic/location_controller.dart';
import 'package:rider_app/features/location/components/address_search_bar.dart';
import 'package:rider_app/features/location/components/current_location_button.dart';
import 'package:rider_app/features/trip/suite/trip_suite.dart';
import 'package:rider_app/features/trip/components/fare_estimate_card.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _mapController;
  final Completer<GoogleMapController> _mapControllerCompleter =
      Completer<GoogleMapController>();

  final selectedDestination = Rx<Map<String, dynamic>?>(null);
  final geocodingInProgress = false.obs;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _onPickedPlace(Map result) async {
    final title = (result['title'] ?? '').toString();
    final subtitle = (result['subtitle'] ?? '').toString();
    final lat = result['latitude'];
    final lng = result['longitude'];
    if (lat is double && lng is double) {
      return _useDestinationLatLng(title, subtitle, LatLng(lat, lng));
    }
    return _onDestinationSelected(title, subtitle);
  }

  Future<LatLng?> _geocodePlace(String placeTitle, String placeSubtitle) async {
    try {
      geocodingInProgress.value = true;
      final query = '$placeTitle, $placeSubtitle';
      final locations = await locationFromAddress(query);
      if (locations.isEmpty) {
        Get.snackbar('Error', 'Could not find location: $query');
        return null;
      }
      final location = locations.first;
      return LatLng(location.latitude, location.longitude);
    } catch (e) {
      Get.snackbar('Geocoding Error', e.toString());
      return null;
    } finally {
      geocodingInProgress.value = false;
    }
  }


  Future<void> _onDestinationSelected(String title, String subtitle) async {
    final destLatLng = await _geocodePlace(title, subtitle);
    if (destLatLng == null) return;
    return _useDestinationLatLng(title, subtitle, destLatLng);
  }

  /// Uzkhukhuun lat/lng-tei tul shaardlagatai bushуу handlerуud руу нэгтгэх heseg.
  Future<void> _useDestinationLatLng(
    String title,
    String subtitle,
    LatLng destLatLng,
  ) async {
    final locationController = Get.find<LocationController>();

    final currentPos = locationController.state.currentPosition.value;
    if (currentPos == null) {
      Get.snackbar('Location', 'Could not get your current location');
      return;
    }

    final distKm = GeoUtils.distanceKm(
      currentPos.latitude,
      currentPos.longitude,
      destLatLng.latitude,
      destLatLng.longitude,
    );

    final fare = GeoUtils.estimateFare(distKm);
    final etaMinutes = (distKm / 30 * 60).toStringAsFixed(0);

    selectedDestination.value = {
      'title': title,
      'subtitle': subtitle,
      'latitude': destLatLng.latitude,
      'longitude': destLatLng.longitude,
      'distance': distKm,
      'fare': fare,
      'eta': etaMinutes,
    };

    _animateCameraToBounds(
      currentPos.latitude,
      currentPos.longitude,
      destLatLng.latitude,
      destLatLng.longitude,
    );
  }


  Future<void> _animateCameraToBounds(
    double pickupLat,
    double pickupLng,
    double dropoffLat,
    double dropoffLng,
  ) async {
    final controller = await _mapControllerCompleter.future;

    final centerLat = (pickupLat + dropoffLat) / 2;
    final centerLng = (pickupLng + dropoffLng) / 2;

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(centerLat, centerLng),
          zoom: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tripController = Get.find<TripController>();
    final locationController = Get.find<LocationController>();

    return Scaffold(
      body: Obx(() {
        final currentPos = locationController.state.currentPosition.value;

        return Stack(
          children: [

            if (currentPos != null)
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(currentPos.latitude, currentPos.longitude),
                  zoom: 15,
                ),
                onMapCreated: (controller) {
                  if (!_mapControllerCompleter.isCompleted) {
                    _mapControllerCompleter.complete(controller);
                  }
                  _mapController = controller;
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                markers: _buildMarkers(currentPos),
                polylines: _buildPolylines(currentPos),
              )
            else
              Container(
                color: const Color(0xFFEEF0EC),
                child: const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryColor),
                ),
              ),

            // Top bar: greeting + profile
            Positioned(
              top: 0,
              left: 0,
              right: 0,
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
                              'Өглөөний мэнд 👋',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            GestureDetector(
                              onTap: () => Get.toNamed(AppRoutes.profile),
                              child: const CircleAvatar(
                                radius: 16,
                                backgroundColor: Color(0xFFDDE3F0),
                                child: Icon(Icons.person,
                                    size: 18, color: AppTheme.primaryColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        AddressSearchBar(
                          onTap: () async {
                            final result = await Get.toNamed(
                                AppRoutes.pickLocation);
                            if (result != null && result is Map) {
                              await _onPickedPlace(result);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Current location button
            Positioned(
              bottom: 220,
              right: 16,
              child: CurrentLocationButton(
                onPressed: () => locationController.getCurrentLocation(),
              ),
            ),

            // Bottom sheet: trip status, fare estimate, or recent places
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomSheet(tripController),
            ),
          ],
        );
      }),
    );
  }

  Set<Marker> _buildMarkers(dynamic currentPos) {
    final dest = selectedDestination.value;
    final markers = <Marker>{};


    markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(currentPos.latitude, currentPos.longitude),
        infoWindow: const InfoWindow(title: 'Pickup Location'),
      ),
    );


    if (dest != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('dropoff'),
          position: LatLng(dest['latitude'], dest['longitude']),
          infoWindow: InfoWindow(title: dest['title']),
        ),
      );
    }

    return markers;
  }

  /// Draw polyline between pickup and dropoff
  Set<Polyline> _buildPolylines(dynamic currentPos) {
    final dest = selectedDestination.value;
    if (dest == null) return {};

    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: [
          LatLng(currentPos.latitude, currentPos.longitude),
          LatLng(dest['latitude'], dest['longitude']),
        ],
        color: AppTheme.primaryColor,
        width: 4,
        geodesic: true,
      ),
    };
  }

  /// Bottom sheet content
  Widget _buildBottomSheet(TripController tripController) {
    return Obx(() {
      final dest = selectedDestination.value;
      final tripStatus = tripController.state.tripStatus.value;

      // If requesting ride, show loading
      if (tripStatus == TripStatus.requested) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 20, offset: Offset(0, -4)),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppTheme.primaryColor),
              const SizedBox(height: 16),
              const Text('Жолооч хайж байна...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('Та түр хүлээгээрэй',
                  style:
                      TextStyle(fontSize: 13, color: AppTheme.textTertiary)),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  tripController.cancelTrip();
                  selectedDestination.value = null;
                },
                child: const Text('Цуцлах'),
              ),
            ],
          ),
        );
      }

      // If destination selected, show fare estimate
      if (dest != null) {
        final locationController = Get.find<LocationController>();
        final currentAddress = locationController.state.currentAddress.value;
        final pickupLabel = currentAddress.isNotEmpty
            ? currentAddress
            : 'Одоогийн байршил';
        final dropoffLabel = '${dest['title']}, ${dest['subtitle']}';
        final currentPos = locationController.state.currentPosition.value;
        final hasPickup = currentPos != null;
        return FareEstimateCard(
          pickupAddress: pickupLabel,
          dropoffAddress: dropoffLabel,
          fare: dest['fare'],
          distance: '${(dest['distance'] as double).toStringAsFixed(1)} km',
          eta: '${dest['eta']} min',
          isLoading: geocodingInProgress.value ||
              tripController.state.isRequesting.value ||
              !hasPickup,
          onRequestRide: () {
            if (!hasPickup) {
              Get.snackbar('Location', 'Could not get your current location');
              return;
            }
            tripController.requestTrip(
              pickup: GeoPoint(currentPos.latitude, currentPos.longitude),
              dropoff: GeoPoint(
                  dest['latitude'] as double, dest['longitude'] as double),
              fare: dest['fare'],
              pickupAddress: pickupLabel,
              dropoffAddress: dropoffLabel,
            );
          },
        );
      }

      // Default: show recent places
      return _buildRecentPlaces();
    });
  }

  Widget _buildRecentPlaces() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4))
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Recent places',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          _placeItem(Icons.business, 'Central Tower',
              'Sukhbaatar Square, UB'),
          _placeItem(
              Icons.home, 'Home', 'Bayangol district, 4th khoroo'),
          _placeItem(Icons.school, 'National University',
              'Baga toiruu, UB'),
        ],
      ),
    );
  }

  Widget _placeItem(IconData icon, String title, String subtitle) {
    return GestureDetector(
      onTap: () => _onDestinationSelected(title, subtitle),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F8),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 16, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textTertiary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
