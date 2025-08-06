import '../../../helper/date_converter.dart';
enum TransactionType { credit, debit }


class WalletTransaction {
  final double amount;
  final TransactionType type;
  final DateTime createdAt;
  final String description;

  WalletTransaction({
    required this.amount,
    required this.type,
    required this.createdAt,
    required this.description,
  });

  WalletTransaction.fromJson(Map<String, dynamic> json)
      : amount = (json['amount'] as num).toDouble(),
        type = json['type'] == 'debit' ? TransactionType.debit : TransactionType.credit,
        createdAt = json['created_at'] != null
            ? DateConverter.parseApiDate(json['created_at'])
            : DateConverter.parseApiDate(json['date']),
        description = json['description'] ?? '';

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'type': type == TransactionType.debit ? 'debit' : 'credit',
        'created_at': DateConverter.formatApiDate(createdAt),
        'description': description,
      };
}
