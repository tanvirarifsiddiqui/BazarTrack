import 'dart:convert';

import 'package:flutter_boilerplate/features/auth/repository/auth_repo.dart';
import 'package:flutter_boilerplate/data/model/user/user.dart';

class AuthController {
  final AuthRepo authRepo;

  AuthController({required this.authRepo});

  UserModel? get currentUser {
    final jsonString = authRepo.getUser();
    if (jsonString == null) return null;
    return UserModel.fromJson(jsonDecode(jsonString));
  }

  Future<void> signUp(UserModel user) async {
    await authRepo.signUp(jsonEncode(user.toJson()));
  }

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

  bool get isOwner => currentUser?.role == UserRole.owner;
}
