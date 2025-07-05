import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_financial_tracker_app/models/transaction_model.dart';

class SummaryCard extends StatelessWidget {
  final Box<TransactionModel> transactionBox;
  const SummaryCard({required this.transactionBox});

  @override
  Widget build(BuildContext context) {
 //   final transactions = transactionBox.values.toList();
    final now = DateTime.now();
    final transactions = transactionBox.values.where((tx) =>
    tx.date.year == now.year && tx.date.month == now.month).toList();

    final totalIncome = transactions
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    final totalExpense = transactions
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    final balance = (totalIncome - totalExpense).clamp(0.0, double.infinity);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        mainAxisAlignment:MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSummaryTile(label: 'Balance', amount: balance, color: Colors.teal
          ),
          SizedBox(height: 10),
          _buildSummaryTile(label: 'Income', amount: totalIncome, color: Colors.green
          ),
          SizedBox(height: 10),
          _buildSummaryTile(label: 'Expense', amount: totalExpense , color: Colors.red
          ),

        ],
      ),
    );
  }
}


/*class SummaryCard extends StatelessWidget {
  final Box<TransactionModel> transactionBox;
  const SummaryCard({required this.transactionBox});

  @override
  Widget build(BuildContext context) {
    final transactions = transactionBox.values.toList();

    final totalIncome = transactions.where((tx) => tx.isIncome).fold(0.0, (sum, tx) => sum + tx.amount);
    final totalExpense = transactions.where((tx) => !tx.isIncome).fold(0.0, (sum, tx) => sum + tx.amount);
    final balance = (totalIncome - totalExpense).clamp(0.0, double.infinity);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSummaryTile(label: 'Balance', amount: balance, color: Colors.teal),
          SizedBox(height: 10),
          _buildSummaryTile(label: 'Income', amount: totalIncome, color: Colors.green),
          SizedBox(height: 10),
          _buildSummaryTile(label: 'Expense', amount: totalExpense, color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildSummaryTile({
    required String label,
    required double amount,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 120, vertical: 70),
      margin: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          SizedBox(height: 6),
          Text(
            "Rs ${amount.toStringAsFixed(2)}",
            style: TextStyle(fontSize: 20, color: color),
          ),
        ],
      ),
    );
  }
}*/
Widget _buildSummaryTile({
  required String label,
  required double amount,
  required Color color}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 120, vertical: 70),
    margin: EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: color.withOpacity(0.4),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        SizedBox(height: 6),
        Text("Rs ${amount.toStringAsFixed(2)}",
          style: TextStyle(fontSize: 20, color: color),
        ),
      ],
    ),
  );
}
