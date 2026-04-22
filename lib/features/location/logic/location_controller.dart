import 'package:get/get.dart';
import 'package:rider_app/features/location/state/location_state.dart';
import 'package:rider_app/features/location/logic/location_api.dart';

class LocationController extends GetxController {
  final LocationApi locationApi;
  final state = LocationState();

  LocationController({required this.locationApi});

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    state.isLoading.value = true;
    final hasPermission = await locationApi.checkAndRequestPermission();
    if (!hasPermission) {
      state.isLoading.value = false;
      Get.snackbar('Permission', 'Location permission is required');
      return;
    }

    final position = await locationApi.getCurrentPosition();
    state.currentPosition.value = position;
    state.isLoading.value = false;
  }
}
