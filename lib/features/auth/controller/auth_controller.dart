import 'package:flutter_boilerplate/features/auth/repository/auth_repo.dart';

class AuthController {
  final AuthRepo authRepo;

  AuthController({required this.authRepo});

  /// Save the login flag/token locally.
  Future<void> login() async {
    await authRepo.saveLogin();
  }

  /// Remove the login flag/token.
  Future<void> logout() async {
    await authRepo.logout();
  }

  /// Whether the user is currently logged in.
  bool get isLoggedIn => authRepo.isLoggedIn();
}
