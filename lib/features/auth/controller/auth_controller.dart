import 'package:flutter_boilerplate/features/auth/repository/auth_repo.dart';

class AuthController {
  final AuthRepo authRepo;
  AuthController({required this.authRepo});

  void login() {
    String token = authRepo.login();
  }
}