import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../adapter_models/monthly_report_model.dart';
import '../view_model/auth_dir/finance_provider.dart';
import '../widgets/app_drawer.dart';


class RecentReportScreen extends StatefulWidget {
  const RecentReportScreen({super.key});

  @override
  State<RecentReportScreen> createState() => _RecentReportScreenState();
}

class _RecentReportScreenState extends State<RecentReportScreen> {
  @override
  bool _isInitialized = false;
  void didChangeDependencies(){
    super.didChangeDependencies();

    if(!_isInitialized){
      _isInitialized=true;

     WidgetsBinding.instance.addPostFrameCallback((_){
       final provider =
       Provider.of<FinanceTrackerProvider>(context, listen: false);
       provider.loadReports();
     });

    }
  }
  /* void initState() {
    super.initState();
    final provider =
        Provider.of<FinanceTrackerProvider>(context, listen: false);

    provider.loadReports();
  }*/

  @override
  Widget build(BuildContext context) {
    final provider =
    Provider.of<FinanceTrackerProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Current Day Reports"),
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: provider.reports.isEmpty
            ? const Center(child: Text("No reports found for current day."))
            : ListView.builder(
          itemCount: provider.reports.length,
          itemBuilder: (context, index) {
            final report = provider.reports[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Report: ${report.monthKey.split('_')[0]} ${report.monthKey.split('_')[1].replaceAll('-', ':')}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                        "Income: Rs ${report.income.toStringAsFixed(2)}"),
                    Text(
                        "Expense: Rs ${report.expense.toStringAsFixed(2)}"),
                    Text(
                      "Cumulative Balance: Rs ${provider.cumulativeBalance.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),

                    const SizedBox(height: 10),
                    const Text("Transactions:",
                        style: TextStyle(fontSize: 18)),
                    report.transactions.isEmpty
                        ? const Text("No transactions in this report.")
                        : Consumer<FinanceTrackerProvider>(
                        builder: (context, provider, _) {
                          final reports = provider.reports;
                          return ListView.builder(
                            shrinkWrap: true,
                            physics:
                            const NeverScrollableScrollPhysics(),
                            itemCount: report.transactions.length,
                            itemBuilder: (context, txIndex) {
                              final tx = report.transactions[txIndex];
                              return ListTile(
                                title: Text(tx.category),
                                subtitle: Text(tx.date.toString()),
                                trailing: Text(
                                  "Rs ${tx.amount.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: tx.isIncome
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          );
                        }),
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
