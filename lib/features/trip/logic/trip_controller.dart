import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:rider_app/app/routes/app_routes.dart';
import 'package:rider_app/features/trip/state/trip_state.dart';
import 'package:rider_app/features/trip/logic/trip_api.dart';
import 'package:rider_app/features/trip/suite/trip_suite.dart';

class TripController extends GetxController {
  final TripApi tripApi;
  final state = TripState();

  StreamSubscription? _tripSubscription;

  TripController({required this.tripApi});

  /// Called when rider taps "Request Ride"
  ///
  /// FLOW:
  /// 1. Creates a trip doc in Firestore with status:'requested', driverId:null
  /// 2. Starts listening to that doc for real-time changes
  /// 3. When driver accepts → driverId is set, status becomes 'accepted'
  /// 4. Our listener picks that up → UI updates to show "Driver found!"
  Future<void> requestTrip({
    required GeoPoint pickup,
    required GeoPoint dropoff,
    required int fare,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    state.isRequesting.value = true;

    // Step 1: Write trip doc to Firestore
    final tripId = await tripApi.createTrip(
      riderId: uid,
      pickup: pickup,
      dropoff: dropoff,
      fare: fare,
    );

    state.activeTripId.value = tripId;
    state.tripStatus.value = TripStatus.requested;
    state.isRequesting.value = false;

    // Step 2: Start listening for changes on this trip doc
    _tripSubscription = tripApi.watchTrip(tripId).listen((snapshot) {
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      state.activeTrip.value = data;

      final status = data['status'] as String?;

      // Step 3: Check if driver has accepted
      if (status == 'accepted' && data['driverId'] != null) {
        state.tripStatus.value = TripStatus.accepted;
        // Navigate to active trip screen showing driver info
        Get.toNamed(AppRoutes.tripActive);
      } else if (status == 'cancelled') {
        state.tripStatus.value = TripStatus.cancelled;
        _resetTrip();
      }
    });
  }

  /// Cancel the current trip
  Future<void> cancelTrip() async {
    final tripId = state.activeTripId.value;
    if (tripId == null) return;

    await tripApi.cancelTrip(tripId);
    _resetTrip();
    Get.back();
  }

  void _resetTrip() {
    _tripSubscription?.cancel();
    _tripSubscription = null;
    state.activeTripId.value = null;
    state.activeTrip.value = null;
    state.tripStatus.value = null;
    state.fareEstimate.value = 0;
  }

  @override
  void onClose() {
    _tripSubscription?.cancel();
    super.onClose();
  }
}
