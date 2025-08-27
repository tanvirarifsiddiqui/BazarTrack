import 'package:get/get.dart';
import '../model/role.dart';
import '../model/user.dart';
import '../service/auth_service.dart';

class AuthController extends GetxController {
  final AuthService authService;

  /// Holds the currently authenticated user (null if not logged in)
  final user = Rxn<UserModel>();

  // Loading flag for user creation
  final isCreatingUser = false.obs;

  AuthController({ required this.authService });

  @override
  void onInit() {
    super.onInit();
    // Initialize with any user already in the AuthService
    user.value = authService.currentUser;
  }

  bool get isLoggedIn => user.value != null;

  bool get isOwner => user.value?.role == UserRole.owner;

  /// Create a new user (owner or assistant)
  Future<UserModel?> createUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    isCreatingUser.value = true;
    try {
      final newUser = await authService.createUser(
        name:     name,
        email:    email,
        password: password,
        role:     role.toApi(),
      );
      // Optionally, you could refresh some list of users here
      return newUser;
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
      return null;
    } finally {
      isCreatingUser.value = false;
    }
  }

  Future<void> loadUser() async {
    await authService.loadUser();
    user.value = authService.currentUser;
  }

  Future<bool> login(String email, String password) async {
    final success = await authService.login(email, password);
    if (success) {
      user.value = authService.currentUser;
    }
    return success;
  }

  Future<void> signUp(UserModel newUser) async {
    await authService.signUp(newUser);
    user.value = authService.currentUser;
  }

  Future<void> logout() async {
    await authService.logout();
    user.value = null;
  }
}
