import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationState {

  final currentPosition = Rx<Position?>(null);

  final currentAddress = ''.obs;

  final pickedLatLng = Rx<LatLng?>(null);
  final pickedAddress = ''.obs;

  // Loading flag-uud
  final isLoading = false.obs;
  final isReverseGeocoding = false.obs;
}
