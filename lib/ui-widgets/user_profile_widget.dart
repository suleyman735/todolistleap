import 'package:flutter/material.dart';
import 'package:todolistleap/core/constant/colors.dart';
import 'package:todolistleap/core/constant/typography.dart';

class UserProfileWidget extends StatelessWidget {
  final String? username;
  final TextStyle style;
  final Widget? subtitle;

  const UserProfileWidget({
    super.key,
    this.username,
    required this.style,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          username ?? 'User',
          style: style,
        ),
        const SizedBox(width: 8),
        // const CircleAvatar(
        //   radius: 20,
        //   backgroundColor: AppColors.primary,
        //   child: Icon(Icons.person, color: Colors.white, size: 24),
        // ),
        if (subtitle != null) ...[
          const SizedBox(width: 8),
          subtitle!,
        ],
      ],
    );
  }
}