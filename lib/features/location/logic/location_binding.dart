import 'package:get/get.dart';
import 'package:rider_app/features/location/logic/location_api.dart';
import 'package:rider_app/features/location/logic/location_controller.dart';

class LocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LocationApi());
    Get.lazyPut(() => LocationController(locationApi: Get.find<LocationApi>()));
  }
}
