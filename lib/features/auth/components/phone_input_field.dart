import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneInputField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String? initialValue;

  const PhoneInputField({
    super.key,
    required this.onChanged,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text(
            '🇲🇳 +976',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 24, color: const Color(0xFFDDDDDD)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
              ],
              decoration: const InputDecoration(
                hintText: '9911 2233',
                hintStyle: TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
