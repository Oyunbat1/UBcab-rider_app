import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rider_app/core/theme/app_theme.dart';
import 'package:rider_app/features/auth/logic/auth_controller.dart';
import 'package:rider_app/features/auth/components/phone_input_field.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

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
              const SizedBox(height: 36),
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_taxi, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 8),
              const Text(
                'RideNow',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const Text(
                'Your ride, just a tap away',
                style: TextStyle(fontSize: 13, color: AppTheme.textTertiary),
              ),
              const SizedBox(height: 40),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Enter your phone number',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "We'll send you a verification code",
                  style: TextStyle(fontSize: 13, color: AppTheme.textTertiary),
                ),
              ),
              const SizedBox(height: 24),

              PhoneInputField(
                onChanged: (value) => controller.state.phone.value = value,
              ),
              const SizedBox(height: 20),

              Obx(() => ElevatedButton(
                    onPressed: controller.state.isLoading.value
                        ? null
                        : controller.sendOtp,
                    child: controller.state.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Continue'),
                  )),
              const Spacer(),

              const Padding(
                padding: EdgeInsets.only(bottom: 32),
                child: Text(
                  'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
