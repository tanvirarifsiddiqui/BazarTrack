enum TransactionType { advance, purchase }

class WalletTransaction {
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String description;

  WalletTransaction({
    required this.amount,
    required this.type,
    required this.date,
    required this.description,
  });

  WalletTransaction.fromJson(Map<String, dynamic> json)
      : amount = json['amount'],
        type = TransactionType.values.firstWhere(
            (e) => e.toString() == json['type'],
            orElse: () => TransactionType.advance),
        date = DateTime.parse(json['date']),
        description = json['description'];

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'type': type.toString(),
        'date': date.toIso8601String(),
        'description': description,
      };
}
