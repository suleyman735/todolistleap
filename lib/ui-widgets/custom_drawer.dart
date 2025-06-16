import 'package:flutter/material.dart';
import 'package:todolistleap/core/constant/colors.dart';
import 'package:todolistleap/core/constant/typography.dart';
import 'package:todolistleap/ui-widgets/user_profile_widget.dart';


class CustomDrawer extends StatelessWidget {
  final String? username;
  final VoidCallback onLogout;

  const CustomDrawer({super.key, this.username, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: UserProfileWidget(
              username: username,
              style: AppTypography.headlineMedium.copyWith(color: Colors.white),
              subtitle: Text(
                'Logged in',
                style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.text),
            title: Text('Logout', style: AppTypography.bodyMedium),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}