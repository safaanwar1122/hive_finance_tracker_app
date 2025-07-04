import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/monthly_report_model.dart'; // make sure the path is correct
import '../models/transaction_model.dart';
import '../widgets/app_drawer.dart';     // for transaction fields

class LastMonthReportScreen extends StatefulWidget {
  @override
  _LastMonthReportScreenState createState() => _LastMonthReportScreenState();
}

class _LastMonthReportScreenState extends State<LastMonthReportScreen> {
  MonthlyReportModel? _report;

  @override
  void initState() {
    super.initState();
    _loadLastMonthReport();
  }
  Future<void> _loadLastMonthReport() async {
    final now = DateTime.now();
    final prevMonth = DateTime(now.year, now.month - 1);
    final prevMonthKey = "${prevMonth.year}-${prevMonth.month.toString().padLeft(2, '0')}";

    final reportBox = Hive.box<MonthlyReportModel>('monthlyReports');
    final report = reportBox.get(prevMonthKey);

    // Debugging: Print all keys in monthlyReports box
    print("📋 Available report keys: ${reportBox.keys}");
    print("🔎 Trying to load report for $prevMonthKey");
    print("Found report? ${report != null}");
    if (report != null) {
      print("📊 Report Details: Income: ${report.income}, Expense: ${report.expense}, "
          "Transactions: ${report.transactions.length}");
    }

    setState(() {
      _report = report;
    });
  }
 /* Future<void> _loadLastMonthReport() async {
    final now = DateTime.now();
    final prevMonth = DateTime(now.year, now.month - 1);
    final prevMonthKey =
        "${prevMonth.year}-${prevMonth.month.toString().padLeft(2, '0')}";

    final reportBox = Hive.box<MonthlyReportModel>('monthlyReports');
    final report = reportBox.get(prevMonthKey);

    setState(() {
      _report = report;
    });
    print("🔎 Trying to load report for $prevMonthKey");
    print("Found report? ${report != null}");

  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Monthly Report"),
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _report == null
            ? Center(child: Text("No report found for last month."))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Month: ${_report!.monthKey}",
                style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Income: Rs ${_report!.income.toStringAsFixed(2)}"),
            Text("Expense: Rs ${_report!.expense.toStringAsFixed(2)}"),
            Text("Remaining Budget: Rs ${_report!.remainingBudget.toStringAsFixed(2)}"),
            SizedBox(height: 20),
            Text("Transactions:", style: TextStyle(fontSize: 18)),
            Expanded(
              child: ListView.builder(
                itemCount: _report!.transactions.length,
                itemBuilder: (context, index) {
                  final tx = _report!.transactions[index];
                  return ListTile(
                    title: Text(tx.category),
                    subtitle: Text(tx.date.toString()),
                    trailing: Text(
                      "Rs ${tx.amount.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: tx.isIncome ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
