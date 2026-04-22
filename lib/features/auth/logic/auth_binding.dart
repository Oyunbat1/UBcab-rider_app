import 'package:get/get.dart';
import 'package:rider_app/features/auth/logic/auth_api.dart';
import 'package:rider_app/features/auth/logic/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // AuthApi and AuthController are registered permanently in main.dart
    // No need to re-register here
  }
}
