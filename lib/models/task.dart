import 'dart:convert';

class Task {
  final String id;
  String title;
  bool isCompleted;
  String? category; // Personal, Work, Other
  int rewardCoins;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.category = 'Other',
    this.rewardCoins = 10,
  });

  // Convert a Task to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'category': category,
      'rewardCoins': rewardCoins,
    };
  }

  // Create a Task from a map
  factory Task.fromMap(Map<dynamic, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'] ?? false,
      category: map['category'] ?? 'Other',
      rewardCoins: map['rewardCoins'] ?? 10,
    );
  }

  // Convert a Task to a JSON string
  String toJson() => json.encode(toMap());

  // Create a Task from a JSON string
  factory Task.fromJson(String source) => Task.fromMap(json.decode(source));
}
