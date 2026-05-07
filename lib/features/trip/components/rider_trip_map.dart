import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:rider_app/core/theme/app_theme.dart';
import 'package:rider_app/features/location/logic/location_controller.dart';
import 'package:rider_app/features/trip/suite/trip_suite.dart';

/// Trip-iin idewhitei uyd rider-iin haruulahaar map.
///
/// Markeruud:
///  - pickup (uchin shar)  - rider-iin sjoo bairshil
///  - dropoff (ulaan)
///  - driver (nogoon) — `trip['driverLocation']` (GeoPoint) deer suugd push hiidg.
///    Driver app 5 sek tutamd ene field-iig shineechin tul rider real-time-aar harna.
///
/// Polyline:
///  - status `accepted` -> driver -> pickup
///  - status `inProgress` -> driver -> dropoff
class RiderTripMap extends StatefulWidget {
  const RiderTripMap({super.key});

  @override
  State<RiderTripMap> createState() => _RiderTripMapState();
}

class _RiderTripMapState extends State<RiderTripMap> {
  final Completer<GoogleMapController> _completer =
      Completer<GoogleMapController>();
  GoogleMapController? _mapController;
  bool _initialized = false;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _animateBoundsToFit(List<LatLng> points) async {
    if (points.length < 2) return;
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    final c = await _completer.future;
    await c.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        80,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tripController = Get.find<TripController>();
    final locationController = Get.find<LocationController>();

    return Obx(() {
      final trip = tripController.state.activeTrip.value;
      final status = tripController.state.tripStatus.value;

      // Pickup ni rider-iin GPS bairshil ese trip['pickup'] (Firestore-aas).
      LatLng? pickup;
      final pickupGp = trip?['pickup'];
      if (pickupGp is GeoPoint) {
        pickup = LatLng(pickupGp.latitude, pickupGp.longitude);
      } else {
        final pos = locationController.state.currentPosition.value;
        if (pos != null) pickup = LatLng(pos.latitude, pos.longitude);
      }

      LatLng? dropoff;
      final dropoffGp = trip?['dropoff'];
      if (dropoffGp is GeoPoint) {
        dropoff = LatLng(dropoffGp.latitude, dropoffGp.longitude);
      }

      LatLng? driver;
      final driverGp = trip?['driverLocation'];
      if (driverGp is GeoPoint) {
        driver = LatLng(driverGp.latitude, driverGp.longitude);
      }

      if (pickup == null) {
        return const ColoredBox(
          color: Color(0xFFEEF0EC),
          child: Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          ),
        );
      }

      // Markers
      final markers = <Marker>{
        Marker(
          markerId: const MarkerId('pickup'),
          position: pickup,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(
            title: 'Pickup',
            snippet: trip?['pickupAddress'] as String?,
          ),
        ),
      };
      if (dropoff != null) {
        markers.add(
          Marker(
            markerId: const MarkerId('dropoff'),
            position: dropoff,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(
              title: 'Dropoff',
              snippet: trip?['dropoffAddress'] as String?,
            ),
          ),
        );
      }
      if (driver != null) {
        markers.add(
          Marker(
            markerId: const MarkerId('driver'),
            position: driver,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            infoWindow: const InfoWindow(title: 'Driver'),
          ),
        );
      }

      // Polyline
      final polylines = <Polyline>{};
      if (driver != null && status == TripStatus.accepted) {
        polylines.add(
          Polyline(
            polylineId: const PolylineId('driver-to-pickup'),
            points: [driver, pickup],
            color: AppTheme.primaryColor,
            width: 4,
            geodesic: true,
          ),
        );
      } else if (driver != null &&
          status == TripStatus.inProgress &&
          dropoff != null) {
        polylines.add(
          Polyline(
            polylineId: const PolylineId('driver-to-dropoff'),
            points: [driver, dropoff],
            color: Colors.red.shade600,
            width: 4,
            geodesic: true,
          ),
        );
      }

      // Markeruud orsoor camera-g unduurun zogson udaa fit hiine.
      if (_initialized) {
        final pts = <LatLng>[pickup];
        if (dropoff != null) pts.add(dropoff);
        if (driver != null) pts.add(driver);
        _animateBoundsToFit(pts);
      }

      return GoogleMap(
        initialCameraPosition: CameraPosition(target: pickup, zoom: 14),
        onMapCreated: (c) {
          _mapController = c;
          if (!_completer.isCompleted) _completer.complete(c);
          _initialized = true;
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        compassEnabled: false,
        markers: markers,
        polylines: polylines,
      );
    });
  }
}
