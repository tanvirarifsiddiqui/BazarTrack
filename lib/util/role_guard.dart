import 'package:flutter_boilerplate/features/auth/controller/auth_controller.dart';
import 'package:get/get.dart';

class RoleGuard {
  static bool ensureOwner() {
    final auth = Get.find<AuthController>();
    if (!auth.isOwner) {
      Get.snackbar('Access Denied', 'Only owners can perform this action');
      return false;
    }
    return true;
  }
}
