import 'dart:async';
import 'package:flutter_boilerplate/features/auth/service/auth_service.dart';
import 'package:flutter_boilerplate/features/auth/sign_in_screen.dart';
import 'package:flutter_boilerplate/features/dashboard/assistant_dashboard.dart';
import 'package:flutter_boilerplate/features/dashboard/owner_dashboard.dart';
import 'package:flutter_boilerplate/features/auth/model/role.dart';
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

    Future.delayed(const Duration(seconds: 2), () {
      final auth = Get.find<AuthService>();
      if (auth.isLoggedIn) {
        final user = auth.currentUser;
        if (user?.role == UserRole.owner) {
          Get.offAll(const OwnerDashboard());
        } else {
          Get.offAll(const AssistantDashboard());
        }
      } else {
        Get.offAll(const SignInScreen());
      }
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
