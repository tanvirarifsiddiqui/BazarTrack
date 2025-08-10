import 'package:flutter_boilerplate/features/auth/model/user.dart';
import 'package:flutter_boilerplate/features/auth/service/auth_service.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final AuthService authService;
  AuthController({required this.authService});

  UserModel? get currentUser => authService.currentUser;

  void loadUser() {
    authService.loadUser();
    update();
  }

  Future<void> signUp(UserModel user) async {
    await authService.signUp(user);
    update();
  }
  Future<bool> login(String email, String password) {
    return authService.login(email, password);
  }

  Future<void> logout() async {
    await authService.logout();
    update();
  }

  bool get isLoggedIn => authService.isLoggedIn;

  bool get isOwner => authService.isOwner;

  Future<void> saveUser(UserModel user) async {
    await authService.saveUser(user);
    update();
  }
}
