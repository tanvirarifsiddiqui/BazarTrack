import 'package:flutter_boilerplate/util/colors.dart';
import 'package:flutter_boilerplate/util/dimensions.dart';
import 'package:flutter_boilerplate/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  const CustomAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: robotoRegular.copyWith(
          fontSize: Dimensions.fontSizeAppbar,
          fontWeight: FontWeight.w400,
          // color: Theme.of(context).textTheme.bodyMedium!.color,
          color: Colors.white,
        ),
      ),
      actions: actions,
      centerTitle: true,
      backgroundColor: AppColors.primary,
      iconTheme: IconThemeData(
        color: Colors.white
      ),

    );
  }

  @override
  Size get preferredSize => Size(1500, GetPlatform.isDesktop ? 70 : 50);
}
