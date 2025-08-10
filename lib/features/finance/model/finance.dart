// lib/features/finance/model/finance.dart

class Finance {
  int?      id;
  int       userId;
  double    amount;
  String    type;      // “credit” or “debit” or “wallet”
  DateTime  createdAt;

  Finance({
    this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.createdAt,
  });

  factory Finance.fromJson(Map<String, dynamic> json) {
    // JSON might give 'amount' as num or String
    final raw = json['amount'];
    final double amt = (raw is num)
        ? raw.toDouble()
        : double.tryParse(raw.toString()) ?? 0.0;

    return Finance(
      id:        json['id'] as int?,
      userId:    json['user_id'] as int,
      amount:    amt,
      type:      json['type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id':       userId,
      'amount':        amount,
      'type':          type,
      'created_at':    createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonForCreate() {
    return {
      'user_id': userId,
      'amount':  amount,
      'type':    type,
    };
  }
}
