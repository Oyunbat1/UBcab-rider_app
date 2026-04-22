import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rider_app/core/theme/app_theme.dart';

class LocationPickerView extends StatelessWidget {
  const LocationPickerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Choose destination',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.circle, size: 10, color: AppTheme.primaryColor),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Current location', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 10, color: Colors.red.shade600),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search destination',
                        hintStyle: TextStyle(color: Color(0xFF999999)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildPlaceItem(Icons.business, 'Central Tower', 'Sukhbaatar Square, UB'),
            _buildPlaceItem(Icons.home, 'Home', 'Bayangol district, 4th khoroo'),
            _buildPlaceItem(Icons.school, 'National University', 'Baga toiruu, UB'),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceItem(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F2F8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: AppTheme.primaryColor),
      ),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
      onTap: () {
        // TODO: Return selected location back
        Get.back(result: {'title': title, 'subtitle': subtitle});
      },
    );
  }
}
