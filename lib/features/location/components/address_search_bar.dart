import 'package:flutter/material.dart';

class AddressSearchBar extends StatelessWidget {
  final VoidCallback? onTap;

  const AddressSearchBar({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, size: 18, color: Color(0xFF999999)),
            SizedBox(width: 10),
            Text(
              'Where to?',
              style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
            ),
          ],
        ),
      ),
    );
  }
}
