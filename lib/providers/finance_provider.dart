import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';

class FinanceProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  final Box<String> _financeBox = Hive.box<String>('financeBox');

  List<TransactionModel> get allTransactions => _transactions;
  
  double get totalIncome => _transactions.where((t) => t.isIncome).fold(0, (sum, item) => sum + item.amount);
  double get totalExpense => _transactions.where((t) => !t.isIncome).fold(0, (sum, item) => sum + item.amount);
  double get balance => totalIncome - totalExpense;

  FinanceProvider() {
    _loadData();
  }

  void _loadData() {
    final List<String> transactionsList = _financeBox.values.toList();
    _transactions = transactionsList.map((tStr) => TransactionModel.fromJson(tStr)).toList();
    
    // Sort by date descending (newest first)
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    
    notifyListeners();
  }

  void _saveData() {
    _financeBox.clear();
    for (var transaction in _transactions) {
      _financeBox.add(transaction.toJson());
    }
  }

  void addTransaction(TransactionModel transaction) {
    _transactions.insert(0, transaction);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    _saveData();
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    _saveData();
    notifyListeners();
  }
}
