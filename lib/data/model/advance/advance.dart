class Advance {
  final double amount;
  final DateTime date;
  final String givenBy;
  final String receivedBy;

  Advance({
    required this.amount,
    required this.date,
    required this.givenBy,
    required this.receivedBy,
  });

  factory Advance.fromJson(Map<String, dynamic> json) => Advance(
        amount: json['amount'],
        date: DateTime.parse(json['date']),
        givenBy: json['givenBy'],
        receivedBy: json['receivedBy'],
      );

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'date': date.toIso8601String(),
        'givenBy': givenBy,
        'receivedBy': receivedBy,
      };
}
