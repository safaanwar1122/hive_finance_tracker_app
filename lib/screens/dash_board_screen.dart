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
import 'last_month_report_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final Box<TransactionModel> transactionBox;

  @override
  void initState() {
    super.initState();
transactionBox=Hive.box<TransactionModel>('transactions');
    _checkMonthChangeAndGenerateReport();
  }

 /* Future<void> _checkMonthChangeAndGenerateReport() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckedMonth = prefs.getString('lastReportMonth');
    final now = DateTime.now();
    // final currentMonthKey="${now.year}-${now.month}";
    final currentMonthKey =
        "2025-08"; // 👈 fake current month (e.g., August 2025) for testing report generation feature
    if (lastCheckedMonth == currentMonthKey) return;
    final box = Hive.box<TransactionModel>('transactions');
    // final prevMonth=DateTime(now.year, now.month-1);
    final prevMonth = DateTime(2025, 7); // 👈 fake previous month July 2025
    final previousMonthTransactions = box.values
        .where((tx) =>
            tx.date.year == prevMonth.year && tx.date.month == prevMonth.month)
        .toList();
    final totalIncome = previousMonthTransactions
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    final totalExpense = previousMonthTransactions
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    final monthlyBudget = prefs.getDouble('monthlyBudget') ?? 0.0;
    final remainingBudget =
        (monthlyBudget - totalExpense).clamp(0.0, monthlyBudget);
    await prefs.setDouble('prevMonthIncome', totalIncome);
    await prefs.setDouble('prevMonthExpense', totalExpense);
    await prefs.setDouble('prevMonthRemainingBudget', remainingBudget);
    for (var tx in previousMonthTransactions) {
      await tx.delete();
    }
    await prefs.setString('lastReportMonth', currentMonthKey);
    print("Saved Income: $totalIncome");
    print("Saved Expense: $totalExpense");
    print("Saved Remaining Budget: $remainingBudget");

  }
*/
  Future<void> _checkMonthChangeAndGenerateReport()async{
    final prefs=await SharedPreferences.getInstance();
    final lastCheckedMonth=prefs.getString('lastReportMonth');
    final now=DateTime.now();
    // Format the current month (e.g., "2025-08")
    final currentMonthKey="${now.year}-${now.month.toString().padLeft(2,'0')}";
    if(lastCheckedMonth==currentMonthKey)return;
    final box=Hive.box<TransactionModel>('transactions');
    final monthlyReportBox=Hive.box<MonthlyReportModel>('monthlyReports');
    // Target previous month (e.g., now is Aug → target July)
    final prevMonth=DateTime(now.year, now.month-1);
    final prevMonthKey="${prevMonth.year}-${prevMonth.month.toString().padLeft(2,'0')}";

    final previousMonthTransactions=box.values.where((tx)=>tx.date.year==
    prevMonth.year&&tx.date.month==prevMonth.month
    ).toList();
// Calculate totals
  final totalIncome=previousMonthTransactions.where((tx)=>tx.isIncome).fold(0.0, (sum, tx)=>sum+tx.amount);
  final totalExpense=previousMonthTransactions.where((tx)=>!tx.isIncome)
    .fold(0.0, (sum,tx)=>sum+tx.amount);
final monthlyBudget=prefs.getDouble('monthlyBudget')??0.0;
final remainingBudget=(monthlyBudget-totalExpense).clamp(0.0, monthlyBudget);
// ✅ Store in Hive monthly report box
  await monthlyReportBox.put(prevMonthKey,
    MonthlyReportModel(
      monthKey: prevMonthKey,
      transactions: previousMonthTransactions,
      income: totalIncome,
      expense: totalExpense,
      remainingBudget: remainingBudget,
    ),);
    // ✅ Mark current month as last checked
    await prefs.setString('lastReportMonth', currentMonthKey);
    print("Report for $prevMonthKey saved to monthlyReports box.");
    print("📦 Total June Transactions Found: ${previousMonthTransactions.length}");
    previousMonthTransactions.forEach((tx) {
      print("📅 TX: ${tx.category}, ${tx.amount}, ${tx.date}");
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      drawer: AppDrawer(),
      body: ValueListenableBuilder(
          valueListenable: transactionBox.listenable(),
          builder: (context, Box<TransactionModel> box, _) {
            return Column(
              children: [
                SummaryCard(transactionBox: transactionBox),
               Row(
                 children: [
                   TextButton(
                     onPressed: () async {
                       await _checkMonthChangeAndGenerateReport();
                       // 🔍 Debugging: Print all reports saved so far
                       final monthlyReportBox = Hive.box<MonthlyReportModel>('monthlyReports');
                       final allReports = monthlyReportBox.toMap();
                       allReports.forEach((key, value) {
                         print("📁 Report $key → Income: ${value.income}, Tx: ${value.transactions.length}");
                       });
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text("Report generated")),
                       );
                     },
                     child: Text("Generate Report"),
                   ),

                   IconButton(
                     icon: Icon(Icons.logout),
                     onPressed: () async {
                       await AuthService().logout();
                       // Show snackbar message
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text('Logging out...')),
                       );

                       // Wait briefly before closing app
                       await Future.delayed(Duration(seconds: 1));

                       // Close the app
                       SystemNavigator.pop();
                     //  Navigator.pushReplacementNamed(context, '/auth'); // Go back to auth screen
                     },
                   ),
                 ],
               ),
              ],
            );
          }),
    );
  }
}
