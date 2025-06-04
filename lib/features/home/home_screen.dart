import 'package:flutter_boilerplate/controller/localization_controller.dart';
import 'package:flutter_boilerplate/controller/splash_controller.dart';
import 'package:flutter_boilerplate/controller/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/splash/splash_screen.dart';
import 'package:flutter_boilerplate/util/styles.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('home'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor)),
          TextButton(
            onPressed: () => Get.find<ThemeController>().toggleTheme(),
            child: Text('Toggle theme'),
          ),
          TextButton(
            onPressed: () {
              Get.to(SplashScreen());
              Get.find<LocalizationController>().setLanguage(Locale(
                Get.locale?.languageCode == 'en' ? 'ar' : 'en',
                Get.locale?.countryCode == 'US' ? 'SA' : 'US',
              ));
            },
            child: Text('Change Localization'),
          ),
        ]),
      ),
    );
  }
}
