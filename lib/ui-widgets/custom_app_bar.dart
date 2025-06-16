import 'package:flutter/material.dart';
import 'package:todolistleap/core/constant/colors.dart';
import 'package:todolistleap/core/constant/typography.dart';
import 'package:todolistleap/ui-widgets/user_profile_widget.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? username;
  final VoidCallback? onProfileTap;

  const CustomAppBar({super.key, this.username, this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      // leading: IconButton(
      //   icon: const Icon(Icons.menu, color: AppColors.text),
      //   onPressed: () {},
      // ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            onTap: onProfileTap,
            child: UserProfileWidget(
              username: username,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.text),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}