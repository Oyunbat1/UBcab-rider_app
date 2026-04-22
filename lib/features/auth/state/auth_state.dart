import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthState {
  final phone = ''.obs;
  final otpCode = ''.obs;
  final isLoading = false.obs;
  final verificationId = ''.obs;
  final currentUser = Rx<User?>(null);
}
