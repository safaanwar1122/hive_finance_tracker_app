import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_financial_tracker_app/adapter_models/transaction_model.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../adapter_models/category_model.dart';
import '../../adapter_models/monthly_report_model.dart';


class FinanceTrackerProvider extends ChangeNotifier {
  final LocalAuthentication authentication = LocalAuthentication();

  final Box<CategoryModel> categoryBox = Hive.box<CategoryModel>('categories');
  // Getter for transactionBox
  late final Box<TransactionModel> _transactionBox;
  late final Box<MonthlyReportModel> _reportBox;
  late final Box<CategoryModel> _categoryBox;
  Timer? _reportTimer;

  late final Future<void> _initialized;
  Box<TransactionModel> get transactionBox => _transactionBox;

  // Getter for initialization future
  Future<void> get initialized => _initialized;


  Future<void> _initialize(BuildContext context) async {
    _transactionBox = await Hive.openBox<TransactionModel>('transactions');
    _reportBox = await Hive.openBox<MonthlyReportModel>('monthlyReports');
    _categoryBox = await Hive.openBox<CategoryModel>('categories');
    startReportGenerationTimer(context);
  }

  Timer? reportTimer;
  List<MonthlyReportModel> _reports = [];
  List<MonthlyReportModel> get reports => _reports;

  Future<void> submitTransaction({
    required BuildContext context,
    required double amount,
    required String description,
    required String selectedCategory,
    required bool isIncome,
    TransactionModel? transaction,
  }) async
  {
    try {
      final box = Hive.box<TransactionModel>('transactions');
      final allTransactions = box.values.toList();
      // Calculate current balance from transactions box
      final totalIncome = allTransactions
          .where((tx) => tx.isIncome)
          .fold(0.0, (sum, tx) => sum + tx.amount);
      final totalExpense = allTransactions
          .where((tx) => !tx.isIncome)
          .fold(0.0, (sum, tx) => sum + tx.amount);
      // Get latest report balance from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final latestReportBalance = prefs.getDouble('latestReportBalance') ?? 0.0;
      final currentBalance = latestReportBalance + (totalIncome - totalExpense);
      // Prevent overspending
      if (!isIncome && amount > currentBalance) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Not enough balance to add this expense.")),
        );
        return;
      }
      // Continue adding/editing transaction
      if (transaction == null) {
        final transaction = TransactionModel(
          amount: amount,
          description: description,
          category: selectedCategory,
          date: DateTime.now(),
          isIncome: isIncome,
        );
        await box.add(transaction);
        print(
            "✅ Transaction saved: ${transaction.category}, ${transaction.amount}, ${transaction.date}");
      } else {
        transaction
          ..amount = amount
          ..description = description
          ..category = selectedCategory
          ..isIncome = isIncome
          ..date = DateTime.now();
        await transaction.save();
        print(
            "✅ Transaction updated: ${transaction.category}, ${transaction.amount}, ${transaction.date}");
      }
      print("📦 All transactions in box: ${box.values.length}");
      box.values.forEach((tx) {
        print("📅 TX: ${tx.category}, ${tx.amount}, ${tx.date}");
      });
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transaction saved!")),
      );
      notifyListeners();
    } catch (e, stackTrace) {
      print("🚨 Error during transaction save: $e");
      print("🪵 StackTrace: $stackTrace");
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text("Something went wrong.\n$e"),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }
  Future<void> loadReports() async {
    final reportBox = Hive.box<MonthlyReportModel>('monthlyReports');

    // Clean up old _5minutes reports
    final oldKeys = reportBox.keys
        .where((key) => key.toString().endsWith('_5minutes'))
        .toList();
    for (var key in oldKeys) {
      await reportBox.delete(key);
      print("🗑️ Deleted old report: $key");
    }

    // Get all reports with _2minutes suffix, sorted by timestamp
    final reportKeys = reportBox.keys
        .where((key) => key.toString().endsWith('_2minutes'))
        .toList();

    List<MapEntry<String, MonthlyReportModel>> sortedReports = [];
    for (var key in reportKeys) {
      try {
        final report = reportBox.get(key);
        if (report != null) {
          sortedReports.add(MapEntry(key, report));
        }
      } catch (e) {
        print("Error loading report for key $key: $e");
      }
    }

    // Sort reports by timestamp (most recent first)
    sortedReports.sort((a, b) {
      final aParts = a.key.split('_');
      final bParts = b.key.split('_');
      if (aParts.length != 3 || bParts.length != 3) return 0;
      final aTime =
      DateTime.parse("${aParts[0]} ${aParts[1].replaceAll('-', ':')}:00");
      final bTime =
      DateTime.parse("${bParts[0]} ${bParts[1].replaceAll('-', ':')}:00");
      return bTime.compareTo(aTime); // Descending order (newest first)
    });

    final reports = sortedReports.map((entry) => entry.value).toList();

    print("📋 Available report keys: ${reportBox.keys}");
    for (var report in reports) {
      print("📊 Report ${report.monthKey}: Income: ${report.income}, "
          "Expense: ${report.expense}, Transactions: ${report.transactions.length}, "
          "Remaining: ${report.remainingBudget}");
    }

    _reports = reports;
    notifyListeners();
  }

  void startReportGenerationTimer(BuildContext context) {
    // Generate report immediately on init
    checkTimeChangeAndGenerateReport(context);
    // Set up a timer to generate report every 2 minutes
    reportTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      checkTimeChangeAndGenerateReport(context);
    });
  }

  Future<void> checkTimeChangeAndGenerateReport(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckedTime = prefs.getInt('lastReportTime') ?? 0;
    final now = DateTime.now();
    final currentTimestamp = now.millisecondsSinceEpoch;

    // Skip if report was generated within the last 2 minutes
    if (lastCheckedTime >
        now.subtract(const Duration(minutes: 2)).millisecondsSinceEpoch) return;

    final box = Hive.box<TransactionModel>('transactions');
    final reportBox = Hive.box<MonthlyReportModel>('monthlyReports');
    // Use a simpler report key format: YYYY-MM-DD_HH-mm
    final reportKey =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}_2minutes";

    // Filter transactions for the current day (from midnight to now)
    final startTime =
        DateTime(now.year, now.month, now.day); // Midnight of current day
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
    print(
        "🗑️ Cleared all transactions from transactions box after report generation.");

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
      print(
          "📁 Report $key → Income: ${value.income}, Expense: ${value.expense}, Remaining: ${value.remainingBudget}");
    });

    // Show notification
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Report generated and transactions cleared")),
      );
    }
  }


  Future<double> getCumulativeBalance() async {
    final reportBox = Hive.box<MonthlyReportModel>('monthlyReports');
    final cumulativeBalance = reportBox.values
        .fold(0.0, (sum, report) => sum + report.remainingBudget);
    return cumulativeBalance;
  }

  double get cumulativeBalance {
    return _reports.fold(0.0, (sum, report) => sum + report.remainingBudget);
  }
}
