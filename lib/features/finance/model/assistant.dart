class Assistant {
  final int    id;
  final String name;
  final double? balance;

  Assistant({ required this.id, required this.name, this.balance });

  factory Assistant.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v is int)    return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }
    double? parseBalance(dynamic v) {
      if (v == null)   return null;
      if (v is num)    return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    return Assistant(
      id:      parseInt(json['id']),
      name:    json['name'] as String,
      balance: parseBalance(json['balance']),
    );
  }
}