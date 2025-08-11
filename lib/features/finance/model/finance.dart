class Finance {
  int?      id;
  int       userId;
  double    amount;
  String    type;      // credit | debit | wallet
  DateTime  createdAt;

  Finance({
    this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.createdAt,
  });

  factory Finance.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      if (v is double) return v.toInt();
      return null;
    }

    // parse amount whether num or String
    dynamic rawAmt = json['amount'];
    final amt = rawAmt is num
        ? rawAmt.toDouble()
        : double.tryParse(rawAmt.toString()) ?? 0.0;

    return Finance(
      id:        parseInt(json['id']),
      userId:    parseInt(json['user_id']) ?? 0,
      amount:    amt,
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