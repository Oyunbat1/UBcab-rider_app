import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final double size;
  final String? photoUrl;

  const AvatarWidget({super.key, this.size = 64, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFDDE3F0),
        shape: BoxShape.circle,
      ),
      child: photoUrl != null && photoUrl!.isNotEmpty
          ? ClipOval(child: Image.network(photoUrl!, fit: BoxFit.cover))
          : Icon(Icons.person, size: size * 0.45, color: const Color(0xFF888888)),
    );
  }
}
