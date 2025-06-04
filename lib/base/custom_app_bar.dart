import 'package:flutter_boilerplate/util/dimensions.dart';
import 'package:flutter_boilerplate/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isBackButtonExist;
  final Function? onBackPressed;
  final bool showCart;
  const CustomAppBar({super.key, required this.title, this.isBackButtonExist = true, this.onBackPressed, this.showCart = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyMedium!.color)),
      centerTitle: true,
      leading: isBackButtonExist ? IconButton(
        icon: Icon(Icons.arrow_back_ios),
        color: Theme.of(context).textTheme.bodyMedium!.color,
        onPressed: () => onBackPressed != null ? onBackPressed!() : Navigator.pop(context),
      ) : SizedBox(),
      backgroundColor: Theme.of(context).cardColor,
      elevation: 0,
      // actions: showCart ? [
      //   IconButton(onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
      //     icon: CartWidget(color: Theme.of(context).textTheme.bodyText1.color, size: 25),
      //   )] : null,
    );
  }

  @override
  Size get preferredSize => Size(1500, GetPlatform.isDesktop ? 70 : 50);
}