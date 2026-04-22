import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rider_app/core/theme/app_theme.dart';
import 'package:rider_app/features/auth/logic/auth_controller.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.checkSession();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_taxi, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'RideNow',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your ride, just a tap away',
              style: TextStyle(fontSize: 14, color: AppTheme.textTertiary),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }
}
