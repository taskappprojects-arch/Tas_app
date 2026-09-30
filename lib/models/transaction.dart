import 'dart:convert';

class TransactionModel {
  final String id;
  final DateTime date;
  final double amount;
  final bool isIncome;
  final String note;

  TransactionModel({
    required this.id,
    required this.date,
    required this.amount,
    required this.isIncome,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'isIncome': isIncome,
      'note': note,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      date: DateTime.parse(map['date']),
      amount: map['amount'],
      isIncome: map['isIncome'],
      note: map['note'],
    );
  }

  String toJson() => json.encode(toMap());
  factory TransactionModel.fromJson(String source) => TransactionModel.fromMap(json.decode(source));
}
