import 'dart:convert';

class KhataModel {
  final String id;
  final String name;
  final String phone;
  final double amount; // Positive = You get, Negative = You owe
  final String? reason;

  KhataModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.amount,
    this.reason,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'amount': amount,
      'reason': reason,
    };
  }

  factory KhataModel.fromMap(Map<String, dynamic> map) {
    return KhataModel(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      amount: map['amount'],
      reason: map['reason'],
    );
  }

  String toJson() => json.encode(toMap());
  factory KhataModel.fromJson(String source) => KhataModel.fromMap(json.decode(source));
}
