import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rider_app/core/theme/app_theme.dart';

class OtpBox extends StatefulWidget {
  final ValueChanged<String> onCompleted;

  const OtpBox({super.key, required this.onCompleted});

  @override
  State<OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<OtpBox> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    final code = _controllers.map((c) => c.text).join();
    if (code.length == 6) {
      widget.onCompleted(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Container(
          width: 42,
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            onChanged: (value) => _onChanged(index, value),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: const Color(0xFFF7F7F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE8E8E8), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
        );
      }),
    );
  }
}
