import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class LocationState {
  final currentPosition = Rx<Position?>(null);
  final pickedLocation = Rx<Position?>(null);
  final isLoading = false.obs;
}
