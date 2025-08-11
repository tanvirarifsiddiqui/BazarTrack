class Finance {
  int?      id;
  int       userId;
  double    amount;
  String    type;       // “credit” or “debit”
  DateTime  createdAt;

  Finance({
    this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.createdAt,
  });

  factory Finance.fromJson(Map<String, dynamic> json) {
    // parse ints or strings
    int parseInt(dynamic v) {
      if (v is int)    return v;
      if (v is String) return int.tryParse(v) ?? 0;
      if (v is double) return v.toInt();
      return 0;
    }
    // parse amount (num or String)
    double parseAmt(dynamic v) {
      if (v is num)    return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    return Finance(
      id:        json['id'] != null  ? parseInt(json['id']) : null,
      userId:    parseInt(json['user_id']),
      amount:    parseAmt(json['amount']),
      type:      json['type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJsonForCreate() {
    return {
      'user_id': userId,
      'amount':  amount,
      'type':    type,
    };
  }
}