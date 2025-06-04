import 'dart:async';

import 'package:flutter_boilerplate/controller/splash_controller.dart';
import 'package:flutter_boilerplate/features/auth/sign_in_screen.dart';
import 'package:flutter_boilerplate/helper/route_helper.dart';
import 'package:flutter_boilerplate/util/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 2), () {
      if(Get.find<SplashController>().existToken()) {
        Get.to(Dashbord);
      }else {
        Get.to(SignInScreen());
      }
    });

    Get.find<SplashController>().initSharedData();
    _route();

  }

  void _route() {
    Get.find<SplashController>().getConfigData().then((value) {
      Timer(Duration(seconds: 1), () async {
        Get.offNamed(RouteHelper.home);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(Images.logo, height: 175),
          ],
        ),
      ),
    );
  }
}
