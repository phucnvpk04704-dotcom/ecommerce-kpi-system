import 'package:flutter/material.dart';

class EmployeeAvatar extends StatelessWidget {
  final String avatar;
  final String fullName;
  final double radius;

  const EmployeeAvatar({
    super.key,
    required this.avatar,
    required this.fullName,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = avatar.startsWith('http') || avatar.contains('/');

    String initials = avatar;
    if (!hasImage && initials.length > 2) {
      initials = initials.substring(0, 2);
    }
    if (initials.isEmpty && fullName.isNotEmpty) {
      final parts = fullName.trim().split(' ');
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
      } else {
        initials = fullName.substring(0, fullName.length < 2 ? fullName.length : 2).toUpperCase();
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: hasImage ? Colors.transparent : const Color(0xFFFF5722).withAlpha(26),
      backgroundImage: hasImage ? NetworkImage(avatar) : null,
      child: hasImage
          ? null
          : Text(
              initials.isEmpty ? 'EM' : initials,
              style: TextStyle(
                color: const Color(0xFFFF5722),
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.75,
              ),
            ),
    );
  }
}
