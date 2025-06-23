import '../../../helper/date_converter.dart';

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
        date: DateConverter.parseApiDate(json['date']),
        givenBy: json['givenBy'],
        receivedBy: json['receivedBy'],
      );

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'date': DateConverter.formatApiDate(date),
        'givenBy': givenBy,
        'receivedBy': receivedBy,
      };
}
