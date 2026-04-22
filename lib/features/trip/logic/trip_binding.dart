import 'package:get/get.dart';
import 'package:rider_app/features/trip/logic/trip_api.dart';
import 'package:rider_app/features/trip/logic/trip_controller.dart';
import 'package:rider_app/features/location/logic/location_api.dart';
import 'package:rider_app/features/location/logic/location_controller.dart';

class TripBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TripApi());
    Get.lazyPut(() => TripController(tripApi: Get.find<TripApi>()));
    Get.lazyPut(() => LocationApi());
    Get.lazyPut(() => LocationController(locationApi: Get.find<LocationApi>()));
  }
}
