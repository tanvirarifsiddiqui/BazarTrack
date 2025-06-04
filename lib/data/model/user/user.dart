import '../wallet/wallet.dart';
import 'role.dart';

class UserModel {
  final String id;
  final String name;
  final UserRole role;
  final Wallet wallet;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    Wallet? wallet,
  }) : wallet = wallet ?? Wallet();

  UserModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        role = UserRole.values.firstWhere(
            (e) => e.toString() == json['role'],
            orElse: () => UserRole.assistant),
        wallet = Wallet.fromJson(json['wallet']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role.toString(),
        'wallet': wallet.toJson(),
      };
}
