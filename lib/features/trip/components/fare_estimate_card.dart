import 'package:flutter/material.dart';
import 'package:rider_app/core/theme/app_theme.dart';

class FareEstimateCard extends StatelessWidget {
  final String pickupAddress;
  final String dropoffAddress;
  final int fare;
  final String distance;
  final String eta;
  final VoidCallback onRequestRide;
  final bool isLoading;

  const FareEstimateCard({
    super.key,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.fare,
      required this.distance,
      required this.eta,
      required this.onRequestRide,
      this.isLoading = false,
    });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4))],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(color: const Color(0xFFDDDDDD), borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(Icons.circle, size: 8, color: AppTheme.primaryColor),
              const SizedBox(width: 10),
              Expanded(child: Text(pickupAddress, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Container(height: 14, decoration: const BoxDecoration(border: Border(left: BorderSide(color: Color(0xFFCCCCCC), width: 2, style: BorderStyle.solid)))),
          ),
          Row(
            children: [
              Icon(Icons.circle, size: 8, color: Colors.red.shade600),
              const SizedBox(width: 10),
              Expanded(child: Text(dropoffAddress, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
            ],
          ),
          const Divider(height: 24),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              border: Border.all(color: AppTheme.primaryColor, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Standard', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text('$eta away - $distance', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
                Text(
                  '₮ ${fare.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Cash payment', style: TextStyle(fontSize: 13, color: Color(0xFF666666))),
              Text('Change >', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.primaryColor)),
            ],
          ),
          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: isLoading ? null : onRequestRide,
            child: isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Request Ride'),
          ),
        ],
      ),
    );
  }
}
