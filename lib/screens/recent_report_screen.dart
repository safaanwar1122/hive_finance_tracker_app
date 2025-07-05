import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_financial_tracker_app/models/monthly_report_model.dart';

import '../widgets/app_drawer.dart';
/*

class RecentReportScreen extends StatefulWidget {
  const RecentReportScreen({super.key});

  @override
  State<RecentReportScreen> createState() => _RecentReportScreenState();
}

class _RecentReportScreenState extends State<RecentReportScreen> {
  MonthlyReportModel? _report;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadRecentReport();
  }

  Future<void> _loadRecentReport() async {
   // final now = DateTime.now();
    final reportBox = Hive.box<MonthlyReportModel>('monthlyReports');
    // Find the most recent report key ending with '_5minutes'
    final reportKeys = reportBox.keys
        .where((key) => key.toString().endsWith('_2minutes'))
        .toList();
    String? latestReportKey;
    DateTime? latestTime;
    for (var key in reportKeys) {
      final timestampStr = key.toString().split('_')[0];// Extract YYYY-MM-DD
     final timeStr=key.toString().split('_')[1];// Extract HH-mm
      try {
        // Parse the simplified date format
        final timestamp = DateTime.parse("$timestampStr $timeStr:00");
        if (latestTime == null || timestamp.isAfter(latestTime)) {
          latestTime = timestamp;
          latestReportKey = key;
        }
      } catch (e) {
        print("Error parsing timestamp for key $key: $e");
      }
    }

    final report =
        latestReportKey != null ? reportBox.get(latestReportKey) : null;
    print("📋 Available report keys: ${reportBox.keys}");
    print("🔎 Trying to load report for $latestReportKey");
    print("Found report? ${report != null}");
    if (report != null) {
      print(
          "📊 Report Details: Income: ${report.income}, Expense: ${report.expense}, "
          "Transactions: ${report.transactions.length}, Remaining: ${report.remainingBudget}");
    }
    setState(() {
      _report = report;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Last 2 Minutes Report"),
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _report == null
            ? Center(child: Text("No report found for last 2 minutes."))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Period: Last 2 Minutes",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("Income: Rs ${_report!.income.toStringAsFixed(2)}"),
                  Text("Expense: Rs ${_report!.expense.toStringAsFixed(2)}"),
                  Text(
                      "Remaining Budget: Rs ${_report!.remainingBudget.toStringAsFixed(2)}"),
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
                                  color:
                                      tx.isIncome ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }))
                ],
              ),
      ),
    );
  }
}
*/

/*

class RecentReportScreen extends StatefulWidget {
  const RecentReportScreen({super.key});

  @override
  State<RecentReportScreen> createState() => _RecentReportScreenState();
}

class _RecentReportScreenState extends State<RecentReportScreen> {
  MonthlyReportModel? _report;

  @override
  void initState() {
    super.initState();
    _loadRecentReport();
  }

  Future<void> _loadRecentReport() async {
    final reportBox = Hive.box<MonthlyReportModel>('monthlyReports');

    // Optional: Clean up old _5minutes reports to avoid clutter
    final oldKeys = reportBox.keys
        .where((key) => key.toString().endsWith('_5minutes'))
        .toList();
    for (var key in oldKeys) {
      await reportBox.delete(key);
      print("🗑️ Deleted old report: $key");
    }

    // Find the most recent report key ending with '_2minutes'
    final reportKeys = reportBox.keys
        .where((key) => key.toString().endsWith('_2minutes'))
        .toList();

    String? latestReportKey;
    DateTime? latestTime;

    for (var key in reportKeys) {
      try {
        // Extract date and time from key (format: YYYY-MM-DD_HH-mm_2minutes)
        final parts = key.toString().split('_');
        if (parts.length != 3) continue; // Skip invalid keys
        final dateStr = parts[0]; // YYYY-MM-DD
        final timeStr = parts[1]; // HH-mm
        final timestamp = DateTime.parse("$dateStr ${timeStr.replaceAll('-', ':')}:00");

        if (latestTime == null || timestamp.isAfter(latestTime)) {
          latestTime = timestamp;
          latestReportKey = key;
        }
      } catch (e) {
        print("Error parsing timestamp for key $key: $e");
      }
    }

    final report = latestReportKey != null ? reportBox.get(latestReportKey) : null;
    print("📋 Available report keys: ${reportBox.keys}");
    print("🔎 Trying to load report for $latestReportKey");
    print("Found report? ${report != null}");
    if (report != null) {
      print("📊 Report Details: Income: ${report.income}, Expense: ${report.expense}, "
          "Transactions: ${report.transactions.length}, Remaining: ${report.remainingBudget}");
    }
    setState(() {
      _report = report;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Current Day Report"),
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _report == null
            ? const Center(child: Text("No report found for current day."))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                "Period: Current Day",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 10),
            Text("Income: Rs ${_report!.income.toStringAsFixed(2)}"),
            Text("Expense: Rs ${_report!.expense.toStringAsFixed(2)}"),
            Text("Remaining Budget: Rs ${_report!.remainingBudget.toStringAsFixed(2)}"),
            const SizedBox(height: 20),
            const Text("Transactions:", style: TextStyle(fontSize: 18)),

          ],
        ),
      ),
    );
  }
}*/
class RecentReportScreen extends StatefulWidget {
  const RecentReportScreen({super.key});

  @override
  State<RecentReportScreen> createState() => _RecentReportScreenState();
}

class _RecentReportScreenState extends State<RecentReportScreen> {
  List<MonthlyReportModel> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
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
      final aTime = DateTime.parse("${aParts[0]} ${aParts[1].replaceAll('-', ':')}:00");
      final bTime = DateTime.parse("${bParts[0]} ${bParts[1].replaceAll('-', ':')}:00");
      return bTime.compareTo(aTime); // Descending order (newest first)
    });

    final reports = sortedReports.map((entry) => entry.value).toList();

    print("📋 Available report keys: ${reportBox.keys}");
    for (var report in reports) {
      print("📊 Report ${report.monthKey}: Income: ${report.income}, "
          "Expense: ${report.expense}, Transactions: ${report.transactions.length}, "
          "Remaining: ${report.remainingBudget}");
    }

    setState(() {
      _reports = reports;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Current Day Reports"),
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _reports.isEmpty
            ? const Center(child: Text("No reports found for current day."))
            : ListView.builder(
          itemCount: _reports.length,
          itemBuilder: (context, index) {
            final report = _reports[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Report: ${report.monthKey.split('_')[0]} ${report.monthKey.split('_')[1].replaceAll('-', ':')}",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text("Income: Rs ${report.income.toStringAsFixed(2)}"),
                    Text("Expense: Rs ${report.expense.toStringAsFixed(2)}"),
                    Text("Remaining Budget: Rs ${report.remainingBudget.toStringAsFixed(2)}"),
                    const SizedBox(height: 10),
                    const Text("Transactions:", style: TextStyle(fontSize: 18)),
                    report.transactions.isEmpty
                        ? const Text("No transactions in this report.")
                        : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: report.transactions.length,
                      itemBuilder: (context, txIndex) {
                        final tx = report.transactions[txIndex];
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
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}