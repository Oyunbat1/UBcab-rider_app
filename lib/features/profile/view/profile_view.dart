import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rider_app/core/theme/app_theme.dart';
import 'package:rider_app/features/auth/logic/auth_controller.dart';
import 'package:rider_app/features/profile/logic/profile_controller.dart';
import 'package:rider_app/features/profile/components/avatar_widget.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        centerTitle: true,
        title: const Text('Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Obx(() => Column(
          children: [
            // Avatar + name
            const SizedBox(height: 4),
            AvatarWidget(size: 64, photoUrl: controller.state.photoUrl.value),
            const SizedBox(height: 10),
            Text(
              controller.state.name.value.isEmpty ? 'Rider' : controller.state.name.value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              controller.state.phone.value,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 14),

            // Stats card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem('${controller.state.totalTrips.value}', 'Trips'),
                  _statItem('⭐ ${controller.state.rating.value.toStringAsFixed(1)}', 'Rating'),
                  _statItem('₮ ${(controller.state.totalSpent.value / 1000).toStringAsFixed(0)}K', 'Spent'),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Menu items
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                children: [
                  _menuItem(Icons.person, 'Edit Profile'),
                  _divider(),
                  _menuItem(Icons.location_on, 'Saved Places'),
                  _divider(),
                  _menuItem(Icons.history, 'Ride History'),
                  _divider(),
                  _menuItem(Icons.credit_card, 'Payment Methods'),
                  _divider(),
                  _menuItem(Icons.notifications, 'Notifications'),
                  _divider(),
                  _menuItem(Icons.settings, 'Settings'),
                  _divider(),
                  _menuItem(Icons.help_outline, 'Help & Support'),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Logout
            OutlinedButton(
              onPressed: () {
                Get.find<AuthController>().signOut();
              },
              child: const Text('Log Out'),
            ),
            const SizedBox(height: 24),
          ],
        )),
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _menuItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 15, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
          const Icon(Icons.chevron_right, size: 16, color: Color(0xFFCCCCCC)),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: AppTheme.dividerColor),
    );
  }
}
