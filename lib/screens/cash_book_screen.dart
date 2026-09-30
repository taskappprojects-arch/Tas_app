import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/models/transaction.dart';
import 'package:todo_app/providers/finance_provider.dart';
import 'package:todo_app/providers/language_provider.dart';

class CashBookScreen extends StatefulWidget {
  const CashBookScreen({super.key});

  @override
  State<CashBookScreen> createState() => _CashBookScreenState();
}

class _CashBookScreenState extends State<CashBookScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final DateTime _selectedDate = DateTime.now();
  bool _isIncome = true;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _addTransaction(BuildContext context, LanguageProvider lang) {
    if (_amountController.text.isEmpty) return;
    
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) return;

    final transaction = TransactionModel(
      id: DateTime.now().toString(),
      date: _selectedDate,
      amount: amount,
      isIncome: _isIncome,
      note: _noteController.text.isEmpty ? (_isIncome ? lang.translate('income') : lang.translate('expense')) : _noteController.text,
    );

    Provider.of<FinanceProvider>(context, listen: false).addTransaction(transaction);
    
    _amountController.clear();
    _noteController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final finance = Provider.of<FinanceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('cash_book')),
      ),
      body: CustomScrollView(
        slivers: [
          // Summary Card
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(lang.translate('balance'), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('₹ ${finance.balance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryItem(lang.translate('income'), finance.totalIncome, Colors.greenAccent),
                      _buildSummaryItem(lang.translate('expense'), finance.totalExpense, Colors.redAccent),
                    ],
                  )
                ],
              ),
            ),
          ),

          // Add Transaction Form
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: lang.translate('amount'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        hintText: lang.translate('description'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: const SizedBox(height: 12),
          ),
          
          // Segmented Buttons & Add Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(value: true, label: Text(lang.translate('income'), style: const TextStyle(color: Colors.green))),
                        ButtonSegment(value: false, label: Text(lang.translate('expense'), style: const TextStyle(color: Colors.red))),
                      ],
                      selected: {_isIncome},
                      onSelectionChanged: (Set<bool> newSelection) {
                        setState(() {
                          _isIncome = newSelection.first;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _addTransaction(context, lang),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(lang.translate('add')),
                  )
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: const SizedBox(height: 20),
          ),
          
          // Transaction List
          finance.allTransactions.isEmpty
              ? SliverFillRemaining(
                  child: Center(child: Text(lang.translate('no_transactions'), style: const TextStyle(color: Colors.grey))),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final t = finance.allTransactions[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: t.isIncome ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                          child: Icon(
                            t.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                            color: t.isIncome ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(t.note, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a').format(t.date)),
                        trailing: Text(
                          '${t.isIncome ? '+' : '-'} ₹${t.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: t.isIncome ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onLongPress: () => finance.deleteTransaction(t.id),
                      );
                    },
                    childCount: finance.allTransactions.length,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text('₹ ${amount.toStringAsFixed(0)}', style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
