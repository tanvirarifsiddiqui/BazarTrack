import 'dart:convert';

import 'package:flutter_boilerplate/features/auth/repository/auth_repo.dart';
import 'package:flutter_boilerplate/data/model/user/user.dart';
import 'package:flutter_boilerplate/data/model/user/role.dart';
import 'package:get/get.dart';

class AuthController extends GetxController implements GetxService {
  final AuthRepo authRepo;
  AuthController({required this.authRepo}) {
    loadUser();
  }

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  void loadUser() {
    final jsonString = authRepo.getUser();
    if (jsonString != null) {
      _currentUser = UserModel.fromJson(jsonDecode(jsonString));
    }
  }

  Future<void> signUp(UserModel user) async {
    await authRepo.signUp(jsonEncode(user.toJson()));
    _currentUser = user;
    update();
  }

  /// Save the login flag/token locally.
  Future<void> login() async {
    await authRepo.saveLogin();
    loadUser();
    update();
  }

  /// Remove the login flag/token.
  Future<void> logout() async {
    await authRepo.logout();
  }

  /// Whether the user is currently logged in.
  bool get isLoggedIn => authRepo.isLoggedIn();

  bool get isOwner => currentUser?.role == UserRole.owner;

  Future<void> saveUser(UserModel user) async {
    _currentUser = user;
    await authRepo.saveUser(jsonEncode(user.toJson()));
    update();
  }
}
