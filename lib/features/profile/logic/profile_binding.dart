import 'package:get/get.dart';
import 'package:rider_app/features/profile/logic/profile_api.dart';
import 'package:rider_app/features/profile/logic/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileApi());
    Get.lazyPut(() => ProfileController(profileApi: Get.find<ProfileApi>()));
  }
}
