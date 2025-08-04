import 'wallet_transaction.dart';

class Wallet {
  double balance;
  final List<WalletTransaction> transactions;

  Wallet({this.balance = 0, List<WalletTransaction>? transactions})
      : transactions = transactions ?? [];

  Wallet.fromJson(Map<String, dynamic> json)
      : balance = json['balance'],
        transactions = (json['transactions'] as List?)
                ?.map((e) => WalletTransaction.fromJson(e))
                .toList() ?? [];

  Map<String, dynamic> toJson() => {
        'balance': balance,
        'transactions': transactions.map((e) => e.toJson()).toList(),
      };
}
