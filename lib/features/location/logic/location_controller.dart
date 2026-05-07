import 'dart:async';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rider_app/features/location/state/location_state.dart';
import 'package:rider_app/features/location/logic/location_api.dart';

class LocationController extends GetxController {
  final LocationApi locationApi;
  final state = LocationState();


  Timer? _reverseGeocodeDebounce;

  LocationController({required this.locationApi});

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  @override
  void onClose() {
    _reverseGeocodeDebounce?.cancel();
    super.onClose();
  }

  Future<void> getCurrentLocation() async {
    state.isLoading.value = true;
    try {
      final hasPermission = await locationApi.checkAndRequestPermission();
      if (!hasPermission) {
        Get.snackbar(
          'Permission',
          'Location permission is required. Please enable it in settings.',
        );
        return;
      }

      final position = await locationApi.getCurrentPosition();
      state.currentPosition.value = position;


      final address = await locationApi.reverseGeocode(
        position.latitude,
        position.longitude,
      );
      if (address != null && address.isNotEmpty) {
        state.currentAddress.value = address;
      }
    } catch (e) {
      Get.snackbar('Location Error', e.toString());
    } finally {
      state.isLoading.value = false;
    }
  }

  void onMapMoved(LatLng center) {
    state.pickedLatLng.value = center;
    _reverseGeocodeDebounce?.cancel();
    _reverseGeocodeDebounce = Timer(const Duration(milliseconds: 400), () {
      _reverseGeocodeCenter(center);
    });
  }

  Future<void> _reverseGeocodeCenter(LatLng center) async {
    state.isReverseGeocoding.value = true;
    final address = await locationApi.reverseGeocode(
      center.latitude,
      center.longitude,
    );
    state.pickedAddress.value = address ?? '';
    state.isReverseGeocoding.value = false;
  }
}
