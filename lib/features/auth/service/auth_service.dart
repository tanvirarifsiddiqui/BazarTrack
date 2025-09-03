import 'dart:convert';

import 'package:flutter_boilerplate/features/auth/model/role.dart';
import 'package:flutter_boilerplate/features/auth/model/user.dart';
import 'package:flutter_boilerplate/features/auth/repository/auth_repo.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final AuthRepo authRepo;
  AuthService({required this.authRepo}) {
    loadUser();
  }

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  Future<UserModel?> loadUser() async {
    final jsonString = authRepo.getUser();
    if (jsonString != null) {
      _currentUser = UserModel.fromJson(jsonDecode(jsonString));
    }
    return _currentUser;
  }


  Future<void> signUp(UserModel user) async {
    await authRepo.signUp(jsonEncode(user.toJson()));
    _currentUser = user;
  }

// Returns true if login succeeded
  Future<bool> login(String email, String password) async {
    final response = await authRepo.login(email, password);
    if (response.isOk) {
      loadUser();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await authRepo.logout();
  }

  bool get isLoggedIn => authRepo.isLoggedIn();

  bool get isOwner => currentUser?.role == UserRole.owner;

  Future<void> saveUser(UserModel user) async {
    _currentUser = user;
    await authRepo.saveUser(jsonEncode(user.toJson()));
  }

  Future<UserModel> createUser({
    required String name,
    required String email,
    required String password,
    required String role,  // “owner” or “assistant”
  }) async {
    final user = await authRepo.createUser(name: name, email: email, password: password, role: role);
    return user;
  }

  Future<void> updatePassword({required String currentPassword, required String newPassword}) async {
    authRepo.updatePassword(currentPassword: currentPassword, newPassword: newPassword);
  }

}
