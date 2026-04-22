import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rider_app/core/theme/app_theme.dart';
import 'package:rider_app/features/auth/logic/auth_controller.dart';
import 'package:rider_app/features/auth/components/otp_box.dart';

class OtpView extends StatelessWidget {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: const Text(
                    '← Back',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock, color: AppTheme.primaryColor, size: 24),
              ),
              const SizedBox(height: 20),
              const Text(
                'Verification Code',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the 6-digit code sent to\n+976 ${controller.state.phone.value}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textTertiary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),

              OtpBox(
                onCompleted: (code) {
                  controller.state.otpCode.value = code;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Didn't receive the code? Resend in 0:45",
                style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
              ),
              const SizedBox(height: 28),

              Obx(() => ElevatedButton(
                    onPressed: controller.state.isLoading.value
                        ? null
                        : controller.verifyOtp,
                    child: controller.state.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Verify'),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
