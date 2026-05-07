import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rider_app/app/routes/app_routes.dart';
import 'package:rider_app/core/services/audio_service.dart';
import 'package:rider_app/core/theme/app_theme.dart';
import 'package:rider_app/features/trip/suite/trip_suite.dart';

class TripController extends GetxController {
  final TripApi tripApi;
  final state = TripState();

  StreamSubscription? _tripSubscription;
  Timer? _elapsedTimer;
  String? _lastSeenStatus;

  TripController({required this.tripApi});

  AudioService get _audio => Get.isRegistered<AudioService>()
      ? Get.find<AudioService>()
      : Get.put(AudioService(), permanent: true);


  Future<void> requestTrip({
    required GeoPoint pickup,
    required GeoPoint dropoff,
    required int fare,
    String? pickupAddress,
    String? dropoffAddress,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _audio.playRequest();

    state.isRequesting.value = true;

    final tripId = await tripApi.createTrip(
      riderId: uid,
      pickup: pickup,
      dropoff: dropoff,
      fare: fare,
      pickupAddress: pickupAddress,
      dropoffAddress: dropoffAddress,
    );

    state.activeTripId.value = tripId;
    state.tripStatus.value = TripStatus.requested;
    state.isRequesting.value = false;
    _lastSeenStatus = 'requested';

    _tripSubscription = tripApi.watchTrip(tripId).listen(_onTripSnapshot);
  }

  void _onTripSnapshot(DocumentSnapshot snapshot) {
    if (!snapshot.exists) return;

    final data = snapshot.data() as Map<String, dynamic>;
    state.activeTrip.value = data;

    final status = data['status'] as String?;
    if (status == null) return;


    if (status == _lastSeenStatus) return;
    final previous = _lastSeenStatus;
    _lastSeenStatus = status;

    switch (status) {
      case 'accepted':
        _onAccepted(data);
        break;
      case 'arriving':
        _onArriving();
        break;
      case 'inProgress':
        _onInProgress();
        break;
      case 'completed':
        _onCompleted(data);
        break;
      case 'cancelled':
        _onCancelled(previous);
        break;
    }
  }

  Future<void> _onAccepted(Map<String, dynamic> data) async {
    state.tripStatus.value = TripStatus.accepted;
    _audio.playDriverFound();

    final driverId = data['driverId'] as String?;
    if (driverId != null) {
      final driverDoc = await tripApi.getUserDoc(driverId);
      if (driverDoc != null) {
        state.driverName.value =
            (driverDoc['name'] as String?)?.trim().isNotEmpty == true
                ? driverDoc['name']
                : 'Driver';
        state.driverPhone.value = driverDoc['phone'] ?? '';
        state.driverVehicle.value = driverDoc['vehicle'] ?? 'Toyota Prius';
        state.driverPlate.value = driverDoc['plate'] ?? 'УБ 1234';
        state.driverRating.value = (driverDoc['rating'] ?? 4.8).toDouble();
      }
    }


    final ts = data['acceptedAt'];
    final accepted = ts is Timestamp ? ts.toDate() : DateTime.now();
    state.acceptedAt.value = accepted;
    _startElapsedTimer();

    Get.snackbar(
      'Driver olloo',
      '${state.driverName.value} tani olj ireh ywaa',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
      icon: const Icon(Icons.directions_car, color: Colors.white),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );


    if (Get.currentRoute != AppRoutes.tripActive) {
      Get.toNamed(AppRoutes.tripActive);
    }
  }

  void _onArriving() {
    state.tripStatus.value = TripStatus.arriving;
    _stopElapsedTimer();
    _audio.playArrived();
  }

  void _onInProgress() {
    state.tripStatus.value = TripStatus.inProgress;
    _audio.playStart();
  }

  void _onCompleted(Map<String, dynamic> data) {
    state.tripStatus.value = TripStatus.completed;
    _audio.playComplete();
    _stopElapsedTimer();

    final fare = (data['fare'] as num?)?.toInt() ?? 0;
    Get.snackbar(
      'Aylal duuslaa',
      '₮ ${_formatCurrency(fare)} tulburtei. Bayrlalaa!',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );

    _resetTrip();
    Get.offAllNamed(AppRoutes.home);
  }

  void _onCancelled(String? previous) {
    state.tripStatus.value = TripStatus.cancelled;
    _stopElapsedTimer();
    if (previous != 'requested') {
      Get.snackbar(
        'Aylal tsutslagdlaa...',
        '',
        snackPosition: SnackPosition.TOP,
      );
    }
    _resetTrip();
    if (Get.currentRoute == AppRoutes.tripActive) {
      Get.offAllNamed(AppRoutes.home);
    }
  }


  void _startElapsedTimer() {
    _elapsedTimer?.cancel();
    _tickElapsed();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tickElapsed();
    });
  }

  void _tickElapsed() {
    final accepted = state.acceptedAt.value;
    if (accepted == null) {
      state.elapsed.value = '00:00';
      return;
    }
    final diff = DateTime.now().difference(accepted);
    final mm = diff.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = diff.inSeconds.remainder(60).toString().padLeft(2, '0');
    state.elapsed.value = '$mm:$ss';
  }

  void _stopElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  ///  Aylal tsutslah
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
    _stopElapsedTimer();
    state.activeTripId.value = null;
    state.activeTrip.value = null;
    state.tripStatus.value = null;
    state.fareEstimate.value = 0;
    state.acceptedAt.value = null;
    state.elapsed.value = '00:00';
    state.driverName.value = '';
    state.driverPhone.value = '';
    state.driverVehicle.value = '';
    state.driverPlate.value = '';
    state.driverRating.value = 0.0;
    _lastSeenStatus = null;
  }

  @override
  void onClose() {
    _tripSubscription?.cancel();
    _stopElapsedTimer();
    super.onClose();
  }
}
