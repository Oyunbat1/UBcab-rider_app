import 'package:get/get.dart';
import 'package:rider_app/app/routes/app_routes.dart';
import 'package:rider_app/features/auth/state/auth_state.dart';
import 'package:rider_app/features/auth/logic/auth_api.dart';

class AuthController extends GetxController {
  final AuthApi authApi;
  final state = AuthState();

  AuthController({required this.authApi});

  @override
  void onInit() {
    super.onInit();
    state.currentUser.value = authApi.currentUser;
  }

  /// Hereglegch newtersen esehiig shalgah
  void checkSession() {
    Future.delayed(const Duration(seconds: 2), () {
      if (authApi.currentUser != null) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    });
  }

  /// Utasnii dugaarluu otp ywuulah
  Future<void> sendOtp() async {
    final phone = state.phone.value.trim();
    if (phone.isEmpty) return;

    state.isLoading.value = true;

    final fullPhone = phone.startsWith('+') ? phone : '+976$phone';

    await authApi.sendOtp(
      phone: fullPhone,
      onCodeSent: (verificationId) {
        state.verificationId.value = verificationId;
        state.isLoading.value = false;
        Get.toNamed(AppRoutes.otp);
      },
      onError: (error) {
        state.isLoading.value = false;
        Get.snackbar('Error', error);
      },
    );
  }

  /// OTP code batalgaajuulah
  Future<void> verifyOtp() async {
    final code = state.otpCode.value.trim();
    if (code.length != 6) return;

    state.isLoading.value = true;

    try {
      final result = await authApi.verifyOtp(
        verificationId: state.verificationId.value,
        otpCode: code,
      );

     // hereglegchin medeelel doc-d hadgalah
      await authApi.saveUserDoc(
        uid: result.user!.uid,
        phone: result.user!.phoneNumber ?? '',
      );

      state.currentUser.value = result.user;
      state.isLoading.value = false;

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      state.isLoading.value = false;
      Get.snackbar('Error', 'Invalid OTP code');
    }
  }

  Future<void> signOut() async {
    await authApi.signOut();
    state.currentUser.value = null;
    Get.offAllNamed(AppRoutes.login);
  }
}
