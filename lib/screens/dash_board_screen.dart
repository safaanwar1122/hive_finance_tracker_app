import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_financial_tracker_app/models/monthly_report_model.dart';
import 'package:hive_financial_tracker_app/models/transaction_model.dart';
import 'package:hive_financial_tracker_app/screens/category_screen.dart';
import 'package:hive_financial_tracker_app/widgets/app_drawer.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth_dir/auth_service.dart';
import '../widgets/summary_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final Box<TransactionModel> transactionBox;
  Timer? _reportTimer;

  @override
  void initState() {
    super.initState();
    transactionBox = Hive.box<TransactionModel>('transactions');
    _startReportGenerationTimer();
  }

  void _startReportGenerationTimer() {
    // Generate report immediately on init
    _checkTimeChangeAndGenerateReport();
    // Set up a timer to generate report every 2 minutes
    _reportTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _checkTimeChangeAndGenerateReport();
    });
  }

  Future<void> _checkTimeChangeAndGenerateReport() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckedTime = prefs.getInt('lastReportTime') ?? 0;
    final now = DateTime.now();
    final currentTimestamp = now.millisecondsSinceEpoch;

    // Skip if report was generated within the last 2 minutes
    if (lastCheckedTime > now.subtract(const Duration(minutes: 2)).millisecondsSinceEpoch) return;

    final box = Hive.box<TransactionModel>('transactions');
    final reportBox = Hive.box<MonthlyReportModel>('monthlyReports');
    // Use a simpler report key format: YYYY-MM-DD_HH-mm
    final reportKey = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}_2minutes";

    // Filter transactions for the current day (from midnight to now)
    final startTime = DateTime(now.year, now.month, now.day); // Midnight of current day
    final recentTransactions = box.values
        .where((tx) => tx.date.isAfter(startTime) && tx.date.isBefore(now))
        .toList();

    // Calculate totals
    final totalIncome = recentTransactions
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    final totalExpense = recentTransactions
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    final remainingBudget = totalIncome - totalExpense;

    // Store in Hive report box
    await reportBox.put(
      reportKey,
      MonthlyReportModel(
        monthKey: reportKey,
        transactions: recentTransactions,
        income: totalIncome,
        expense: totalExpense,
        remainingBudget: remainingBudget,
      ),
    );
// Store the current report's remaining budget and set reportGenerated flag
    // Store the current report's remaining budget in SharedPreferences
    await prefs.setDouble('latestReportBalance', remainingBudget);
   // await prefs.setBool('reportGenerated', true); // Set flag to true
    print("💰 Set latest report balance: $remainingBudget");

    // Clear all transactions from the transactions box
    await box.clear();
    print("🗑️ Cleared all transactions from transactions box after report generation.");

    // Update last checked time
    await prefs.setInt('lastReportTime', currentTimestamp);
    print("Report for current day ($reportKey) saved to monthlyReports box.");
    print("📦 Total Transactions Found: ${recentTransactions.length}");
    recentTransactions.forEach((tx) {
      print("📅 TX: ${tx.category}, ${tx.amount}, ${tx.date}");
    });

    // Debug: Print all reports
    final allReports = reportBox.toMap();
    allReports.forEach((key, value) {
      print("📁 Report $key → Income: ${value.income}, Expense: ${value.expense}, Remaining: ${value.remainingBudget}");
    });

    // Show notification
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Report generated and transactions cleared")),
      );
    }
  }

  @override
  void dispose() {
    _reportTimer?.cancel(); // Clean up timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      drawer: const AppDrawer(),
      body: ValueListenableBuilder(
        valueListenable: transactionBox.listenable(),
        builder: (context, Box<TransactionModel> box, _) {
          return Column(
            children: [
              SummaryCard(transactionBox: transactionBox),
              Row(
                children: [
                 /* TextButton(
                    onPressed: () async {
                      await _checkTimeChangeAndGenerateReport();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Report generated and transactions cleared")),
                        );
                      }
                    },
                    child: const Text("Generate Report"),
                  ),*/
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await AuthService().logout();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logging out...')),
                        );
                      }
                      await Future.delayed(const Duration(seconds: 1));
                      SystemNavigator.pop();
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}