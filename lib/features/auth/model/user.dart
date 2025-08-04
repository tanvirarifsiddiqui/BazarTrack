import 'package:flutter_boilerplate/features/finance/model/wallet.dart';
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
      : id = json['id'].toString(),
        name = json['name'],
        role = UserRoleExtension.fromString(json['role'] ?? 'assistant'),
        wallet = json['wallet'] != null
            ? Wallet.fromJson(json['wallet'])
            : Wallet();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role.toApi(),
        'wallet': wallet.toJson(),
      };
}
