import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../adapter_models/monthly_report_model.dart';
import '../adapter_models/transaction_model.dart';
import '../view_model/auth_dir/finance_provider.dart';

/*
class SummaryCard extends StatelessWidget {
  final Box<TransactionModel> transactionBox;
  const SummaryCard({required this.transactionBox});

  @override
  Widget build(BuildContext context) {
    //   final transactions = transactionBox.values.toList();
    final now = DateTime.now();
    final transactions = transactionBox.values
        .where((tx) => tx.date.year == now.year && tx.date.month == now.month)
        .toList();

    final totalIncome = transactions
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    final totalExpense = transactions
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    // final balance = (totalIncome - totalExpense).clamp(0.0, double.infinity);
    // Use FutureBuilder to asynchronously fetch the balance from SharedPreferences

    return FutureBuilder<double>(
      future: _getCumulativeBalance(),
      builder: (context, snapshot) {
        double balance =
        (totalIncome - totalExpense).clamp(0.0, double.infinity);
        // Handle different states of the FutureBuilder
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          print("Error in Future Builder:${snapshot.error}");
          return const Center(
            child: Text("Error loading balance"),
          );
        } else if (snapshot.hasData) {
          // Add cumulative balance from reports to current balance
          balance=(snapshot.data!+(totalIncome-totalExpense)).clamp(0.0, double.infinity);

        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildSummaryTile(
                  label: 'Balance', amount: balance, color: Colors.teal),
              SizedBox(height: 10),
              _buildSummaryTile(
                  label: 'Income', amount: totalIncome, color: Colors.green),
              SizedBox(height: 10),
              _buildSummaryTile(
                  label: 'Expense', amount: totalExpense, color: Colors.red),
            ],
          ),
        );
      },
    );
  }
}
// Helper method to calculate cumulative balance from all reports

Future<double>_getCumulativeBalance() async{
  final reportBox=Hive.box<MonthlyReportModel>('monthlyReports');
  final cumulativeBalance=reportBox.values.fold(0.0, (sum,report)=>sum+report.remainingBudget);
  return cumulativeBalance;

}

Widget _buildSummaryTile(
    {required String label, required double amount, required Color color})
{
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
        Text(
          "Rs ${amount.toStringAsFixed(2)}",
          style: TextStyle(fontSize: 20, color: color),
        ),
      ],
    ),
  );
}*/

class SummaryCard extends StatelessWidget {
  final Box<TransactionModel> transactionBox;
  const SummaryCard({required this.transactionBox});

  @override
  Widget build(BuildContext context) {
    //   final transactions = transactionBox.values.toList();
    final now = DateTime.now();
    final transactions = transactionBox.values
        .where((tx) => tx.date.year == now.year && tx.date.month == now.month)
        .toList();

    final totalIncome = transactions
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    final totalExpense = transactions
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    // final balance = (totalIncome - totalExpense).clamp(0.0, double.infinity);
    // Use FutureBuilder to asynchronously fetch the balance from SharedPreferences
    final provider =
    Provider.of<FinanceTrackerProvider>(context, listen: false);

    return FutureBuilder<double>(
      future: provider.getCumulativeBalance(),
      builder: (context, snapshot) {
        double balance =
        (totalIncome - totalExpense).clamp(0.0, double.infinity);
        // Handle different states of the FutureBuilder
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          print("Error in Future Builder:${snapshot.error}");
          return const Center(
            child: Text("Error loading balance"),
          );
        } else if (snapshot.hasData) {
          // Add cumulative balance from reports to current balance
          balance = (snapshot.data! + (totalIncome - totalExpense))
              .clamp(0.0, double.infinity);
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildSummaryTile(
                  label: 'Balance', amount: balance, color: Colors.teal),
              SizedBox(height: 10),
              _buildSummaryTile(
                  label: 'Income', amount: totalIncome, color: Colors.green),
              SizedBox(height: 10),
              _buildSummaryTile(
                  label: 'Expense', amount: totalExpense, color: Colors.red),
            ],
          ),
        );
      },
    );
  }
}
// Helper method to calculate cumulative balance from all reports

Widget _buildSummaryTile(
    {required String label, required double amount, required Color color}) {
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
        Text(
          "Rs ${amount.toStringAsFixed(2)}",
          style: TextStyle(fontSize: 20, color: color),
        ),
      ],
    ),
  );
}
